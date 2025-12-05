from flask import Flask, request, jsonify
import os
import json
import logging
from dotenv import load_dotenv
import google.generativeai as genai
from cv_parser import CVParser
from keyword_extractor import KeywordExtractor
from section_detector import SectionDetector
from ats_analyzer import ATSAnalyzer
from suggestion_generator import SuggestionGenerator

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Configure maximum file size (10MB)
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024

# Configure Gemini API
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY not found in environment variables")

genai.configure(api_key=GEMINI_API_KEY)

# Initialize Gemini model
model = genai.GenerativeModel('gemini-2.0-flash')

# Supported file formats
SUPPORTED_FORMATS = {'pdf', 'doc', 'docx'}

def validate_file_format(filename):
    """Validate that the file has a supported format"""
    if not filename:
        return False
    ext = filename.rsplit('.', 1)[-1].lower() if '.' in filename else ''
    return ext in SUPPORTED_FORMATS

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
    """
    Analyze CV using Gemini API.
    
    Accepts file uploads from Laravel/Flutter and returns structured CV analysis.
    Validates if the document is actually a CV before analysis.
    
    Returns:
        JSON response with analysis results or error message
    """
    try:
        # Check if file is in request
        if 'file' not in request.files:
            logger.warning("No file in request")
            return jsonify({
                'success': False,
                'error': 'No file provided'
            }), 400
        
        file = request.files['file']
        
        if file.filename == '':
            logger.warning("Empty filename")
            return jsonify({
                'success': False,
                'error': 'No file selected'
            }), 400
        
        # Validate file format
        if not validate_file_format(file.filename):
            logger.warning(f"Unsupported file format: {file.filename}")
            return jsonify({
                'success': False,
                'error': f'Unsupported file format. Please upload PDF or DOCX files.'
            }), 400
        
        # Parse CV to extract text
        parser = CVParser()
        try:
            cv_text = parser.extract_text(file)
        except ValueError as e:
            logger.error(f"Failed to extract text: {str(e)}")
            return jsonify({
                'success': False,
                'error': str(e)
            }), 400
        
        if not cv_text or len(cv_text.strip()) < 50:
            logger.warning("Not enough text extracted from CV")
            return jsonify({
                'success': False,
                'error': 'Could not extract enough text from the document. The file may be empty or contain only images.'
            }), 400
        
        logger.info(f"Extracted {len(cv_text)} characters from CV")
        
        # Truncate cv_text to prevent exceeding API limits (max 15000 chars for analysis)
        max_cv_length = 15000
        if len(cv_text) > max_cv_length:
            cv_text_for_analysis = cv_text[:max_cv_length] + "\n... [truncated due to length]"
            logger.info(f"CV text truncated from {len(cv_text)} to {max_cv_length} characters")
        else:
            cv_text_for_analysis = cv_text
        
        # Create enhanced prompt for CV validation and analysis
        prompt = f"""
You are an expert CV/Resume analyst. Analyze the following document and determine if it is a valid CV/Resume.

DOCUMENT CONTENT:
{cv_text_for_analysis}

STEP 1 - VALIDATION:
First, determine if this document is actually a CV/Resume. A valid CV should contain at least 3 of these sections:
- Contact Information (name, email, phone, address)
- Work Experience / Professional Experience
- Education / Academic Background
- Skills / Technical Skills / Competencies
- Professional Summary / Objective / Profile

If the document does NOT appear to be a CV/Resume (e.g., it's a random document, article, letter, or contains mostly irrelevant content), respond with ONLY this JSON:
{{
    "is_valid_cv": false,
    "error": "Your document does not look like a CV",
    "details": "Missing critical sections like experience, education, or contact information. Please upload a proper CV/Resume document."
}}

STEP 2 - ANALYSIS (only if it's a valid CV):
If it IS a valid CV, analyze it thoroughly and provide this JSON structure:

{{
    "is_valid_cv": true,
    "sections_found": ["contact", "experience", "education", "skills", "summary", "certifications", "interests", "projects"],
    "missing_sections": ["list of important sections not found"],
    "extracted_sections": {{
        "contact": {{
            "name": "extracted name or null",
            "email": "extracted email or null",
            "phone": "extracted phone or null",
            "location": "extracted location or null",
            "linkedin": "extracted linkedin or null"
        }},
        "background": "Professional summary/objective text if found, or null",
        "experience": [
            {{
                "title": "job title",
                "company": "company name",
                "duration": "time period",
                "description": "key responsibilities and achievements"
            }}
        ],
        "education": [
            {{
                "degree": "degree name",
                "institution": "school/university name",
                "year": "graduation year or period",
                "details": "additional details if any"
            }}
        ],
        "skills": ["skill1", "skill2", "skill3"],
        "certifications": ["certification1", "certification2"],
        "interests": "interests/hobbies text if found, or null"
    }},
    "overall_score": 85,
    "ats_compatibility_score": 75,
    "strengths": [
        "specific strength 1",
        "specific strength 2",
        "specific strength 3"
    ],
    "improvements": [
        {{
            "section": "section name",
            "issue": "what's wrong or missing",
            "suggestion": "specific actionable advice",
            "priority": "high/medium/low"
        }}
    ],
    "formatting_issues": ["list of formatting problems if any"],
    "recommended_keywords": ["relevant keyword 1", "relevant keyword 2"]
}}

SCORING GUIDELINES:
- Overall Score (0-100): Based on completeness, clarity, and professionalism
- ATS Compatibility Score (0-100): Based on formatting, keyword usage, and structure

Return ONLY valid JSON, no markdown formatting or code blocks.
"""
        
        # Call Gemini API
        logger.info("Calling Gemini API for CV analysis")
        response = model.generate_content(prompt)
        result_text = response.text
        
        # Clean up response - remove markdown code blocks if present
        if "```json" in result_text:
            result_text = result_text.split("```json")[1].split("```")[0].strip()
        elif "```" in result_text:
            result_text = result_text.split("```")[1].split("```")[0].strip()
        
        # Parse JSON response
        try:
            analysis_data = json.loads(result_text)
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse Gemini response: {str(e)}")
            logger.error(f"Raw response: {result_text[:500]}")
            return jsonify({
                'success': False,
                'error': 'Failed to parse analysis response',
                'details': 'The AI analysis could not be processed. Please try again.'
            }), 500
        
        # Check if document validation failed
        if not analysis_data.get('is_valid_cv', True):
            logger.warning("Document failed CV validation")
            return jsonify({
                'success': False,
                'error': analysis_data.get('error', 'Your document does not look like a CV'),
                'details': analysis_data.get('details', 'Missing critical sections like experience, education, or contact information')
            }), 400
        
        # Ensure required fields are present in analysis
        if 'sections_found' not in analysis_data:
            analysis_data['sections_found'] = []
        if 'missing_sections' not in analysis_data:
            analysis_data['missing_sections'] = []
        if 'overall_score' not in analysis_data:
            analysis_data['overall_score'] = 0
        if 'ats_compatibility_score' not in analysis_data:
            analysis_data['ats_compatibility_score'] = 0
        
        logger.info(f"CV analysis complete. Score: {analysis_data.get('overall_score', 0)}")
        
        return jsonify({
            'success': True,
            'analysis': analysis_data,
            'cv_length': len(cv_text),
            'cv_preview': cv_text[:200] + '...' if len(cv_text) > 200 else cv_text
        })
        
    except Exception as e:
        logger.exception(f"Error analyzing CV: {str(e)}")
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


