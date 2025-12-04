# SkillBridge - AI-Powered CV Optimization Application

SkillBridge is a comprehensive CV optimization application that helps users improve their resumes through AI/NLP analysis. The application provides feedback on skills, missing sections, ATS readability, and actionable suggestions for improvement.

## Architecture

The application follows a 3-tier architecture:

1. **Flutter Mobile App** (Frontend) - Cross-platform mobile application
2. **Laravel Backend** (API) - RESTful API server
3. **AI/NLP Services** (Analysis Engine) - Python-based NLP service

## Features

### User Management
- User registration and authentication
- Secure JWT-based authentication
- Session management

### CV Analysis
- Upload CV in PDF or DOCX format
- AI-powered keyword extraction
- Skills identification
- Section detection and completeness analysis
- ATS (Applicant Tracking System) compatibility check
- Missing section identification
- Improvement suggestions with priority levels

### Results & Insights
- Comprehensive score breakdown (Skills, Completeness, ATS)
- Visual representation of analysis results
- Detailed improvement suggestions
- Export optimized CV as PDF

### Dashboard
- Today's tasks and recommendations
- Quick access to CV upload
- Feature overview
- User profile management

## Project Structure

```
Skill/
├── lib/                    # Flutter application code
│   ├── models/            # Data models
│   ├── screens/           # UI screens
│   ├── services/          # API and business logic
│   ├── widgets/           # Reusable widgets
│   └── main.dart          # Application entry point
├── backend/               # Laravel backend
│   ├── app/
│   │   ├── Http/Controllers/  # API controllers
│   │   └── Models/            # Database models
│   ├── database/migrations/   # Database migrations
│   └── routes/api.php         # API routes
└── nlp_service/          # Python NLP service
    ├── app.py            # Flask application
    ├── cv_parser.py      # CV parsing logic
    ├── keyword_extractor.py    # Keyword extraction
    ├── section_detector.py     # Section detection
    ├── ats_analyzer.py         # ATS analysis
    └── suggestion_generator.py # Suggestion generation
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- PHP 8.1+ and Composer
- Python 3.8+ and pip
- MySQL or PostgreSQL database

### Frontend Setup (Flutter)

1. Navigate to the project root directory
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

### Backend Setup (Laravel)

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   composer install
   ```
3. Configure environment:
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```
4. Update `.env` with database credentials
5. Run migrations:
   ```bash
   php artisan migrate
   ```
6. Start the server:
   ```bash
   php artisan serve
   ```

### NLP Service Setup (Python)

1. Navigate to the nlp_service directory:
   ```bash
   cd nlp_service
   ```
2. Create a virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Download spaCy language model:
   ```bash
   python -m spacy download en_core_web_sm
   ```
5. Start the service:
   ```bash
   python app.py
   ```

## API Endpoints

### Authentication
- `POST /api/register` - User registration
- `POST /api/login` - User login
- `POST /api/logout` - User logout

### CV Management
- `POST /api/cv/upload` - Upload CV file
- `POST /api/cv/analysis` - Store analysis results
- `GET /api/cv/{id}/results` - Get analysis results
- `GET /api/cv/{id}/score` - Get CV scores
- `POST /api/cv/{id}/calculate-score` - Recalculate scores
- `GET /api/cv/{id}/suggestions` - Get improvement suggestions
- `PUT /api/cv/{id}/suggestions` - Update suggestions
- `POST /api/cv/{id}/export` - Export optimized CV as PDF

### NLP Service Endpoints
- `GET /health` - Service health check
- `POST /parse` - Parse CV file
- `POST /extract-keywords` - Extract keywords from text
- `POST /detect-sections` - Detect CV sections
- `POST /analyze-ats` - Analyze ATS compatibility
- `POST /generate-suggestions` - Generate improvement suggestions
- `POST /analyze-complete` - Complete CV analysis pipeline

## Database Schema

### users
- id, name, email, password, timestamps

### cvs
- id, user_id, filename, file_path, original_name, status, timestamps

### cv_analyses
- id, cv_id, skills (JSON), missing_sections (JSON), suggestions (JSON)
- score, skills_score, completeness_score, ats_score, timestamps

## Configuration

### Flutter App
Update `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://your-backend-url/api';
```

### Laravel Backend
Update `backend/.env`:
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=skillbridge
DB_USERNAME=your_username
DB_PASSWORD=your_password

JWT_SECRET=your-secret-key
```

## Testing

### Flutter Tests
```bash
flutter test
```

### Laravel Tests
```bash
cd backend
php artisan test
```

### Python Tests
```bash
cd nlp_service
pytest
```

## Security Features

- JWT-based authentication
- Password hashing with bcrypt
- File type and size validation
- Input sanitization
- Rate limiting on API endpoints
- Secure file storage
- Environment-based configuration

## Performance Optimization

- Efficient CV parsing algorithms
- Optimized database queries
- Caching for frequently accessed data
- Asynchronous processing for large files
- Connection pooling

## Contributing

This is a learning project demonstrating a complete full-stack application architecture.

## License

This project is for educational purposes.
