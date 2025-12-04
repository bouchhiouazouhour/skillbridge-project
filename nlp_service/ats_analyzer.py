from typing import Dict, Any
import re

class ATSAnalyzer:
    """Analyze ATS (Applicant Tracking System) readability"""
    
    def analyze(self, text: str) -> Dict[str, Any]:
        """Analyze text for ATS compatibility"""
        score = 100
        issues = []
        recommendations = []
        
        # Check for complex formatting
        if self._has_tables(text):
            score -= 15
            issues.append("Contains tables which may not be parsed correctly by ATS")
            recommendations.append("Convert tables to simple text format")
        
        # Check for graphics/images indicators
        if self._has_graphics_indicators(text):
            score -= 10
            issues.append("May contain graphics or images")
            recommendations.append("Remove graphics and images; use text only")
        
        # Check for standard section headers
        if not self._has_standard_headers(text):
            score -= 15
            issues.append("Missing standard section headers")
            recommendations.append("Use clear section headers: Experience, Education, Skills")
        
        # Check keyword density
        keyword_score = self._analyze_keyword_density(text)
        if keyword_score < 50:
            score -= 10
            issues.append("Low keyword density")
            recommendations.append("Include more industry-relevant keywords")
        
        # Check for proper formatting
        if not self._has_consistent_formatting(text):
            score -= 10
            issues.append("Inconsistent formatting detected")
            recommendations.append("Use consistent formatting throughout")
        
        # Check length
        word_count = len(text.split())
        if word_count < 200:
            score -= 15
            issues.append("CV is too short")
            recommendations.append("Expand your experience and skills sections")
        elif word_count > 2000:
            score -= 10
            issues.append("CV is too long")
            recommendations.append("Condense to 1-2 pages")
        
        return {
            'score': max(0, score),
            'issues': issues,
            'recommendations': recommendations,
            'keyword_density': keyword_score,
            'word_count': word_count
        }
    
    def _has_tables(self, text: str) -> bool:
        """Check if text might contain tables"""
        # Simple heuristic: multiple consecutive spaces or tabs
        return bool(re.search(r'  {3,}|\t{2,}', text))
    
    def _has_graphics_indicators(self, text: str) -> bool:
        """Check for graphics indicators"""
        graphics_keywords = ['[image]', '[graphic]', '[chart]', '[logo]']
        return any(keyword in text.lower() for keyword in graphics_keywords)
    
    def _has_standard_headers(self, text: str) -> bool:
        """Check for standard section headers"""
        text_lower = text.lower()
        required_headers = ['experience', 'education', 'skills']
        return all(header in text_lower for header in required_headers)
    
    def _analyze_keyword_density(self, text: str) -> int:
        """Analyze keyword density (0-100)"""
        text_lower = text.lower()
        
        # Common professional keywords
        keywords = [
            'managed', 'developed', 'created', 'implemented', 'designed',
            'led', 'coordinated', 'achieved', 'improved', 'increased',
            'reduced', 'analyzed', 'collaborated', 'delivered', 'executed'
        ]
        
        found = sum(1 for keyword in keywords if keyword in text_lower)
        return min(100, (found / len(keywords)) * 100)
    
    def _has_consistent_formatting(self, text: str) -> bool:
        """Check for consistent formatting"""
        lines = text.split('\n')
        
        # Check if dates are formatted consistently
        date_patterns = [
            r'\d{4}\s*-\s*\d{4}',
            r'\d{2}/\d{4}\s*-\s*\d{2}/\d{4}',
            r'[A-Za-z]+\s+\d{4}'
        ]
        
        date_formats_found = set()
        for line in lines:
            for pattern in date_patterns:
                if re.search(pattern, line):
                    date_formats_found.add(pattern)
        
        # If multiple date formats found, it's inconsistent
        return len(date_formats_found) <= 1
