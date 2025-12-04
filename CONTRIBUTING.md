# Contributing to SkillBridge

Thank you for your interest in contributing to SkillBridge! This document provides guidelines and instructions for contributing to the project.

## Project Overview

SkillBridge is a full-stack CV optimization application with three main components:
1. **Flutter Frontend** - Mobile/Web application
2. **Laravel Backend** - RESTful API
3. **Python NLP Service** - AI/ML analysis engine

## Development Setup

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for complete setup instructions.

## Member Responsibilities

The project is divided into three member areas:

### Member 1: Authentication & Basic Analysis
**Backend:**
- Authentication endpoints (register, login, logout)
- CV upload endpoint
- Database schema (users, cvs, cv_analyses)
- Basic scoring logic

**Frontend:**
- Welcome/Login/Register screens
- CV upload UI
- Results page for skills & missing sections

**NLP:**
- CV parsing (PDF/DOCX)
- Keyword extraction
- JSON output generation

### Member 2: Dashboard & Section Analysis
**Backend:**
- Results storage endpoints
- Sub-score calculation
- Secure file handling

**Frontend:**
- Dashboard UI
- File picker integration
- Visual feedback (heatmaps, progress indicators)

**NLP:**
- Section detection
- Section scoring
- Missing information detection

### Member 3: Suggestions & Export
**Backend:**
- Scoring logic endpoints
- Suggestions endpoints
- PDF generation

**Frontend:**
- Results display screen
- Suggestion editing interface
- Export PDF functionality

**NLP:**
- ATS readability analysis
- Phrase rewriting
- Suggestion generation

## Code Style Guidelines

### Flutter/Dart
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Format code: `flutter format .`
- Run linter: `flutter analyze`

Example:
```dart
// Good
Future<void> uploadCV(File file) async {
  if (file == null) {
    throw ArgumentError('File cannot be null');
  }
  // Implementation
}

// Bad
void upload(var f) {
  // Implementation
}
```

### PHP/Laravel
- Follow [PSR-12](https://www.php-fig.org/psr/psr-12/) coding standard
- Use type hints and return types
- Write descriptive method names
- Add PHPDoc comments
- Use Laravel conventions

Example:
```php
// Good
public function uploadCV(Request $request): JsonResponse
{
    $validator = Validator::make($request->all(), [
        'cv' => 'required|file|mimes:pdf,doc,docx|max:10240',
    ]);
    
    // Implementation
}

// Bad
function upload($req) {
    // Implementation
}
```

### Python
- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/) style guide
- Use type hints (Python 3.8+)
- Write docstrings for functions and classes
- Keep functions focused and small
- Use meaningful variable names

Example:
```python
# Good
def extract_keywords(text: str) -> List[str]:
    """
    Extract keywords and skills from CV text.
    
    Args:
        text: The CV text content
        
    Returns:
        List of identified keywords
    """
    # Implementation

# Bad
def extract(t):
    # Implementation
```

## Commit Guidelines

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(auth): add JWT authentication to login endpoint

Implemented JWT token generation and validation for user authentication.
Tokens expire after 60 minutes.

Closes #123
```

```
fix(cv-parser): handle empty PDF files gracefully

Added validation to check if PDF has content before parsing.
Returns appropriate error message for empty files.
```

## Branch Naming

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring

Example: `feature/add-cv-export`, `fix/login-validation`

## Pull Request Process

1. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following code style guidelines

3. **Test your changes:**
   ```bash
   # Flutter
   flutter test
   
   # Laravel
   php artisan test
   
   # Python
   pytest
   ```

4. **Commit your changes** with descriptive messages

5. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request** on GitHub with:
   - Clear description of changes
   - Reference to related issues
   - Screenshots (for UI changes)
   - Test results

7. **Address review comments** if any

8. **Wait for approval** and merge

## Testing Requirements

### Flutter Tests
- Widget tests for UI components
- Unit tests for business logic
- Integration tests for API calls

### Laravel Tests
- Feature tests for API endpoints
- Unit tests for models and services
- Test authentication flows

### Python Tests
- Unit tests for each module
- Integration tests for complete pipeline
- Test edge cases and error handling

## Documentation

- Update README.md for new features
- Update API_DOCUMENTATION.md for API changes
- Add inline comments for complex logic
- Update SETUP_GUIDE.md for setup changes

## Code Review Checklist

Before submitting a PR, ensure:
- [ ] Code follows style guidelines
- [ ] All tests pass
- [ ] New features have tests
- [ ] Documentation is updated
- [ ] No sensitive data in commits
- [ ] Commit messages are clear
- [ ] Code is properly formatted
- [ ] No unnecessary dependencies added
- [ ] Error handling is implemented
- [ ] Security best practices followed

## Reporting Bugs

Use GitHub Issues with the following information:
- Clear, descriptive title
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Environment details (OS, versions, etc.)

## Feature Requests

For feature requests, provide:
- Clear description of the feature
- Use case and benefits
- Proposed implementation (optional)
- Mockups or examples (if applicable)

## Questions and Support

- Open a GitHub Issue for questions
- Check existing documentation first
- Be specific and provide context

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the code, not the person
- Help others learn and grow
- Celebrate successes together

Thank you for contributing to SkillBridge! 🚀
