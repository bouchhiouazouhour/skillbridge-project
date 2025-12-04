from typing import List, Dict, Any
import re

class SuggestionGenerator:
    """Generate CV improvement suggestions"""
    
    def __init__(self):
        self.action_verbs = [
            'achieved', 'improved', 'increased', 'developed', 'created',
            'managed', 'led', 'designed', 'implemented', 'delivered',
            'coordinated', 'executed', 'optimized', 'streamlined', 'established'
        ]
    
    def generate(self, text: str, sections: Dict[str, bool], keywords: List[str]) -> List[Dict[str, Any]]:
        """Generate improvement suggestions"""
        suggestions = []
        
        # Check for missing sections
        suggestions.extend(self._suggest_missing_sections(sections))
        
        # Check for weak action verbs
        suggestions.extend(self._suggest_better_verbs(text))
        
        # Check for quantifiable achievements
        suggestions.extend(self._suggest_metrics(text))
        
        # Check for skills section
        suggestions.extend(self._suggest_skills_improvement(text, keywords))
        
        # Check for length and formatting
        suggestions.extend(self._suggest_formatting(text))
        
        # Prioritize by impact
        return self._prioritize_suggestions(suggestions)
    
    def _suggest_missing_sections(self, sections: Dict[str, bool]) -> List[Dict[str, Any]]:
        """Suggest adding missing sections"""
        suggestions = []
        
        required = ['contact', 'experience', 'education', 'skills']
        for section in required:
            if section in sections and not sections[section]:
                suggestions.append({
                    'type': 'missing_section',
                    'priority': 'high',
                    'section': section,
                    'message': f'Add a {section.title()} section to your CV',
                    'example': self._get_section_example(section)
                })
        
        return suggestions
    
    def _suggest_better_verbs(self, text: str) -> List[Dict[str, Any]]:
        """Suggest replacing weak verbs with stronger action verbs"""
        suggestions = []
        
        weak_verbs = {
            'did': 'executed',
            'made': 'created',
            'worked on': 'developed',
            'was responsible for': 'managed',
            'helped': 'assisted',
            'got': 'achieved'
        }
        
        text_lower = text.lower()
        for weak, strong in weak_verbs.items():
            if weak in text_lower:
                suggestions.append({
                    'type': 'verb_improvement',
                    'priority': 'medium',
                    'message': f'Replace "{weak}" with stronger verb like "{strong}"',
                    'example': f'Instead of "{weak} the project", use "{strong} the project"'
                })
        
        return suggestions
    
    def _suggest_metrics(self, text: str) -> List[Dict[str, Any]]:
        """Suggest adding quantifiable metrics"""
        suggestions = []
        
        # Check if there are numbers in experience section
        lines = text.split('\n')
        lines_with_numbers = [line for line in lines if any(char.isdigit() for char in line)]
        
        if len(lines_with_numbers) < 3:
            suggestions.append({
                'type': 'metrics',
                'priority': 'high',
                'message': 'Add quantifiable achievements to demonstrate impact',
                'example': 'Instead of "Improved system performance", use "Improved system performance by 40%, reducing load time from 5s to 3s"'
            })
        
        return suggestions
    
    def _suggest_skills_improvement(self, text: str, keywords: List[str]) -> List[Dict[str, Any]]:
        """Suggest improving skills section"""
        suggestions = []
        
        if len(keywords) < 5:
            suggestions.append({
                'type': 'skills',
                'priority': 'high',
                'message': 'Add more relevant skills to your Skills section',
                'example': 'Include technical skills, tools, frameworks, and methodologies you have experience with'
            })
        
        # Check if skills are categorized
        if 'technical skills' not in text.lower() and 'programming languages' not in text.lower():
            suggestions.append({
                'type': 'skills_organization',
                'priority': 'medium',
                'message': 'Organize skills into categories',
                'example': 'Group skills: Programming Languages, Frameworks, Tools, Soft Skills'
            })
        
        return suggestions
    
    def _suggest_formatting(self, text: str) -> List[Dict[str, Any]]:
        """Suggest formatting improvements"""
        suggestions = []
        
        word_count = len(text.split())
        
        if word_count < 300:
            suggestions.append({
                'type': 'length',
                'priority': 'medium',
                'message': 'Expand your CV with more details',
                'example': 'Add more bullet points describing your responsibilities and achievements'
            })
        elif word_count > 2000:
            suggestions.append({
                'type': 'length',
                'priority': 'medium',
                'message': 'Condense your CV to 1-2 pages',
                'example': 'Remove older or less relevant experience; focus on recent achievements'
            })
        
        # Check for bullet points
        if not any(marker in text for marker in ['•', '-', '*']):
            suggestions.append({
                'type': 'formatting',
                'priority': 'low',
                'message': 'Use bullet points for better readability',
                'example': 'Format experience items as bullet points instead of paragraphs'
            })
        
        return suggestions
    
    def _get_section_example(self, section: str) -> str:
        """Get example for a section"""
        examples = {
            'contact': 'Name: John Doe\nEmail: john@example.com\nPhone: +1-234-567-8900',
            'experience': '• Software Engineer at Company (2020-2023)\n• Developed web applications using React and Node.js',
            'education': '• Bachelor of Science in Computer Science, University Name (2016-2020)',
            'skills': '• Programming: Python, JavaScript, Java\n• Frameworks: React, Django, Spring Boot'
        }
        return examples.get(section, '')
    
    def _prioritize_suggestions(self, suggestions: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Sort suggestions by priority"""
        priority_order = {'high': 0, 'medium': 1, 'low': 2}
        return sorted(suggestions, key=lambda x: priority_order.get(x.get('priority', 'low'), 2))
