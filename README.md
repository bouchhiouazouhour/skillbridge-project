# SkillBridge Project

## Overview
SkillBridge consists of two sibling applications:

- **Flutter mobile client** (`skillbridge_frontend/`): Provides authentication, profile display, and CV optimization upload & results UI.
- **Laravel API backend** (`skillbridge-backend1/`): Exposes auth endpoints (register, login, logout, me) and CV analysis (`cv/analyze`). Performs heuristic & lightweight NLP analysis on uploaded CV text.

## Architecture
| Concern            | Flutter (skillbridge_frontend)                  | Laravel (skillbridge-backend1)                |
|--------------------|--------------------------------------------------|-----------------------------------------------|
| Auth persistence   | Secure storage bearer token                      | Sanctum personal access tokens                |
| API base URL       | `AppConfig.apiBaseUrl` (`lib/core/app_config.dart`) | Route group under `/api` (see `routes/api.php`) |
| CV upload          | `OptimizeScreen` -> multipart via HTTP           | `CvController@analyze`                        |
| NLP / heuristics   | UI rendering only                                | `CvAnalyzer` service                          |
| Config             | `--dart-define=API_URL` override                 | `.env` (copy from `.env.example`)             |

## Folder Structure
```
backend/skillbridge-project/
├─ skillbridge_frontend/    # Flutter app (pubspec.yaml, lib/, android/, ios/ ...)
├─ skillbridge-backend1/    # Laravel API (composer.json, app/, routes/, database/ ...)
├─ README.md                # (this file)
```

## Running Locally
### Backend (Laravel: skillbridge-backend1)
```powershell
cd backend/skillbridge-project/skillbridge-backend1
copy .env.example .env   # Windows copy; or use: cp .env.example .env
php artisan key:generate
composer install         # if vendor/ not present
php artisan migrate
php artisan serve        # defaults to http://127.0.0.1:8000
```

### Frontend (Flutter: skillbridge_frontend)
Android emulator uses host alias `10.0.2.2` to reach your machine.
Default base URL (in code): `http://10.0.2.2:8000/api`
Override with a different API URL:
```powershell
cd backend/skillbridge-project/skillbridge_frontend
flutter pub get
flutter run --dart-define=API_URL=http://127.0.0.1:8000/api
```
For release/test builds:
```powershell
flutter build apk --dart-define=API_URL=http://YOUR_LAN_IP:8000/api
```

## Endpoints (Simplified)
| Method | Path             | Auth | Description              |
|--------|------------------|------|--------------------------|
| POST   | /api/register    | No   | Create user + token      |
| POST   | /api/login       | No   | Issue token              |
| POST   | /api/logout      | Yes  | Revoke current token     |
| GET    | /api/me          | Yes  | Current authenticated user|
| POST   | /api/cv/analyze  | Yes  | Upload CV & get analysis |

## CV Analysis
Supported file types: `txt`, `pdf`, `docx` (legacy `.doc` removed).
Heuristics scored sections: Experience, Education, Skills, Certifications, Languages. NLP adds word counts, readability (Flesch-style approximation), top keywords, and warnings.

## Recent Fixes
- Separated backend and frontend into `mobile-backend/` and `mobile/`.
- Added environment-based API base URL with `--dart-define=API_URL`.
- Removed unsupported legacy `.doc` from validation mimes.

## Testing Checklist
Backend:
- `php artisan serve` running at expected host/port.
- `php artisan migrate` completes without errors.
- Register user: `curl -X POST http://127.0.0.1:8000/api/register -d "name=Test&email=test@example.com&password=secret123&password_confirmation=secret123"`
- Login returns token.
- Authorized request: `curl -H "Authorization: Bearer <token>" http://127.0.0.1:8000/api/me`
- CV analysis: multipart POST to `/api/cv/analyze` returns JSON with `sub_scores` and `suggestions`.

Flutter:
- Launch app (emulator) -> Splash redirects to login if no token.
- Register/Login -> Home shows greeting with user name.
- Navigate "Start now" -> Optimize screen.
- Pick `sample_cv.pdf` (create minimal test file) -> Submit -> See analysis card.
- Logout returns to login screen.

## Troubleshooting
| Issue                     | Cause / Fix |
|---------------------------|-------------|
| 401 errors after token expiry | Token cleared automatically; re-login. |
| Emulator can’t reach API  | Ensure using `10.0.2.2:8000` and backend running. |
| File upload fails (413)   | Increase `post_max_size` / `upload_max_filesize` in PHP (if changed). |
| Empty PDF text            | Some PDFs are image-scanned; need OCR (future enhancement). |

## Suggested Enhancements
- Add OCR for scanned PDFs (e.g., Tesseract integration).
- Replace manual service locator with Provider/Riverpod for state management.
- Persist last analysis locally for offline viewing.
- Add unit tests for `CvAnalyzer` and widget tests beyond default.

## Command Reference
Backend quick start:
```powershell
cd backend/skillbridge-project/skillbridge-backend1; copy .env.example .env; php artisan key:generate; composer install; php artisan migrate; php artisan serve
```
Frontend quick start:
```powershell
cd backend/skillbridge-project/skillbridge_frontend; flutter pub get; flutter run
```

## License
Internal/private project (not published). Add license if needed.
