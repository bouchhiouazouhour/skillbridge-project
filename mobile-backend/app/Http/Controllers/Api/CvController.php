<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Analysis;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Services\CvAnalyzer;
use Smalot\PdfParser\Parser as PdfParser;

class CvController extends Controller
{
    public function analyze(Request $request)
    {
        $validated = $request->validate([
            'file' => 'required|file|max:5120|mimes:txt,pdf,doc,docx', // 5MB
        ]);

        $file = $validated['file'];
        $path = $file->store('cv_uploads'); // local disk, storage/app/cv_uploads

        // Extract text from supported formats (txt, pdf, docx). Legacy .doc is not parsed.
        $text = $this->extractText($file->getRealPath(), strtolower($file->getClientOriginalExtension()));

        // Very simple heuristics for demo: check presence of sections/keywords
        $sections = [
            'Experience', 'Education', 'Skills', 'Certifications', 'Languages'
        ];
        $kw = [
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
            $words = $kw[$sec] ?? [];
            $hits = 0;
            foreach ($words as $w) {
                if ($w !== '' && str_contains($lower, $w)) {
                    $hits++;
                }
            }
            $score = min(1.0, $hits / max(1, count($words)));
            $subScores[$sec] = round($score, 2);
            if ($score < 0.3) {
                $missing[] = $sec;
            }
        }

        $suggestions = [];
        foreach ($missing as $m) {
            $suggestions[] = "Consider adding or improving your $m section.";
        }

        // Add lightweight NLP analysis
        $nlp = (new CvAnalyzer())->analyze($text);

        $analysis = Analysis::create([
            'user_id' => $request->user()->id,
            'original_filename' => $file->getClientOriginalName(),
            'mime' => $file->getClientMimeType(),
            'size' => $file->getSize(),
            'sub_scores' => array_merge($subScores, [
                'Readability' => $nlp['readability'],
            ]),
            'suggestions' => array_values(array_merge(
                $suggestions,
                $nlp['warnings']
            )),
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $analysis->id,
                'sub_scores' => $analysis->sub_scores,
                'suggestions' => $analysis->suggestions,
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
     * Extract basic text content from a CV file.
     * Supports: txt, pdf (via smalot/pdfparser), docx (via ZipArchive document.xml).
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
                        // Replace paragraph tags with newlines then strip remaining tags
                        $xml = preg_replace('/<w:p[^>]*>/', "\n", $xml) ?? '';
                        $text = strip_tags($xml);
                        return trim(html_entity_decode($text, ENT_QUOTES | ENT_XML1));
                    }
                }
                return '';
            }
        } catch (\Throwable $e) {
            // Fallback to empty text on parse errors
            return '';
        }
        return '';
    }
}
