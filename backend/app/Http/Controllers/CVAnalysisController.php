<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class CVAnalysisController extends Controller
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
     * Analyze a CV file by forwarding it to the Python NLP service.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function analyze(Request $request)
    {
        // Validate the incoming request
        $validator = Validator::make($request->all(), [
            'file' => 'required|file|mimes:pdf,doc,docx|max:10240', // 10MB max
        ], [
            'file.required' => 'Please upload a CV file.',
            'file.file' => 'The uploaded file is invalid.',
            'file.mimes' => 'Only PDF and DOCX files are supported.',
            'file.max' => 'The file size must not exceed 10MB.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => $validator->errors()->first(),
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $file = $request->file('file');

            // Log the analysis request
            Log::info('CV Analysis requested', [
                'filename' => $file->getClientOriginalName(),
                'size' => $file->getSize(),
                'mime' => $file->getMimeType(),
            ]);

            // Forward the file to the Python NLP service
            $response = Http::timeout(120)
                ->attach(
                    'file',
                    file_get_contents($file->getRealPath()),
                    $file->getClientOriginalName()
                )
                ->post("{$this->nlpServiceUrl}/analyze-cv");

            // Check if the request was successful
            if (!$response->successful()) {
                Log::error('NLP Service error', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);

                $errorData = $response->json();
                
                return response()->json([
                    'success' => false,
                    'error' => $errorData['error'] ?? 'Failed to analyze CV',
                    'details' => $errorData['details'] ?? null,
                ], $response->status());
            }

            $analysisResult = $response->json();

            // Check if the analysis was successful
            if (!isset($analysisResult['success']) || !$analysisResult['success']) {
                return response()->json([
                    'success' => false,
                    'error' => $analysisResult['error'] ?? 'Analysis failed',
                    'details' => $analysisResult['details'] ?? null,
                ], 400);
            }

            Log::info('CV Analysis completed successfully', [
                'filename' => $file->getClientOriginalName(),
                'score' => $analysisResult['analysis']['overall_score'] ?? 'N/A',
            ]);

            return response()->json([
                'success' => true,
                'analysis' => $analysisResult['analysis'],
                'cv_length' => $analysisResult['cv_length'] ?? null,
                'cv_preview' => $analysisResult['cv_preview'] ?? null,
            ]);

        } catch (\Illuminate\Http\Client\ConnectionException $e) {
            Log::error('NLP Service connection failed', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'error' => 'CV analysis service is currently unavailable. Please try again later.',
            ], 503);

        } catch (\Exception $e) {
            Log::error('CV Analysis error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'error' => 'An unexpected error occurred while analyzing your CV.',
            ], 500);
        }
    }

    /**
     * Check the health status of the NLP service.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function healthCheck()
    {
        try {
            $response = Http::timeout(10)->get("{$this->nlpServiceUrl}/health");

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'nlp_service' => $response->json(),
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => 'NLP service is not responding correctly',
            ], 503);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Could not connect to NLP service',
            ], 503);
        }
    }
}
