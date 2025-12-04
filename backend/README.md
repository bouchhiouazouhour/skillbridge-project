# SkillBridge Laravel Backend

RESTful API backend for the SkillBridge CV optimization application.

## Features

- JWT Authentication
- CV File Upload & Management
- Analysis Results Storage
- Score Calculation
- Suggestion Management
- PDF Export (placeholder)

## Setup

1. Install dependencies:
   ```bash
   composer install
   ```

2. Copy environment file:
   ```bash
   cp .env.example .env
   ```

3. Generate application key:
   ```bash
   php artisan key:generate
   ```

4. Configure database in `.env`:
   ```
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=skillbridge
   DB_USERNAME=root
   DB_PASSWORD=
   ```

5. Run migrations:
   ```bash
   php artisan migrate
   ```

6. Generate JWT secret:
   ```bash
   php artisan jwt:secret
   ```

7. Start the server:
   ```bash
   php artisan serve
   ```

The API will be available at `http://localhost:8000`

## API Documentation

See `/API_DOCUMENTATION.md` in the project root for complete API documentation.

## Database Schema

### users
- id: Primary key
- name: User's full name
- email: User's email (unique)
- password: Hashed password
- timestamps

### cvs
- id: Primary key
- user_id: Foreign key to users table
- filename: Stored filename
- file_path: Path to stored file
- original_name: Original filename
- status: Status (pending, uploaded, processing, completed, failed)
- timestamps

### cv_analyses
- id: Primary key
- cv_id: Foreign key to cvs table
- skills: JSON array of identified skills
- missing_sections: JSON array of missing CV sections
- suggestions: JSON array of improvement suggestions
- score: Overall CV score (0-100)
- skills_score: Skills section score (0-100)
- completeness_score: Completeness score (0-100)
- ats_score: ATS compatibility score (0-100)
- timestamps

## Security

- JWT authentication for all protected routes
- Password hashing using bcrypt
- File type and size validation
- User authorization checks
- Input sanitization and validation

## Testing

Run tests:
```bash
php artisan test
```

## Production Deployment

1. Set `APP_ENV=production` in `.env`
2. Set `APP_DEBUG=false`
3. Configure production database
4. Set up file storage (S3, etc.)
5. Configure CORS for production domain
6. Set up SSL/TLS certificates
7. Configure web server (Nginx/Apache)
8. Set up queue workers for background jobs
9. Enable caching
10. Set up monitoring and logging
