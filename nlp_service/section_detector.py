from typing import Dict, List

class SectionDetector:
    """Detect CV sections and identify missing ones"""
    
    def __init__(self):
        self.required_sections = {
            'contact': ['contact', 'personal information', 'email', 'phone'],
            'summary': ['summary', 'objective', 'profile', 'about'],
            'experience': ['experience', 'work history', 'employment', 'work experience'],
            'education': ['education', 'academic', 'qualifications', 'degree'],
            'skills': ['skills', 'technical skills', 'competencies', 'expertise'],
        }
        
        self.optional_sections = {
            'certifications': ['certifications', 'certificates', 'licenses'],
            'projects': ['projects', 'portfolio'],
            'awards': ['awards', 'honors', 'achievements'],
            'publications': ['publications', 'papers', 'articles'],
            'languages': ['languages', 'language proficiency'],
            'references': ['references', 'referees']
        }
    
    def detect(self, text: str) -> Dict[str, bool]:
        """Detect which sections are present in the CV"""
        text_lower = text.lower()
        detected = {}
        
        # Check required sections
        for section_name, keywords in self.required_sections.items():
            detected[section_name] = any(keyword in text_lower for keyword in keywords)
        
        # Check optional sections
        for section_name, keywords in self.optional_sections.items():
            detected[section_name] = any(keyword in text_lower for keyword in keywords)
        
        return detected
    
    def find_missing(self, detected_sections: Dict[str, bool]) -> List[str]:
        """Find missing critical sections"""
        missing = []
        
        for section_name in self.required_sections.keys():
            if section_name in detected_sections and not detected_sections[section_name]:
                missing.append(section_name)
        
        return missing
    
    def score_section(self, section_name: str, content: str) -> int:
        """Score a section's quality (0-100)"""
        if not content:
            return 0
        
        score = 50  # Base score
        
        # Length-based scoring
        word_count = len(content.split())
        if word_count > 100:
            score += 20
        elif word_count > 50:
            score += 10
        
        # Check for bullet points (good formatting)
        if any(marker in content for marker in ['•', '-', '*']):
            score += 15
        
        # Check for numbers/metrics (quantified achievements)
        if any(char.isdigit() for char in content):
            score += 15
        
        return min(100, score)
