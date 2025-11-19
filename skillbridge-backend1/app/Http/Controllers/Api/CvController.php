<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\CvAnalyzer;
use Smalot\PdfParser\Parser as PdfParser;

class CvController extends Controller
{
    /**
     * Analyze uploaded CV and return heuristic scores and suggestions.
     * Accepts: multipart/form-data with field name "file".
     * Supported types: txt, pdf, docx (legacy .doc not supported).
     */
    public function analyze(Request $request)
    {
        $validated = $request->validate([
            'file' => 'required|file|max:5120|mimes:txt,pdf,docx', // 5MB
        ]);

        $file = $validated['file'];

        // Extract text content by file type
        $ext = strtolower($file->getClientOriginalExtension());
        $text = $this->extractText($file->getRealPath(), $ext);

        // Heuristic section checks
        $sections = [
            'Experience', 'Education', 'Skills', 'Certifications', 'Languages'
        ];
        $keywords = [
            'Experience' => ['experience', 'worked', 'responsible', 'project'],
            'Education' => ['bachelor', 'master', 'university', 'college'],
            'Skills' => ['skills', 'stack', 'tools', 'technologies'],
            'Certifications' => ['certified', 'certificate', 'certification'],
            'Languages' => ['english', 'arabic', 'french', 'language'],
        ];

        $lower = mb_strtolower($text);
        $subScores = [];
        $missing = [];
        foreach ($sections as $sec) {
            $hits = 0;
            foreach (($keywords[$sec] ?? []) as $w) {
                if ($w !== '' && str_contains($lower, $w)) {
                    $hits++;
                }
            }
            $score = min(1.0, $hits / max(1, count($keywords[$sec] ?? [])));
            $subScores[$sec] = round($score, 2);
            if ($score < 0.3) $missing[] = $sec;
        }

        $suggestions = [];
        foreach ($missing as $m) {
            $suggestions[] = "Consider adding or improving your $m section.";
        }

        // Lightweight NLP
        $nlp = (new CvAnalyzer())->analyze($text);

        return response()->json([
            'success' => true,
            'data' => [
                'sub_scores' => array_merge($subScores, [
                    'Readability' => $nlp['readability'],
                ]),
                'suggestions' => array_values($suggestions + $nlp['warnings']),
                'nlp' => [
                    'word_count' => $nlp['word_count'],
                    'sentence_count' => $nlp['sentence_count'],
                    'readability' => $nlp['readability'],
                    'top_keywords' => $nlp['top_keywords'],
                ],
            ],
        ], 201);
    }

    /**
     * Extract text from txt/pdf/docx files.
     */
    protected function extractText(string $path, string $ext): string
    {
        try {
            if ($ext === 'txt') {
                return (string) file_get_contents($path);
            }
            if ($ext === 'pdf') {
                $parser = new PdfParser();
                $pdf = $parser->parseFile($path);
                return trim($pdf->getText());
            }
            if ($ext === 'docx') {
                if (class_exists('ZipArchive')) {
                    $zip = new \ZipArchive();
                    if ($zip->open($path) === true) {
                        $xml = $zip->getFromName('word/document.xml') ?: '';
                        $zip->close();
                        $xml = preg_replace('/<w:p[^>]*>/', "\n", $xml) ?? '';
                        $text = strip_tags($xml);
                        return trim(html_entity_decode($text, ENT_QUOTES | ENT_XML1));
                    }
                }
                return '';
            }
        } catch (\Throwable $e) {
            return '';
        }
        return '';
    }
}
