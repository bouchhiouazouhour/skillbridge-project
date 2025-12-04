<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class CVController extends Controller
{
    /**
     * Upload et analyse de CV
     */
    public function upload(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'cv' => 'required|file|mimes:pdf,doc,docx|max:5120', // Max 5MB
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $file = $request->file('cv');
            $filename = time() .  '_' . $file->getClientOriginalName();
            $path = $file->storeAs('cvs', $filename, 'public');

            // Créer l'entrée dans la base de données
            $cv = auth()->user()->cvs()->create([
                'filename' => $filename,
                'path' => $path,
                'status' => 'pending',
            ]);

            // Simuler l'analyse (vous pouvez intégrer une vraie API ici)
            $analysisResult = $this->analyzeCV($cv);

            return response()->json([
                'success' => true,
                'message' => 'CV uploaded successfully',
                'data' => [
                    'cv_id' => $cv->id,
                    'analysis' => $analysisResult,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Upload failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Analyse simulée du CV
     */
    private function analyzeCV($cv)
    {
        // TODO: Intégrer une vraie API d'analyse (NLP, ATS, etc.)
        return [
            'overall_score' => 85,
            'scores' => [
                'ats_compatibility' => 90,
                'content_quality' => 85,
                'formatting' => 80,
                'keywords_match' => 75,
            ],
            'recommendations' => [
                'Add more technical skills',
                'Improve work experience descriptions',
                'Include quantifiable achievements',
                'Add relevant certifications',
            ],
        ];
    }

    /**
     * Obtenir tous les CVs de l'utilisateur
     */
    public function index()
    {
        $cvs = auth()->user()->cvs()->latest()->get();

        return response()->json([
            'success' => true,
            'data' => $cvs
        ], 200);
    }

    /**
     * Obtenir les résultats d'analyse d'un CV
     */
    public function show($id)
    {
        $cv = auth()->user()->cvs()->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => [
                'cv' => $cv,
                'analysis' => $this->analyzeCV($cv),
            ]
        ], 200);
    }

    /**
     * Télécharger un CV
     */
    public function download($id)
    {
        $cv = auth()->user()->cvs()->findOrFail($id);
        
        return Storage::disk('public')->download($cv->path, $cv->filename);
    }
}