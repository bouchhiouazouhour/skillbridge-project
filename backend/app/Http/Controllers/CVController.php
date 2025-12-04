<?php

namespace App\Http\Controllers;

use App\Models\CV;
use App\Models\CVAnalysis;
use Illuminate\Http\Request;
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

        $cv = CV::create([
            'user_id' => auth()->id(),
            'filename' => $filename,
            'file_path' => $path,
            'original_name' => $file->getClientOriginalName(),
            'status' => 'uploaded',
        ]);

        // Create mock analysis immediately
        $mockSkills = ['JavaScript', 'Python', 'React', 'Laravel', 'Flutter', 'SQL', 'Git', 'Docker'];
        $mockMissingSections = [];
        $mockSuggestions = [
            'Add more quantifiable achievements to your experience section',
            'Include relevant certifications to strengthen your profile',
            'Optimize keywords for ATS compatibility',
            'Add a professional summary at the top',
            'Include links to your portfolio or GitHub projects'
        ];

        $skillsScore = $this->calculateSkillsScore($mockSkills);
        $completenessScore = $this->calculateCompletenessScore($mockMissingSections);
        $atsScore = 85; // Mock ATS score
        $overallScore = ($skillsScore + $completenessScore + $atsScore) / 3;

        CVAnalysis::create([
            'cv_id' => $cv->id,
            'skills' => $mockSkills,
            'missing_sections' => $mockMissingSections,
            'suggestions' => $mockSuggestions,
            'skills_score' => $skillsScore,
            'completeness_score' => $completenessScore,
            'ats_score' => $atsScore,
            'score' => round($overallScore),
        ]);

        $cv->update(['status' => 'completed']);

        return response()->json([
            'message' => 'CV uploaded and analyzed successfully',
            'cv' => $cv->fresh('analysis'),
        ], 201);
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
