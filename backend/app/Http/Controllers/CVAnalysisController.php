<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
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

        $file = $request->file('file');

        Log::info('CV Analysis requested', [
            'filename' => $file->getClientOriginalName(),
            'size' => $file->getSize(),
            'mime' => $file->getMimeType(),
        ]);

        $result = $this->performAnalysis($file);

        if (!$result['success']) {
            $statusCode = $result['status_code'] ?? 500;
            return response()->json([
                'success' => false,
                'error' => $result['error'],
                'details' => $result['details'] ?? null,
            ], $statusCode);
        }

        Log::info('CV Analysis completed successfully', [
            'filename' => $file->getClientOriginalName(),
            'score' => $result['analysis']['overall_score'] ?? 'N/A',
        ]);

        return response()->json([
            'success' => true,
            'analysis' => $result['analysis'],
            'cv_length' => $result['cv_length'] ?? null,
            'cv_preview' => $result['cv_preview'] ?? null,
        ]);
    }

    /**
     * Analyze a CV file (internal method for CVController).
     *
     * @param \Illuminate\Http\UploadedFile $file
     * @return array
     */
    public function analyzeFile($file)
    {
        Log::info('Internal CV Analysis requested', [
            'filename' => $file->getClientOriginalName(),
            'size' => $file->getSize(),
        ]);

        $result = $this->performAnalysis($file);

        if ($result['success']) {
            Log::info('Internal CV Analysis completed successfully', [
                'filename' => $file->getClientOriginalName(),
                'score' => $result['analysis']['overall_score'] ?? 'N/A',
            ]);
        }

        // Remove internal status_code from result before returning
        unset($result['status_code']);

        return $result;
    }

    /**
     * Perform the actual CV analysis by forwarding to the NLP service.
     *
     * @param \Illuminate\Http\UploadedFile $file
     * @return array
     */
    private function performAnalysis($file)
    {
        try {
            // Use cURL instead of Http facade to avoid Guzzle dependency
            $ch = curl_init();

            $cfile = new \CURLFile(
                $file->getRealPath(),
                $file->getMimeType(),
                $file->getClientOriginalName()
            );

            $postData = ['file' => $cfile];

            curl_setopt_array($ch, [
                CURLOPT_URL => "{$this->nlpServiceUrl}/analyze-cv",
                CURLOPT_POST => true,
                CURLOPT_POSTFIELDS => $postData,
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_TIMEOUT => 120, // 2 minute timeout for AI analysis
                CURLOPT_HTTPHEADER => [
                    'Accept: application/json',
                ],
            ]);

            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $curlError = curl_error($ch);
            curl_close($ch);

            // Handle cURL errors (connection issues)
            if ($curlError) {
                Log::error('NLP Service connection failed', [
                    'error' => $curlError,
                ]);

                return [
                    'success' => false,
                    'error' => 'CV analysis service is currently unavailable. Please try again later.',
                    'status_code' => 503,
                ];
            }

            // Parse the response
            $analysisResult = json_decode($response, true);

            // Check if the request was successful (HTTP 2xx)
            if ($httpCode < 200 || $httpCode >= 300) {
                Log::error('NLP Service error', [
                    'status' => $httpCode,
                    'body' => $response,
                ]);

                return [
                    'success' => false,
                    'error' => $analysisResult['error'] ?? 'Failed to analyze CV',
                    'details' => $analysisResult['details'] ?? null,
                    'status_code' => $httpCode,
                ];
            }

            // Check if the analysis was successful
            if (!isset($analysisResult['success']) || !$analysisResult['success']) {
                return [
                    'success' => false,
                    'error' => $analysisResult['error'] ?? 'Analysis failed',
                    'details' => $analysisResult['details'] ?? null,
                    'status_code' => 400,
                ];
            }

            return [
                'success' => true,
                'analysis' => $analysisResult['analysis'],
                'cv_length' => $analysisResult['cv_length'] ?? null,
                'cv_preview' => $analysisResult['cv_preview'] ?? null,
            ];

        } catch (\Exception $e) {
            Log::error('CV Analysis error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return [
                'success' => false,
                'error' => 'An unexpected error occurred while analyzing your CV.',
                'status_code' => 500,
            ];
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
            // Use cURL instead of Http facade to avoid Guzzle dependency
            $ch = curl_init();

            curl_setopt_array($ch, [
                CURLOPT_URL => "{$this->nlpServiceUrl}/health",
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_TIMEOUT => 10,
                CURLOPT_HTTPHEADER => [
                    'Accept: application/json',
                ],
            ]);

            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $curlError = curl_error($ch);
            curl_close($ch);

            if ($curlError || $httpCode < 200 || $httpCode >= 300) {
                return response()->json([
                    'success' => false,
                    'error' => $curlError ?: 'NLP service is not responding correctly',
                ], 503);
            }

            $data = json_decode($response, true);

            return response()->json([
                'success' => true,
                'nlp_service' => $data,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Could not connect to NLP service',
            ], 503);
        }
    }
}
