<?php

namespace App\Http\Controllers;

use App\Models\JobMatch;
use App\Models\CV;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class JobMatchController extends Controller
{
    /**
     * The URL of the Python NLP service.
     */
    protected $nlpServiceUrl;

    public function __construct()
    {
        $this->nlpServiceUrl = env('NLP_SERVICE_URL', 'http://localhost:5000');
    }

    /**
     * Analyze CV against a job description.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function analyze(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'cv_id' => 'required|integer|exists:cvs,id',
            'job_description' => 'required|string|min:50',
            'job_title' => 'nullable|string|max:255',
            'company_name' => 'nullable|string|max:255',
        ], [
            'cv_id.required' => 'Please select a CV.',
            'cv_id.exists' => 'The selected CV does not exist.',
            'job_description.required' => 'Please provide a job description.',
            'job_description.min' => 'Job description must be at least 50 characters.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => $validator->errors()->first(),
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $cv = CV::where('id', $request->cv_id)
                 ->where('user_id', $user->id)
                 ->first();

        if (!$cv) {
            return response()->json([
                'success' => false,
                'error' => 'CV not found or access denied.',
            ], 404);
        }

        Log::info('Job Match Analysis requested', [
            'user_id' => $user->id,
            'cv_id' => $cv->id,
            'job_title' => $request->job_title,
        ]);

        // Get the CV file
        $filePath = storage_path('app/' . $cv->file_path);
        if (!file_exists($filePath)) {
            return response()->json([
                'success' => false,
                'error' => 'CV file not found.',
            ], 404);
        }

        // Call Python NLP service for job matching
        $result = $this->performJobMatch($filePath, $cv->original_name, $request->job_description);

        if (!$result['success']) {
            return response()->json([
                'success' => false,
                'error' => $result['error'],
                'details' => $result['details'] ?? null,
            ], $result['status_code'] ?? 500);
        }

        // Create job match record
        $jobMatch = JobMatch::create([
            'user_id' => $user->id,
            'cv_id' => $cv->id,
            'job_description' => $request->job_description,
            'job_title' => $request->job_title,
            'company_name' => $request->company_name,
            'match_score' => $result['match']['match_score'],
            'match_verdict' => $result['match']['verdict'],
            'matching_skills' => $result['match']['matching_skills'],
            'missing_skills' => $result['match']['missing_skills'],
            'improvement_suggestions' => $result['match']['suggestions'],
            'strengths' => $result['match']['strengths'],
            'is_saved' => false,
        ]);

        Log::info('Job Match Analysis completed', [
            'job_match_id' => $jobMatch->id,
            'match_score' => $jobMatch->match_score,
            'verdict' => $jobMatch->match_verdict,
        ]);

        return response()->json([
            'success' => true,
            'job_match' => $jobMatch,
        ]);
    }

    /**
     * Perform the job match analysis by calling the NLP service.
     *
     * @param string $filePath
     * @param string $originalName
     * @param string $jobDescription
     * @return array
     */
    private function performJobMatch($filePath, $originalName, $jobDescription)
    {
        try {
            $ch = curl_init();

            $cfile = new \CURLFile(
                $filePath,
                mime_content_type($filePath),
                $originalName
            );

            $postData = [
                'file' => $cfile,
                'job_description' => $jobDescription,
            ];

            curl_setopt_array($ch, [
                CURLOPT_URL => "{$this->nlpServiceUrl}/match-job",
                CURLOPT_POST => true,
                CURLOPT_POSTFIELDS => $postData,
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_TIMEOUT => 120,
                CURLOPT_HTTPHEADER => [
                    'Accept: application/json',
                ],
            ]);

            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $curlError = curl_error($ch);
            curl_close($ch);

            if ($curlError) {
                Log::error('NLP Service connection failed for job match', [
                    'error' => $curlError,
                ]);

                return [
                    'success' => false,
                    'error' => 'Job matching service is currently unavailable. Please try again later.',
                    'status_code' => 503,
                ];
            }

            $matchResult = json_decode($response, true);

            if ($httpCode < 200 || $httpCode >= 300) {
                Log::error('NLP Service error for job match', [
                    'status' => $httpCode,
                    'body' => $response,
                ]);

                $errorMessage = 'Failed to analyze job match';
                $errorDetails = null;
                if (is_array($matchResult)) {
                    $errorMessage = $matchResult['error'] ?? $errorMessage;
                    $errorDetails = $matchResult['details'] ?? null;
                }

                return [
                    'success' => false,
                    'error' => $errorMessage,
                    'details' => $errorDetails,
                    'status_code' => $httpCode,
                ];
            }

            if (!isset($matchResult['success']) || !$matchResult['success']) {
                return [
                    'success' => false,
                    'error' => $matchResult['error'] ?? 'Job match analysis failed',
                    'details' => $matchResult['details'] ?? null,
                    'status_code' => 400,
                ];
            }

            return [
                'success' => true,
                'match' => $matchResult['match'],
            ];

        } catch (\Exception $e) {
            Log::error('Job Match Analysis error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return [
                'success' => false,
                'error' => 'An unexpected error occurred while analyzing the job match.',
                'status_code' => 500,
            ];
        }
    }

    /**
     * Save a job match to history.
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function save(Request $request, $id)
    {
        $user = $request->user();
        $jobMatch = JobMatch::where('id', $id)
                            ->where('user_id', $user->id)
                            ->first();

        if (!$jobMatch) {
            return response()->json([
                'success' => false,
                'error' => 'Job match not found.',
            ], 404);
        }

        $jobMatch->is_saved = true;
        $jobMatch->save();

        return response()->json([
            'success' => true,
            'message' => 'Job match saved to history.',
            'job_match' => $jobMatch,
        ]);
    }

    /**
     * Get saved job match history.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function history(Request $request)
    {
        $user = $request->user();
        $matches = JobMatch::where('user_id', $user->id)
                           ->where('is_saved', true)
                           ->orderBy('created_at', 'desc')
                           ->get();

        return response()->json([
            'success' => true,
            'matches' => $matches,
        ]);
    }

    /**
     * Get a specific job match.
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Request $request, $id)
    {
        $user = $request->user();
        $jobMatch = JobMatch::where('id', $id)
                            ->where('user_id', $user->id)
                            ->first();

        if (!$jobMatch) {
            return response()->json([
                'success' => false,
                'error' => 'Job match not found.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'job_match' => $jobMatch,
        ]);
    }

    /**
     * Delete a job match.
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        $jobMatch = JobMatch::where('id', $id)
                            ->where('user_id', $user->id)
                            ->first();

        if (!$jobMatch) {
            return response()->json([
                'success' => false,
                'error' => 'Job match not found.',
            ], 404);
        }

        $jobMatch->delete();

        return response()->json([
            'success' => true,
            'message' => 'Job match deleted successfully.',
        ]);
    }
}
