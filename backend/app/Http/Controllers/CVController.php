<?php

namespace App\Http\Controllers;

use App\Models\CV;
use App\Models\CVAnalysis;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class CVController extends Controller
{
    public function upload(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'cv' => 'required|file|mimes:pdf,docx|max:10240', // 10MB max, PDF and DOCX only
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $file = $request->file('cv');
        $filename = time() . '_' . $file->getClientOriginalName();
        $path = $file->storeAs('cvs', $filename, 'local');

        try {
            // FIRST: Validate if it's a real CV by analyzing it
            $analysisController = new CVAnalysisController();
            $analysisResult = $analysisController->analyzeFile($file);

            if (!$analysisResult['success']) {
                // Analysis failed - determine error type
                $errorMsg = $analysisResult['error'] ?? 'Unknown error';
                $errorDetails = $analysisResult['details'] ?? null;

                // Check if it's a validation error (not a CV)
                $isValidationError = str_contains($errorMsg, 'not look like a CV') || 
                                    str_contains($errorMsg, 'not a valid CV') ||
                                    str_contains($errorMsg, 'does not appear to be');

                // Delete the uploaded file since validation failed
                if (Storage::disk('local')->exists($path)) {
                    Storage::disk('local')->delete($path);
                }

                Log::warning('File upload rejected - not a valid CV', [
                    'filename' => $file->getClientOriginalName(),
                    'error' => $errorMsg,
                ]);

                $statusCode = $isValidationError ? 422 : 500;
                
                return response()->json([
                    'error' => $errorMsg,
                    'message' => $errorMsg,
                    'details' => $errorDetails,
                ], $statusCode);
            }

            // SECOND: Only create CV record after successful validation
            $cv = CV::create([
                'user_id' => auth()->id(),
                'filename' => $filename,
                'file_path' => $path,
                'original_name' => $file->getClientOriginalName(),
                'status' => 'processing',
            ]);

            // THIRD: Store the analysis results
            $geminiAnalysis = $analysisResult['analysis'];

            // Extract data from Gemini response
            $skills = $geminiAnalysis['recommended_keywords'] ?? [];
            $missingSections = $geminiAnalysis['missing_sections'] ?? [];

            // Convert Gemini improvements to suggestions format
            $suggestions = [];
            foreach ($geminiAnalysis['improvements'] ?? [] as $improvement) {
                if (isset($improvement['suggestion'])) {
                    $suggestions[] = $improvement['suggestion'];
                }
            }

            // Get scores from Gemini data
            $atsScore = $geminiAnalysis['ats_compatibility_score'] ?? 70;
            $overallScore = $geminiAnalysis['overall_score'] ?? 70;

            // Calculate derived scores
            $skillsScore = $this->calculateSkillsScore($skills);
            $completenessScore = $this->calculateCompletenessScore($missingSections);

            // Store REAL analysis from Gemini
            CVAnalysis::create([
                'cv_id' => $cv->id,
                'skills' => $skills,
                'missing_sections' => $missingSections,
                'suggestions' => $suggestions,
                'skills_score' => $skillsScore,
                'completeness_score' => $completenessScore,
                'ats_score' => $atsScore,
                'score' => round($overallScore),
            ]);

            $cv->update(['status' => 'completed']);

            Log::info('CV uploaded and analyzed successfully', [
                'cv_id' => $cv->id,
                'overall_score' => $overallScore,
            ]);

            return response()->json([
                'message' => 'CV uploaded and analyzed successfully',
                'cv' => $cv->fresh('analysis'),
            ], 201);

        } catch (\Exception $e) {
            // Delete the uploaded file on exception
            if (Storage::disk('local')->exists($path)) {
                Storage::disk('local')->delete($path);
            }

            Log::error('CV upload exception', [
                'filename' => $file->getClientOriginalName(),
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'error' => 'CV upload failed',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    public function storeAnalysis(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'cv_id' => 'required|exists:cvs,id',
            'skills' => 'nullable|array',
            'missing_sections' => 'nullable|array',
            'suggestions' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $cv = CV::findOrFail($request->cv_id);

        // Calculate scores
        $skillsScore = $this->calculateSkillsScore($request->skills ?? []);
        $completenessScore = $this->calculateCompletenessScore($request->missing_sections ?? []);
        $atsScore = $request->ats_score ?? 70; // Default ATS score
        $overallScore = ($skillsScore + $completenessScore + $atsScore) / 3;

        $analysis = CVAnalysis::create([
            'cv_id' => $cv->id,
            'skills' => $request->skills,
            'missing_sections' => $request->missing_sections,
            'suggestions' => $request->suggestions,
            'skills_score' => $skillsScore,
            'completeness_score' => $completenessScore,
            'ats_score' => $atsScore,
            'score' => round($overallScore),
        ]);

        $cv->update(['status' => 'completed']);

        return response()->json([
            'message' => 'Analysis stored successfully',
            'analysis' => $analysis,
        ], 201);
    }

    public function getResults($id)
    {
        $cv = CV::with('analysis')->findOrFail($id);

        if ($cv->user_id !== auth()->id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        return response()->json([
            'cv' => $cv,
            'analysis' => $cv->analysis,
        ]);
    }

    public function getScore($id)
    {
        $cv = CV::with('analysis')->findOrFail($id);

        if ($cv->user_id !== auth()->id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $analysis = $cv->analysis;

        return response()->json([
            'overall_score' => $analysis->score,
            'skills_score' => $analysis->skills_score,
            'completeness_score' => $analysis->completeness_score,
            'ats_score' => $analysis->ats_score,
        ]);
    }

    public function calculateScore($id)
    {
        $cv = CV::with('analysis')->findOrFail($id);

        if ($cv->user_id !== auth()->id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $analysis = $cv->analysis;

        if (!$analysis) {
            return response()->json(['error' => 'No analysis found'], 404);
        }

        // Recalculate scores
        $skillsScore = $this->calculateSkillsScore($analysis->skills ?? []);
        $completenessScore = $this->calculateCompletenessScore($analysis->missing_sections ?? []);
        $atsScore = $analysis->ats_score;
        $overallScore = ($skillsScore + $completenessScore + $atsScore) / 3;

        $analysis->update([
            'skills_score' => $skillsScore,
            'completeness_score' => $completenessScore,
            'score' => round($overallScore),
        ]);

        return response()->json([
            'message' => 'Score recalculated',
            'analysis' => $analysis,
        ]);
    }

    public function getSuggestions($id)
    {
        $cv = CV::with('analysis')->findOrFail($id);

        if ($cv->user_id !== auth()->id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        return response()->json([
            'suggestions' => $cv->analysis->suggestions ?? [],
        ]);
    }

    public function updateSuggestions(Request $request, $id)
    {
        $cv = CV::with('analysis')->findOrFail($id);

        if ($cv->user_id !== auth()->id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $validator = Validator::make($request->all(), [
            'suggestions' => 'required|array',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $cv->analysis->update([
            'suggestions' => $request->suggestions,
        ]);

        return response()->json([
            'message' => 'Suggestions updated successfully',
            'suggestions' => $cv->analysis->suggestions,
        ]);
    }

    public function history()
    {
        $cvs = CV::where('user_id', auth()->id())
            ->with('analysis')
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($cv) {
                return [
                    'id' => $cv->id,
                    'file_name' => $cv->original_name,
                    'filename' => $cv->original_name ?? $cv->filename,
                    'uploaded_at' => $cv->created_at,
                    'created_at' => $cv->created_at,
                    'status' => $cv->status,
                    'ats_score' => $cv->analysis ? $cv->analysis->ats_score : null,
                    'overall_score' => $cv->analysis ? $cv->analysis->overall_score : null,
                    'score' => $cv->analysis ? $cv->analysis->score : 0,
                ];
            });

        return response()->json([
            'cvs' => $cvs,
            'total' => $cvs->count(),
        ]);
    }

    public function exportPDF($id)
    {
        $cv = CV::with('analysis')->findOrFail($id);

        if ($cv->user_id !== auth()->id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        // This would integrate with a PDF generation library
        // For now, return a success response
        return response()->json([
            'message' => 'PDF export functionality would generate optimized CV here',
            'cv_id' => $cv->id,
            'filename' => 'optimized_' . $cv->original_name,
        ]);
    }

    public function delete($id)
    {
        $cv = CV::findOrFail($id);

        if ($cv->user_id !== auth()->id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        // Delete the file from storage
        if (Storage::disk('local')->exists($cv->file_path)) {
            Storage::disk('local')->delete($cv->file_path);
        }

        // Delete the CV record (cascade will delete analysis)
        $cv->delete();

        return response()->json([
            'message' => 'CV deleted successfully',
        ], 200);
    }

    private function calculateSkillsScore(array $skills): int
    {
        // Simple scoring: more skills = higher score, max 100
        $count = count($skills);
        return min(100, $count * 10);
    }

    private function calculateCompletenessScore(array $missingSections): int
    {
        // Score based on missing sections: fewer missing = higher score
        $criticalSections = ['experience', 'education', 'skills', 'contact'];
        $missingCount = count($missingSections);
        
        if ($missingCount === 0) {
            return 100;
        }
        
        return max(0, 100 - ($missingCount * 20));
    }
}
