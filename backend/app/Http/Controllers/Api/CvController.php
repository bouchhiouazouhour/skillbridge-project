<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Cv;
use Symfony\Component\Process\Process;
use Symfony\Component\Process\Exception\ProcessFailedException;

class CvController extends Controller
{
    public function uploadCv(Request $request)
    {
        $request->validate([
            'cv' => 'required|file|mimes:pdf,doc,docx|max:5120' // 5MB
        ]);

        $file = $request->file('cv');
        $path = $file->store('cvs', 'public'); // stocke dans storage/app/public/cvs
        $fullPath = storage_path('app/public/' . $path);

        // Appel du script Python (sécurisé)
        $python = env('PYTHON_PATH', 'python3');
        $script = base_path('nlp/analyze_cv.py'); // crée ce fichier (voir plus bas)

        $process = new Process([$python, $script, $fullPath]);
        $process->setTimeout(60); // 60s, adapter si besoin

        try {
            $process->mustRun();
            $output = $process->getOutput();
            $result = json_decode($output, true);
        } catch (ProcessFailedException $e) {
            // si erreur d'analyse -> renvoyer message et éventuellement supprimer le fichier
            return response()->json(['message' => 'Erreur d’analyse', 'error' => $e->getMessage()], 500);
        }

        // Sauvegarder l'enregistrement CV
        $cv = Cv::create([
            'user_id' => $request->user()->id,
            'chemin_fichier' => $path,
            'score' => $result['score'] ?? null,
        ]);

        return response()->json([
            'keywords' => $result['keywords'] ?? [],
            'missing_sections' => $result['missing_sections'] ?? [],
            'score' => $result['score'] ?? null,
            'cv' => $cv
        ]);
    }
}


class CvController extends Controller
{
    public function uploadCv(Request $request)
    {
        $request->validate([
            'cv' => 'required|file|mimes:pdf,doc,docx|max:5120' // 5MB
        ]);

        $file = $request->file('cv');
        $path = $file->store('cvs', 'public'); // stocke dans storage/app/public/cvs
        $fullPath = storage_path('app/public/' . $path);

        // Appel du script Python (sécurisé)
        $python = env('PYTHON_PATH', 'python3');
        $script = base_path('nlp/analyze_cv.py'); // crée ce fichier (voir plus bas)

        $process = new Process([$python, $script, $fullPath]);
        $process->setTimeout(60); // 60s, adapter si besoin

        try {
            $process->mustRun();
            $output = $process->getOutput();
            $result = json_decode($output, true);
        } catch (ProcessFailedException $e) {
            // si erreur d'analyse -> renvoyer message et éventuellement supprimer le fichier
            return response()->json(['message' => 'Erreur d’analyse', 'error' => $e->getMessage()], 500);
        }

        // Sauvegarder l'enregistrement CV
        $cv = Cv::create([
            'user_id' => $request->user()->id,
            'chemin_fichier' => $path,
            'score' => $result['score'] ?? null,
        ]);

        return response()->json([
            'keywords' => $result['keywords'] ?? [],
            'missing_sections' => $result['missing_sections'] ?? [],
            'score' => $result['score'] ?? null,
            'cv' => $cv
        ]);
    }
}