@app.route('/match-job', methods=['POST'])
def match_job():
    """
    Compare CV against job description using Gemini AI.
    
    Expects:
    - file: CV file (PDF/DOCX)
    - job_description: Text of job posting
    
    Returns:
    - match_score: 0-100
    - match_verdict: strong/moderate/weak
    - matching_skills: []
    - missing_skills: []
    - improvement_suggestions: []
    - strengths: []
    """
    try:
        # Check if file is in request
        if 'file' not in request.files:
            logger.warning("No file in request for job match")
            return jsonify({
                'success': False,
                'error': 'No CV file provided'
            }), 400
        
        file = request.files['file']
        
        if file.filename == '':
            logger.warning("Empty filename for job match")
            return jsonify({
                'success': False,
                'error': 'No file selected'
            }), 400
        
        # Validate file format
        if not validate_file_format(file.filename):
            logger.warning(f"Unsupported file format: {file.filename}")
            return jsonify({
                'success': False,
                'error': 'Unsupported file format. Please upload PDF or DOCX files.'
            }), 400
        
        # Get job description
        job_description = request.form.get('job_description', '')
        
        if not job_description or len(job_description.strip()) < 50:
            logger.warning("Job description too short or missing")
            return jsonify({
                'success': False,
                'error': 'Job description must be at least 50 characters.'
            }), 400
        
        # Parse CV to extract text
        parser = CVParser()
        try:
            cv_text = parser.extract_text(file)
        except ValueError as e:
            logger.error(f"Failed to extract text from CV: {str(e)}")
            return jsonify({
                'success': False,
                'error': str(e)
            }), 400
        
        if not cv_text or len(cv_text.strip()) < 50:
            logger.warning("Not enough text extracted from CV")
            return jsonify({
                'success': False,
                'error': 'Could not extract enough text from the CV.'
            }), 400
        
        logger.info(f"Extracted {len(cv_text)} characters from CV for job matching")
        
        # Truncate texts to prevent exceeding API limits
        max_cv_length = 12000
        max_jd_length = 5000
        
        if len(cv_text) > max_cv_length:
            cv_text = cv_text[:max_cv_length] + "\n... [truncated]"
            logger.info(f"CV text truncated to {max_cv_length} characters")
        
        if len(job_description) > max_jd_length:
            job_description = job_description[:max_jd_length] + "\n... [truncated]"
            logger.info(f"Job description truncated to {max_jd_length} characters")
        
        # Create prompt for job matching
        prompt = f"""
You are an expert career advisor and ATS specialist. Compare this CV against the job description.

JOB DESCRIPTION:
{job_description}

CV CONTENT:
{cv_text}

Provide analysis in this EXACT JSON format:
{{
    "match_score": 85,
    "match_verdict": "strong",
    "matching_skills": ["skill1", "skill2"],
    "missing_skills": ["skill3", "skill4"],
    "improvement_suggestions": [
        "Add project showcasing skill3",
        "Highlight experience with skill4"
    ],
    "strengths": [
        "Strong background in X",
        "Relevant experience in Y"
    ]
}}

Match Verdict Rules:
- strong: 80-100% match
- moderate: 60-79% match  
- weak: 0-59% match

Important Guidelines:
1. Be specific about which skills match and which are missing
2. Provide actionable improvement suggestions
3. List real strengths from the CV that align with the job
4. Score should realistically reflect the match quality
5. Return ONLY valid JSON, no markdown or additional text
"""
        
        # Call Gemini API
        logger.info("Calling Gemini API for job match analysis")
        response = model.generate_content(prompt)
        result_text = response.text
        
        # Clean up response - remove markdown code blocks if present
        if "```json" in result_text:
            result_text = result_text.split("```json")[1].split("```")[0].strip()
        elif "```" in result_text:
            result_text = result_text.split("```")[1].split("```")[0].strip()
        
        # Parse JSON response
        try:
            analysis_data = json.loads(result_text)
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse Gemini response: {str(e)}")
            logger.error(f"Raw response: {result_text[:500]}")
            return jsonify({
                'success': False,
                'error': 'Failed to parse analysis response',
                'details': 'The AI analysis could not be processed. Please try again.'
            }), 500
        
        # Validate and normalize response
        match_score = analysis_data.get('match_score', 0)
        if not isinstance(match_score, int):
            try:
                match_score = int(match_score)
            except (ValueError, TypeError):
                match_score = 0
        match_score = max(0, min(100, match_score))
        
        # Determine verdict based on score if not provided or invalid
        match_verdict = analysis_data.get('match_verdict', '')
        if match_verdict not in ['strong', 'moderate', 'weak']:
            if match_score >= 80:
                match_verdict = 'strong'
            elif match_score >= 60:
                match_verdict = 'moderate'
            else:
                match_verdict = 'weak'
        
        # Ensure arrays exist
        matching_skills = analysis_data.get('matching_skills', [])
        if not isinstance(matching_skills, list):
            matching_skills = []
        
        missing_skills = analysis_data.get('missing_skills', [])
        if not isinstance(missing_skills, list):
            missing_skills = []
        
        improvement_suggestions = analysis_data.get('improvement_suggestions', [])
        if not isinstance(improvement_suggestions, list):
            improvement_suggestions = []
        
        strengths = analysis_data.get('strengths', [])
        if not isinstance(strengths, list):
            strengths = []
        
        logger.info(f"Job match analysis complete. Score: {match_score}, Verdict: {match_verdict}")
        
        return jsonify({
            'success': True,
            'analysis': {
                'match_score': match_score,
                'match_verdict': match_verdict,
                'matching_skills': matching_skills,
                'missing_skills': missing_skills,
                'improvement_suggestions': improvement_suggestions,
                'strengths': strengths
            }
        })
        
    except Exception as e:
        logger.exception(f"Error in job match analysis: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e),
            'error_type': type(e).__name__
        }), 500

if __name__ == '__main__':
    # Run the Flask app
    app.run(host='0.0.0.0', port=5000, debug=True)