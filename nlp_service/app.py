from flask import Flask, request, jsonify
import os
from dotenv import load_dotenv
import google.generativeai as genai
from cv_parser import CVParser
from keyword_extractor import KeywordExtractor
from section_detector import SectionDetector
from ats_analyzer import ATSAnalyzer
from suggestion_generator import SuggestionGenerator

# Load environment variables
load_dotenv()

app = Flask(__name__)

# Configure Gemini API
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY not found in environment variables")

genai.configure(api_key=GEMINI_API_KEY)

# Initialize Gemini model
model = genai.GenerativeModel('gemini-2.5-flash')

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'CV Analyzer NLP Service',
        'gemini_configured': GEMINI_API_KEY is not None
    })

@app.route('/test-gemini', methods=['GET'])
def test_gemini():
    """Test Gemini API connection"""
    try:
        response = model.generate_content("explain the theory of relativity in simple terms.")
        return jsonify({
            'success': True,
            'message': response.text
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/analyze-cv', methods=['POST'])
def analyze_cv():
    """Analyze CV using Gemini API"""
    try:
        # Check if file is in request
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        # Parse CV to extract text
        parser = CVParser()
        cv_text = parser.extract_text(file)
        
        if not cv_text or len(cv_text.strip()) < 50:
            return jsonify({'error': 'Could not extract enough text from CV'}), 400
        
        # Create detailed prompt for Gemini
        prompt = f"""
Analyze this CV/Resume thoroughly and provide a detailed assessment in JSON format.

CV Content:
{cv_text}

Provide your analysis in this EXACT JSON structure (return ONLY valid JSON, no markdown):
{{
    "missing_sections": ["list of missing important sections"],
    "present_sections": ["list of sections found in CV"],
    "overall_score": 85,
    "strengths": [
        "specific strength 1",
        "specific strength 2",
        "specific strength 3"
    ],
    "improvements": [
        {{
            "section": "section name",
            "issue": "what's wrong",
            "suggestion": "how to fix it",
            "priority": "high"
        }}
    ],
    "formatting_issues": ["list of formatting problems"],
    "ats_compatibility_score": 75,
    "ats_issues": ["specific ATS compatibility issues"],
    "recommended_keywords": ["keyword1", "keyword2"]
}}

Important sections to check for:
- Contact Information (name, email, phone, location)
- Professional Summary or Objective
- Work Experience with dates and descriptions
- Education with dates and degrees
- Skills (technical and soft skills)
- Certifications (if applicable)
- Projects or Portfolio (if applicable)

Be specific and actionable. Return ONLY the JSON object.
"""
        
        # Call Gemini API
        response = model.generate_content(prompt)
        result_text = response.text
        
        # Clean up response - remove markdown code blocks
        import json
        if "```json" in result_text:
            result_text = result_text.split("```json")[1].split("```")[0].strip()
        elif "```" in result_text:
            result_text = result_text.split("```")[1].split("```")[0].strip()
        
        # Parse JSON response
        try:
            analysis_data = json.loads(result_text)
        except json.JSONDecodeError:
            # If JSON parsing fails, return raw text
            return jsonify({
                'success': False,
                'error': 'Failed to parse Gemini response as JSON',
                'raw_response': result_text
            }), 500
        
        return jsonify({
            'success': True,
            'analysis': analysis_data,
            'cv_length': len(cv_text),
            'cv_preview': cv_text[:200] + '...' if len(cv_text) > 200 else cv_text
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'error_type': type(e).__name__
        }), 500

@app.route('/generate-improvements', methods=['POST'])
def generate_improvements():
    """Generate improved CV content based on suggestions"""
    try:
        data = request.get_json()
        
        if not data or 'cv_text' not in data or 'improvements' not in data:
            return jsonify({'error': 'Missing cv_text or improvements in request'}), 400
        
        cv_text = data['cv_text']
        improvements = data['improvements']
        
        prompt = f"""
You are a professional CV writer. Given this CV and improvement suggestions, rewrite the CV to be better.

Original CV:
{cv_text}

Improvements to apply:
{improvements}

Instructions:
1. Rewrite weak sections to be more impactful
2. Add any critical missing sections with professional content
3. Use action verbs and quantifiable achievements
4. Ensure ATS-friendly formatting
5. Keep it professional and concise

Return the improved CV text in a clean, well-structured format.
"""
        
        response = model.generate_content(prompt)
        
        return jsonify({
            'success': True,
            'improved_content': response.text
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    # Run the Flask app
    app.run(host='0.0.0.0', port=5000, debug=True)