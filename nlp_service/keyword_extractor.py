import re
from typing import List, Set

class KeywordExtractor:
    """Extract skills and keywords from CV text"""
    
    def __init__(self):
        # Common technical skills and keywords
        self.tech_skills = {
            'python', 'java', 'javascript', 'typescript', 'c++', 'c#', 'ruby', 'go', 'rust',
            'php', 'swift', 'kotlin', 'scala', 'r', 'matlab',
            'react', 'angular', 'vue', 'node.js', 'express', 'django', 'flask', 'spring',
            'laravel', 'rails', 'asp.net', 'flutter', 'react native',
            'docker', 'kubernetes', 'aws', 'azure', 'gcp', 'heroku', 'jenkins',
            'git', 'github', 'gitlab', 'bitbucket', 'ci/cd', 'devops',
            'mysql', 'postgresql', 'mongodb', 'redis', 'elasticsearch', 'cassandra',
            'sql', 'nosql', 'graphql', 'rest', 'api', 'microservices',
            'machine learning', 'deep learning', 'ai', 'nlp', 'computer vision',
            'tensorflow', 'pytorch', 'keras', 'scikit-learn', 'pandas', 'numpy',
            'html', 'css', 'sass', 'less', 'bootstrap', 'tailwind',
            'agile', 'scrum', 'kanban', 'jira', 'confluence',
            'linux', 'unix', 'windows', 'macos', 'bash', 'powershell',
            'testing', 'unit testing', 'integration testing', 'tdd', 'bdd',
            'security', 'oauth', 'jwt', 'ssl', 'encryption'
        }
        
        self.soft_skills = {
            'leadership', 'communication', 'teamwork', 'problem solving',
            'analytical', 'creative', 'adaptable', 'organized', 'detail-oriented',
            'time management', 'project management', 'critical thinking',
            'collaboration', 'mentoring', 'presentation', 'negotiation'
        }
    
    def extract(self, text: str) -> List[str]:
        """Extract skills and keywords from text"""
        text_lower = text.lower()
        found_skills = set()
        
        # Extract technical skills
        for skill in self.tech_skills:
            if skill in text_lower:
                found_skills.add(skill)
        
        # Extract soft skills
        for skill in self.soft_skills:
            if skill in text_lower:
                found_skills.add(skill)
        
        # Extract programming languages with version numbers
        prog_lang_pattern = r'\b(python|java|javascript|c\+\+|ruby|php|go)\s*[\d\.]*\b'
        matches = re.findall(prog_lang_pattern, text_lower)
        found_skills.update(matches)
        
        return sorted(list(found_skills))
