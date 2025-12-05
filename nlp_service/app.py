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
    Compare CV with job description using Gemini AI.
    
    Request JSON:
    {
        "cv_file_path": "path/to/cv.pdf",
        "job_description": "Full job posting text..."
    }
    
    Returns:
    {
        "success": true,
        "match_score": 75,
        "match_verdict": "moderate",
        "matching_skills": ["Python", "React", ...],
        "missing_skills": ["AWS", "Docker", ...],
        "improvement_suggestions": [...],
        "strengths": [...]
    }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'error': 'No JSON data provided'
            }), 400
        
        cv_file_path = data.get('cv_file_path')
        job_description = data.get('job_description')
        
        if not cv_file_path:
            return jsonify({
                'success': False,
                'error': 'CV file path is required'
            }), 400
        
        if not job_description:
            return jsonify({
                'success': False,
                'error': 'Job description is required'
            }), 400
        
        if len(job_description) < 100:
            return jsonify({
                'success': False,
                'error': 'Job description must be at least 100 characters'
            }), 400
        
        # Extract text from CV file
        parser = CVParser()
        try:
            cv_text = parser._extract_text(cv_file_path)
        except Exception as e:
            logger.error(f"Failed to extract text from CV: {str(e)}")
            return jsonify({
                'success': False,
                'error': f'Failed to read CV file: {str(e)}'
            }), 400
        
        if not cv_text or len(cv_text.strip()) < 50:
            return jsonify({
                'success': False,
                'error': 'Could not extract enough text from the CV file'
            }), 400
        
        logger.info(f"Job Match Analysis: Extracted {len(cv_text)} characters from CV")
        
        # Truncate texts to prevent exceeding API limits
        max_cv_length = 12000
        max_job_length = 5000
        
        if len(cv_text) > max_cv_length:
            cv_text = cv_text[:max_cv_length] + "\n... [truncated]"
        
        if len(job_description) > max_job_length:
            job_description = job_description[:max_job_length] + "\n... [truncated]"
        
        # Create comprehensive prompt for Gemini
        prompt = f"""
You are an expert recruiter and career advisor. Compare this CV with the job description and provide a detailed analysis.

JOB DESCRIPTION:
{job_description}

CANDIDATE'S CV:
{cv_text}

Provide your analysis in this EXACT JSON structure (return ONLY valid JSON, no markdown):
{{
    "match_score": 75,
    "match_verdict": "moderate",
    "matching_skills": ["list of skills candidate has that match job requirements"],
    "missing_skills": ["list of required skills candidate is missing"],
    "improvement_suggestions": [
        "Specific suggestion 1 on how to improve CV for this job",
        "Specific suggestion 2",
        "Specific suggestion 3"
    ],
    "strengths": [
        "Specific strength 1 that makes candidate suitable",
        "Specific strength 2",
        "Specific strength 3"
    ]
}}

Match Score Guidelines:
- 80-100: Strong fit, highly qualified - use "strong" verdict
- 60-79: Moderate fit, some gaps but decent match - use "moderate" verdict
- 0-59: Weak fit, significant skill gaps - use "weak" verdict

IMPORTANT:
- match_score must be an integer between 0 and 100
- match_verdict must be exactly one of: "strong", "moderate", or "weak"
- All arrays should contain strings only
- Be specific and actionable in suggestions
- Focus on skills, experience, and qualifications mentioned in the job description
- Return ONLY valid JSON, no markdown formatting or code blocks
"""
        
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
        
        # Validate and sanitize response
        match_score = analysis_data.get('match_score', 50)
        if not isinstance(match_score, (int, float)):
            match_score = 50
        match_score = max(0, min(100, int(match_score)))
        
        match_verdict = analysis_data.get('match_verdict', 'moderate')
        if match_verdict not in ['strong', 'moderate', 'weak']:
            if match_score >= 80:
                match_verdict = 'strong'
            elif match_score >= 60:
                match_verdict = 'moderate'
            else:
                match_verdict = 'weak'
        
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
        
        logger.info(f"Job Match Analysis complete. Score: {match_score}, Verdict: {match_verdict}")
        
        return jsonify({
            'success': True,
            'match_score': match_score,
            'match_verdict': match_verdict,
            'matching_skills': matching_skills,
            'missing_skills': missing_skills,
            'improvement_suggestions': improvement_suggestions,
            'strengths': strengths
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