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
     * Analyze job match between a CV and job description.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function analyzeMatch(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'cv_id' => 'required|exists:cvs,id',
            'job_description' => 'required|string|min:100',
        ], [
            'cv_id.required' => 'Please select a CV.',
            'cv_id.exists' => 'The selected CV does not exist.',
            'job_description.required' => 'Please provide a job description.',
            'job_description.min' => 'Job description must be at least 100 characters.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => $validator->errors()->first(),
                'errors' => $validator->errors(),
            ], 422);
        }

        $cv = CV::findOrFail($request->cv_id);

        // Verify user owns the CV
        if ($cv->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'error' => 'Unauthorized access to CV',
            ], 403);
        }

        // Get the CV file path with path traversal protection
        $cvFilePath = Storage::disk('local')->path($cv->file_path);
        
        // Validate the resolved path is within the storage directory
        $storagePath = Storage::disk('local')->path('');
        $realCvPath = realpath($cvFilePath);
        $realStoragePath = realpath($storagePath);
        
        if ($realCvPath === false || $realStoragePath === false || 
            strpos($realCvPath, $realStoragePath) !== 0) {
            Log::warning('Potential path traversal attempt', [
                'cv_id' => $cv->id,
                'file_path' => $cv->file_path,
            ]);
            return response()->json([
                'success' => false,
                'error' => 'Invalid CV file path',
            ], 400);
        }

        if (!file_exists($cvFilePath)) {
            return response()->json([
                'success' => false,
                'error' => 'CV file not found',
            ], 404);
        }

        Log::info('Job Match Analysis requested', [
            'cv_id' => $cv->id,
            'job_description_length' => strlen($request->job_description),
        ]);

        // Call Python NLP service
        $result = $this->callMatchJobService($cvFilePath, $request->job_description);

        if (!$result['success']) {
            return response()->json([
                'success' => false,
                'error' => $result['error'],
                'details' => $result['details'] ?? null,
            ], $result['status_code'] ?? 500);
        }

        // Store the job match result (not saved by default)
        $jobMatch = JobMatch::create([
            'user_id' => auth()->id(),
            'cv_id' => $cv->id,
            'job_description' => $request->job_description,
            'match_score' => $result['match_score'],
            'match_verdict' => $result['match_verdict'],
            'matching_skills' => $result['matching_skills'],
            'missing_skills' => $result['missing_skills'],
            'improvement_suggestions' => $result['improvement_suggestions'],
            'strengths' => $result['strengths'],
            'is_saved' => false,
        ]);

        Log::info('Job Match Analysis completed', [
            'job_match_id' => $jobMatch->id,
            'match_score' => $jobMatch->match_score,
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
    public function saveMatch(Request $request, $id)
    {
        $jobMatch = JobMatch::findOrFail($id);

        if ($jobMatch->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'error' => 'Unauthorized',
            ], 403);
        }

        $jobMatch->update(['is_saved' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Job match saved to history',
            'job_match' => $jobMatch,
        ]);
    }

    /**
     * Get saved job match history.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getHistory(Request $request)
    {
        $jobMatches = JobMatch::where('user_id', auth()->id())
            ->where('is_saved', true)
            ->with('cv:id,filename,original_name')
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($match) {
                return [
                    'id' => $match->id,
                    'cv_id' => $match->cv_id,
                    'cv_name' => $match->cv->original_name ?? $match->cv->filename,
                    'match_score' => $match->match_score,
                    'match_verdict' => $match->match_verdict,
                    'job_description_preview' => substr($match->job_description, 0, 100) . '...',
                    'created_at' => $match->created_at,
                ];
            });

        return response()->json([
            'success' => true,
            'job_matches' => $jobMatches,
            'total' => $jobMatches->count(),
        ]);
    }

    /**
     * Get a specific job match.
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function getMatch($id)
    {
        $jobMatch = JobMatch::with('cv:id,filename,original_name')->findOrFail($id);

        if ($jobMatch->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'error' => 'Unauthorized',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'job_match' => $jobMatch,
        ]);
    }

    /**
     * Delete a job match.
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function deleteMatch($id)
    {
        $jobMatch = JobMatch::findOrFail($id);

        if ($jobMatch->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'error' => 'Unauthorized',
            ], 403);
        }

        $jobMatch->delete();

        return response()->json([
            'success' => true,
            'message' => 'Job match deleted',
        ]);
    }

    /**
     * Call the Python NLP service to match job description with CV.
     *
     * @param string $cvFilePath
     * @param string $jobDescription
     * @return array
     */
    private function callMatchJobService($cvFilePath, $jobDescription)
    {
        try {
            $ch = curl_init();

            $postData = json_encode([
                'cv_file_path' => $cvFilePath,
                'job_description' => $jobDescription,
            ]);

            curl_setopt_array($ch, [
                CURLOPT_URL => "{$this->nlpServiceUrl}/match-job",
                CURLOPT_POST => true,
                CURLOPT_POSTFIELDS => $postData,
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_TIMEOUT => 120,
                CURLOPT_HTTPHEADER => [
                    'Content-Type: application/json',
                    'Accept: application/json',
                ],
            ]);

            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $curlError = curl_error($ch);
            curl_close($ch);

            if ($curlError) {
                Log::error('NLP Service connection failed', [
                    'error' => $curlError,
                ]);

                return [
                    'success' => false,
                    'error' => 'Job matching service is currently unavailable. Please try again later.',
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
                'match_score' => $analysisResult['match_score'],
                'match_verdict' => $analysisResult['match_verdict'],
                'matching_skills' => $analysisResult['matching_skills'] ?? [],
                'missing_skills' => $analysisResult['missing_skills'] ?? [],
                'improvement_suggestions' => $analysisResult['improvement_suggestions'] ?? [],
                'strengths' => $analysisResult['strengths'] ?? [],
            ];

        } catch (\Exception $e) {
            Log::error('Job Match Analysis error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return [
                'success' => false,
                'error' => 'An unexpected error occurred during job match analysis.',
                'status_code' => 500,
            ];
        }
    }
}
