# SkillBridge API Documentation

## Base URL
```
http://localhost:8000/api
```

## Authentication
The API uses JWT (JSON Web Token) authentication. Include the token in the Authorization header:
```
Authorization: Bearer {your_token}
```

## Endpoints

### Authentication

#### Register User
**POST** `/register`

Creates a new user account.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

**Response (201 Created):**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  },
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

#### Login
**POST** `/login`

Authenticates a user and returns a JWT token.

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "message": "Login successful",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

#### Logout
**POST** `/logout`

Invalidates the current JWT token. Requires authentication.

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "message": "Successfully logged out"
}
```

### CV Management

#### Upload CV
**POST** `/cv/upload`

Uploads a CV file for analysis. Requires authentication.

**Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body (Form Data):**
- `cv`: File (PDF or DOCX, max 10MB)

**Response (201 Created):**
```json
{
  "message": "CV uploaded successfully",
  "cv": {
    "id": 1,
    "user_id": 1,
    "filename": "1234567890_resume.pdf",
    "file_path": "cvs/1234567890_resume.pdf",
    "original_name": "resume.pdf",
    "status": "uploaded",
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

#### Store Analysis
**POST** `/cv/analysis`

Stores the analysis results for a CV. Requires authentication.

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "cv_id": 1,
  "skills": ["python", "java", "javascript", "react"],
  "missing_sections": ["certifications", "projects"],
  "suggestions": [
    {
      "type": "skills",
      "priority": "high",
      "message": "Add more relevant skills",
      "example": "Include technical skills like Docker, Kubernetes"
    }
  ],
  "ats_score": 85
}
```

**Response (201 Created):**
```json
{
  "message": "Analysis stored successfully",
  "analysis": {
    "id": 1,
    "cv_id": 1,
    "skills": ["python", "java", "javascript", "react"],
    "missing_sections": ["certifications", "projects"],
    "suggestions": [...],
    "score": 82,
    "skills_score": 80,
    "completeness_score": 75,
    "ats_score": 85,
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

#### Get Results
**GET** `/cv/{id}/results`

Retrieves the analysis results for a specific CV. Requires authentication.

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "cv": {
    "id": 1,
    "user_id": 1,
    "filename": "1234567890_resume.pdf",
    "status": "completed",
    "analysis": {
      "id": 1,
      "cv_id": 1,
      "skills": ["python", "java", "javascript"],
      "missing_sections": ["certifications"],
      "suggestions": [...],
      "score": 82
    }
  },
  "analysis": {...}
}
```

#### Get Score
**GET** `/cv/{id}/score`

Retrieves the score breakdown for a specific CV. Requires authentication.

**Response (200 OK):**
```json
{
  "overall_score": 82,
  "skills_score": 80,
  "completeness_score": 75,
  "ats_score": 85
}
```

#### Calculate Score
**POST** `/cv/{id}/calculate-score`

Recalculates the score for a CV. Requires authentication.

**Response (200 OK):**
```json
{
  "message": "Score recalculated",
  "analysis": {
    "score": 82,
    "skills_score": 80,
    "completeness_score": 75,
    "ats_score": 85
  }
}
```

#### Get Suggestions
**GET** `/cv/{id}/suggestions`

Retrieves improvement suggestions for a CV. Requires authentication.

**Response (200 OK):**
```json
{
  "suggestions": [
    {
      "type": "skills",
      "priority": "high",
      "message": "Add more relevant technical skills",
      "example": "Include frameworks like React, Angular, or Vue"
    },
    {
      "type": "metrics",
      "priority": "high",
      "message": "Add quantifiable achievements",
      "example": "Instead of 'Improved performance', use 'Improved performance by 40%'"
    }
  ]
}
```

#### Update Suggestions
**PUT** `/cv/{id}/suggestions`

Updates the suggestions for a CV. Requires authentication.

**Request Body:**
```json
{
  "suggestions": [
    {
      "type": "skills",
      "priority": "high",
      "message": "Updated suggestion",
      "accepted": true
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "message": "Suggestions updated successfully",
  "suggestions": [...]
}
```

#### Export PDF
**POST** `/cv/{id}/export`

Exports the optimized CV as a PDF. Requires authentication.

**Response (200 OK):**
```json
{
  "message": "PDF export functionality would generate optimized CV here",
  "cv_id": 1,
  "filename": "optimized_resume.pdf"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "error": "No file provided"
}
```

### 401 Unauthorized
```json
{
  "error": "Invalid credentials"
}
```

### 403 Forbidden
```json
{
  "error": "Unauthorized"
}
```

### 404 Not Found
```json
{
  "error": "Resource not found"
}
```

### 422 Unprocessable Entity
```json
{
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password must be at least 6 characters."]
  }
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error",
  "message": "Error details..."
}
```

## Rate Limiting

API endpoints are rate-limited to prevent abuse:
- 60 requests per minute for authenticated users
- 10 requests per minute for unauthenticated users

When rate limit is exceeded:
```json
{
  "message": "Too Many Requests",
  "retry_after": 60
}
```

## File Upload Constraints

- Maximum file size: 10MB
- Allowed formats: PDF, DOC, DOCX
- Files are stored securely and encrypted at rest

## NLP Service Endpoints

### Health Check
**GET** `/health`

```json
{
  "status": "healthy",
  "service": "NLP Service"
}
```

### Complete Analysis
**POST** `/analyze-complete`

Performs complete CV analysis including parsing, keyword extraction, section detection, ATS analysis, and suggestion generation.

**Request Body (Form Data):**
- `file`: CV file (PDF or DOCX)

**Response (200 OK):**
```json
{
  "contact": {
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1-234-567-8900"
  },
  "experience": [...],
  "education": [...],
  "skills": ["python", "javascript", "react", ...],
  "sections": {
    "contact": true,
    "summary": true,
    "experience": true,
    "education": true,
    "skills": true
  },
  "missing_sections": ["certifications", "projects"],
  "ats_score": 85,
  "ats_analysis": {
    "score": 85,
    "issues": [...],
    "recommendations": [...]
  },
  "suggestions": [...]
}
```

## Best Practices

1. **Always include the Authorization header** for protected endpoints
2. **Handle token expiration** by implementing token refresh logic
3. **Validate file types** on the client side before upload
4. **Implement retry logic** for failed requests
5. **Use HTTPS** in production environments
6. **Store tokens securely** using secure storage mechanisms
7. **Implement proper error handling** for all API calls
