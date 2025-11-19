<?php

namespace App\Services;

/**
 * Lightweight CV text analyzer (heuristic NLP) without external libs.
 * Provides readability score (Flesch-style approximation), word/sentence counts,
 * top keyword frequencies excluding common stop words, and basic section guidance.
 */
class CvAnalyzer
{
    /** @var array<string,bool> */
    protected array $stop = [];

    public function __construct()
    {
        $words = [
            'the','and','a','an','of','to','in','on','for','with','at','by','from','or','as','is','are','was','were','be','this','that','it','your','you','i','we','our'
        ];
        $this->stop = array_fill_keys($words, true);
    }

    /**
     * Analyze raw CV text.
     * @return array{word_count:int,sentence_count:int,readability:float,top_keywords:array<int,array{word:string,count:int}>,warnings:array<int,string>}
     */
    public function analyze(string $text): array
    {
        $clean = trim(preg_replace('/[\r\t]+/', ' ', $text) ?? '');
        $sentences = $this->splitSentences($clean);
        $sentenceCount = max(1, count($sentences));
        $tokens = $this->tokenize($clean);
        $wordCount = count($tokens);
        $syllables = 0;
        foreach ($tokens as $w) {
            $syllables += $this->estimateSyllables($w);
        }
        // Flesch Reading Ease approximation: 206.835 - 1.015*(W/S) - 84.6*(Sy/W)
        $readability = 206.835 - 1.015 * ($wordCount / $sentenceCount) - 84.6 * ($syllables / max(1, $wordCount));
        $readability = round($readability, 2);

        $freq = $this->frequency($tokens);
        arsort($freq);
        $top = [];
        foreach ($freq as $w => $c) {
            if (count($top) >= 10) break;
            $top[] = ['word' => $w, 'count' => $c];
        }

        $warnings = [];
        if ($readability < 40) {
            $warnings[] = 'Your CV text is quite complex; consider shorter sentences and simpler wording.';
        } elseif ($readability < 60) {
            $warnings[] = 'Readability could be improved; aim for clearer, more concise sentences.';
        }
        if ($wordCount < 150) {
            $warnings[] = 'CV appears brief; consider elaborating on experience and achievements.';
        }
        if ($wordCount > 1200) {
            $warnings[] = 'CV may be too long; consider condensing to the most impactful information.';
        }

        return [
            'word_count' => $wordCount,
            'sentence_count' => $sentenceCount,
            'readability' => $readability,
            'top_keywords' => $top,
            'warnings' => $warnings,
        ];
    }

    /** @return string[] */
    protected function splitSentences(string $text): array
    {
        $parts = preg_split('/(?<=[.!?])\s+/', $text) ?: [];
        return array_filter(array_map('trim', $parts), fn($s) => $s !== '');
    }

    /** @return string[] */
    protected function tokenize(string $text): array
    {
        $text = mb_strtolower($text);
        $text = preg_replace('/[^a-z0-9\s]/u', ' ', $text) ?? '';
        $raw = preg_split('/\s+/', $text) ?: [];
        $out = [];
        foreach ($raw as $t) {
            $t = trim($t);
            if ($t === '' || isset($this->stop[$t])) continue;
            $out[] = $t;
        }
        return $out;
    }

    protected function estimateSyllables(string $word): int
    {
        // Very rough heuristic: count vowel groups (a,e,i,o,u,y)
        $vowelGroups = preg_match_all('/[aeiouy]+/i', $word);
        return max(1, (int)$vowelGroups);
    }

    /** @param string[] $tokens */
    protected function frequency(array $tokens): array
    {
        $freq = [];
        foreach ($tokens as $t) {
            $freq[$t] = ($freq[$t] ?? 0) + 1;
        }
        return $freq;
    }
}
