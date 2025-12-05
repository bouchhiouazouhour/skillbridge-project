<?php

namespace App\Http\Controllers;

use App\Models\CV;
use App\Models\JobMatch;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

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
     * Analyze CV against job description.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function analyze(Request $request)
    {
        // Validate the incoming request
        $validator = Validator::make($request->all(), [
            'job_description' => 'required|string|min:50',
            'cv_id' => 'nullable|integer|exists:cvs,id',
            'cv' => 'nullable|file|mimes:pdf,doc,docx|max:10240',
        ], [
            'job_description.required' => 'Please provide a job description.',
            'job_description.min' => 'Job description must be at least 50 characters.',
            'cv_id.exists' => 'The selected CV does not exist.',
            'cv.mimes' => 'Only PDF and DOCX files are supported.',
            'cv.max' => 'The file size must not exceed 10MB.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => $validator->errors()->first(),
                'errors' => $validator->errors(),
            ], 422);
        }

        // Check that either cv_id or cv file is provided
        if (!$request->has('cv_id') && !$request->hasFile('cv')) {
            return response()->json([
                'success' => false,
                'error' => 'Please provide either a CV ID or upload a CV file.',
            ], 422);
        }

        $userId = auth()->id();
        $cvId = null;
        $filePath = null;
        $file = null;

        // Get CV file path from storage or uploaded file
        if ($request->has('cv_id')) {
            $cv = CV::where('id', $request->cv_id)
                ->where('user_id', $userId)
                ->first();

            if (!$cv) {
                return response()->json([
                    'success' => false,
                    'error' => 'CV not found or unauthorized.',
                ], 404);
            }

            $cvId = $cv->id;
            $filePath = Storage::path($cv->file_path);

            if (!file_exists($filePath)) {
                return response()->json([
                    'success' => false,
                    'error' => 'CV file not found in storage.',
                ], 404);
            }
        } else {
            $file = $request->file('cv');
        }

        Log::info('Job Match Analysis requested', [
            'user_id' => $userId,
            'cv_id' => $cvId,
            'has_file' => $file !== null,
            'job_description_length' => strlen($request->job_description),
        ]);

        // Call Python NLP service
        $result = $this->performJobMatch($request->job_description, $filePath, $file);

        if (!$result['success']) {
            $statusCode = $result['status_code'] ?? 500;
            return response()->json([
                'success' => false,
                'error' => $result['error'],
                'details' => $result['details'] ?? null,
            ], $statusCode);
        }

        // If uploaded a new file, save it first
        if ($file && !$cvId) {
            $filename = time() . '_' . $file->getClientOriginalName();
            $path = $file->storeAs('cvs', $filename, 'local');

            $cv = CV::create([
                'user_id' => $userId,
                'filename' => $filename,
                'file_path' => $path,
                'original_name' => $file->getClientOriginalName(),
                'status' => 'completed',
            ]);

            $cvId = $cv->id;
        }

        // Create JobMatch record
        $jobMatch = JobMatch::create([
            'user_id' => $userId,
            'cv_id' => $cvId,
            'job_description' => $request->job_description,
            'match_score' => $result['analysis']['match_score'] ?? 0,
            'match_verdict' => $result['analysis']['match_verdict'] ?? 'weak',
            'matching_skills' => $result['analysis']['matching_skills'] ?? [],
            'missing_skills' => $result['analysis']['missing_skills'] ?? [],
            'improvement_suggestions' => $result['analysis']['improvement_suggestions'] ?? [],
            'strengths' => $result['analysis']['strengths'] ?? [],
            'is_saved' => false,
        ]);

        Log::info('Job Match Analysis completed', [
            'job_match_id' => $jobMatch->id,
            'match_score' => $jobMatch->match_score,
            'match_verdict' => $jobMatch->match_verdict,
        ]);

        return response()->json([
            'success' => true,
            'job_match' => $jobMatch,
        ]);
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
        $jobMatch = JobMatch::where('id', $id)
            ->where('user_id', auth()->id())
            ->first();

        if (!$jobMatch) {
            return response()->json([
                'success' => false,
                'error' => 'Job match not found or unauthorized.',
            ], 404);
        }

        $jobMatch->update(['is_saved' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Job match saved to history.',
            'job_match' => $jobMatch,
        ]);
    }

    /**
     * Get user's saved job matches.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function history()
    {
        $jobMatches = JobMatch::where('user_id', auth()->id())
            ->where('is_saved', true)
            ->with('cv:id,original_name')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'job_matches' => $jobMatches,
            'total' => $jobMatches->count(),
        ]);
    }

    /**
     * Get specific job match details.
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        $jobMatch = JobMatch::where('id', $id)
            ->where('user_id', auth()->id())
            ->with('cv:id,original_name')
            ->first();

        if (!$jobMatch) {
            return response()->json([
                'success' => false,
                'error' => 'Job match not found or unauthorized.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'job_match' => $jobMatch,
        ]);
    }

    /**
     * Delete a saved job match.
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function delete($id)
    {
        $jobMatch = JobMatch::where('id', $id)
            ->where('user_id', auth()->id())
            ->first();

        if (!$jobMatch) {
            return response()->json([
                'success' => false,
                'error' => 'Job match not found or unauthorized.',
            ], 404);
        }

        $jobMatch->delete();

        return response()->json([
            'success' => true,
            'message' => 'Job match deleted successfully.',
        ]);
    }

    /**
     * Perform job match analysis via NLP service.
     *
     * @param string $jobDescription
     * @param string|null $filePath
     * @param \Illuminate\Http\UploadedFile|null $file
     * @return array
     */
    private function performJobMatch($jobDescription, $filePath = null, $file = null)
    {
        try {
            $ch = curl_init();

            $postData = ['job_description' => $jobDescription];

            if ($filePath) {
                $postData['file'] = new \CURLFile(
                    $filePath,
                    mime_content_type($filePath),
                    basename($filePath)
                );
            } elseif ($file) {
                $postData['file'] = new \CURLFile(
                    $file->getRealPath(),
                    $file->getMimeType(),
                    $file->getClientOriginalName()
                );
            }

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
                Log::error('NLP Service connection failed', ['error' => $curlError]);
                return [
                    'success' => false,
                    'error' => 'Job match service is currently unavailable. Please try again later.',
                    'status_code' => 503,
                ];
            }

            $analysisResult = json_decode($response, true);

            if ($httpCode < 200 || $httpCode >= 300) {
                Log::error('NLP Service error', [
                    'status' => $httpCode,
                    'body' => $response,
                ]);

                $errorMessage = 'Failed to analyze job match';
                $errorDetails = null;
                if (is_array($analysisResult)) {
                    $errorMessage = $analysisResult['error'] ?? $errorMessage;
                    $errorDetails = $analysisResult['details'] ?? null;
                }

                return [
                    'success' => false,
                    'error' => $errorMessage,
                    'details' => $errorDetails,
                    'status_code' => $httpCode,
                ];
            }

            if (!isset($analysisResult['success']) || !$analysisResult['success']) {
                return [
                    'success' => false,
                    'error' => $analysisResult['error'] ?? 'Job match analysis failed',
                    'details' => $analysisResult['details'] ?? null,
                    'status_code' => 400,
                ];
            }

            return [
                'success' => true,
                'analysis' => $analysisResult['analysis'],
            ];

        } catch (\Exception $e) {
            Log::error('Job Match Analysis error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return [
                'success' => false,
                'error' => 'An unexpected error occurred while analyzing job match.',
                'status_code' => 500,
            ];
        }
    }
}
