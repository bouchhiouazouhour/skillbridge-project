from flask import Flask, request, jsonify
import os
from cv_parser import CVParser
from keyword_extractor import KeywordExtractor
from section_detector import SectionDetector
from ats_analyzer import ATSAnalyzer
from suggestion_generator import SuggestionGenerator

app = Flask(__name__)

# Initialize services
cv_parser = CVParser()
keyword_extractor = KeywordExtractor()
section_detector = SectionDetector()
ats_analyzer = ATSAnalyzer()
suggestion_generator = SuggestionGenerator()

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy', 'service': 'NLP Service'})

@app.route('/parse', methods=['POST'])
def parse_cv():
    """Parse CV and extract structured data"""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    try:
        # Save file temporarily
        temp_path = f"/tmp/{file.filename}"
        file.save(temp_path)
        
        # Parse CV
        parsed_data = cv_parser.parse(temp_path)
        
        # Clean up
        os.remove(temp_path)
        
        return jsonify(parsed_data)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/extract-keywords', methods=['POST'])
def extract_keywords():
    """Extract skills and keywords from text"""
    data = request.get_json()
    
    if 'text' not in data:
        return jsonify({'error': 'No text provided'}), 400
    
    try:
        keywords = keyword_extractor.extract(data['text'])
        return jsonify({'keywords': keywords})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/detect-sections', methods=['POST'])
def detect_sections():
    """Detect CV sections and identify missing ones"""
    data = request.get_json()
    
    if 'text' not in data:
        return jsonify({'error': 'No text provided'}), 400
    
    try:
        sections = section_detector.detect(data['text'])
        missing = section_detector.find_missing(sections)
        
        return jsonify({
            'sections': sections,
            'missing_sections': missing
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/analyze-ats', methods=['POST'])
def analyze_ats():
    """Analyze ATS readability"""
    data = request.get_json()
    
    if 'text' not in data:
        return jsonify({'error': 'No text provided'}), 400
    
    try:
        analysis = ats_analyzer.analyze(data['text'])
        return jsonify(analysis)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/generate-suggestions', methods=['POST'])
def generate_suggestions():
    """Generate improvement suggestions"""
    data = request.get_json()
    
    if 'text' not in data:
        return jsonify({'error': 'No text provided'}), 400
    
    try:
        suggestions = suggestion_generator.generate(
            data['text'],
            data.get('sections', {}),
            data.get('keywords', [])
        )
        return jsonify({'suggestions': suggestions})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/analyze-complete', methods=['POST'])
def analyze_complete():
    """Complete CV analysis pipeline"""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    try:
        # Save file temporarily
        temp_path = f"/tmp/{file.filename}"
        file.save(temp_path)
        
        # Parse CV
        parsed_data = cv_parser.parse(temp_path)
        text = parsed_data.get('full_text', '')
        
        # Extract keywords
        keywords = keyword_extractor.extract(text)
        
        # Detect sections
        sections = section_detector.detect(text)
        missing_sections = section_detector.find_missing(sections)
        
        # Analyze ATS
        ats_analysis = ats_analyzer.analyze(text)
        
        # Generate suggestions
        suggestions = suggestion_generator.generate(text, sections, keywords)
        
        # Clean up
        os.remove(temp_path)
        
        return jsonify({
            'contact': parsed_data.get('contact', {}),
            'experience': parsed_data.get('experience', []),
            'education': parsed_data.get('education', []),
            'skills': keywords,
            'sections': sections,
            'missing_sections': missing_sections,
            'ats_score': ats_analysis.get('score', 70),
            'ats_analysis': ats_analysis,
            'suggestions': suggestions
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
