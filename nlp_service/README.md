# SkillBridge NLP Service

Python-based NLP service for CV analysis, keyword extraction, and suggestion generation.

## Features

- CV Parsing (PDF and DOCX)
- Keyword Extraction
- Section Detection
- Missing Section Identification
- ATS Readability Analysis
- Improvement Suggestion Generation
- Complete Analysis Pipeline

## Setup

1. Create virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Download spaCy language model:
   ```bash
   python -m spacy download en_core_web_sm
   ```

4. Start the service:
   ```bash
   python app.py
   ```

The service will be available at `http://localhost:5000`

## API Endpoints

### Health Check
```
GET /health
```

### Parse CV
```
POST /parse
Content-Type: multipart/form-data
Body: file (PDF or DOCX)
```

### Extract Keywords
```
POST /extract-keywords
Content-Type: application/json
Body: { "text": "CV text content" }
```

### Detect Sections
```
POST /detect-sections
Content-Type: application/json
Body: { "text": "CV text content" }
```

### Analyze ATS
```
POST /analyze-ats
Content-Type: application/json
Body: { "text": "CV text content" }
```

### Generate Suggestions
```
POST /generate-suggestions
Content-Type: application/json
Body: {
  "text": "CV text content",
  "sections": {...},
  "keywords": [...]
}
```

### Complete Analysis
```
POST /analyze-complete
Content-Type: multipart/form-data
Body: file (PDF or DOCX)
```

## Modules

### cv_parser.py
Parses PDF and DOCX files to extract text and structured data.

**Features:**
- Text extraction from PDF (using pdfplumber and PyPDF2)
- Text extraction from DOCX
- Contact information extraction
- Experience section extraction
- Education section extraction

### keyword_extractor.py
Extracts skills and keywords from CV text.

**Features:**
- Technical skills identification
- Soft skills identification
- Programming language detection
- Framework and tool recognition

### section_detector.py
Detects CV sections and identifies missing ones.

**Features:**
- Required section detection (contact, experience, education, skills, summary)
- Optional section detection (certifications, projects, awards, etc.)
- Missing section identification
- Section quality scoring

### ats_analyzer.py
Analyzes ATS (Applicant Tracking System) compatibility.

**Features:**
- Formatting checks
- Keyword density analysis
- Standard header verification
- Length validation
- Consistency checks

### suggestion_generator.py
Generates actionable improvement suggestions.

**Features:**
- Missing section suggestions
- Weak verb replacement recommendations
- Metrics and quantification suggestions
- Skills improvement recommendations
- Formatting suggestions
- Priority-based suggestion ranking

## Testing

Run tests:
```bash
pytest
```

## Dependencies

- **Flask**: Web framework
- **python-docx**: DOCX file parsing
- **PyPDF2**: PDF parsing (fallback)
- **pdfplumber**: PDF text extraction
- **spacy**: NLP processing
- **nltk**: Natural language toolkit

## Performance Considerations

- CV parsing is optimized for files up to 10MB
- Text extraction uses efficient algorithms
- Keyword extraction uses pre-compiled skill sets
- Section detection uses pattern matching

## Error Handling

The service returns appropriate HTTP status codes:
- 200: Success
- 400: Bad request (missing parameters)
- 500: Internal server error

## Production Deployment

1. **CRITICAL: Disable debug mode** - Set `FLASK_DEBUG=False` in production
2. Use production WSGI server (Gunicorn, uWSGI)
3. Set up reverse proxy (Nginx)
4. Configure proper logging
5. Implement rate limiting
6. Add request authentication
7. Use SSL/TLS
8. Monitor service health
9. Set up error tracking
10. Configure CORS properly
11. Implement caching for common requests

**Security Warning:** Never run Flask with `debug=True` in production as it allows arbitrary code execution through the debugger.

## Example Usage

```python
import requests

# Health check
response = requests.get('http://localhost:5000/health')
print(response.json())

# Complete analysis
with open('resume.pdf', 'rb') as f:
    files = {'file': f}
    response = requests.post('http://localhost:5000/analyze-complete', files=files)
    results = response.json()
    print(f"Skills found: {results['skills']}")
    print(f"ATS Score: {results['ats_score']}")
    print(f"Suggestions: {len(results['suggestions'])}")
```
