# SkillBridge Setup Guide

Complete setup instructions for the SkillBridge CV Optimization Application.

## Prerequisites

Before starting, ensure you have the following installed:

- **Flutter SDK** 3.9.2 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **PHP** 8.1 or higher with Composer ([Install PHP](https://www.php.net/manual/en/install.php))
- **Python** 3.8 or higher with pip ([Install Python](https://www.python.org/downloads/))
- **MySQL** or PostgreSQL database
- **Git** for version control

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/AmirMouelhi/Skill.git
cd Skill
```

### 2. Setup Flutter Frontend

```bash
# Install Flutter dependencies
flutter pub get

# Verify Flutter installation
flutter doctor

# Run the app (choose a platform)
flutter run
```

**Configuration:**
- The API URL is configurable via build arguments
- For development (localhost):
  ```bash
  flutter run
  ```
- For custom backend URL:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://your-backend-url/api
  ```
- For production builds:
  ```bash
  flutter build apk --dart-define=API_BASE_URL=https://api.yourdomain.com/api
  ```

### 3. Setup Laravel Backend

```bash
# Navigate to backend directory
cd backend

# Install PHP dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Configure database in .env
# Edit DB_CONNECTION, DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD

# Run database migrations
php artisan migrate

# Start the server
php artisan serve
```

The backend will be available at `http://localhost:8000`

**Important Configuration Steps:**

1. **Database Setup:**
   ```bash
   # Create MySQL database
   mysql -u root -p
   CREATE DATABASE skillbridge;
   exit
   ```

2. **JWT Secret (if using tymon/jwt-auth):**
   ```bash
   php artisan jwt:secret
   ```

3. **Storage Link:**
   ```bash
   php artisan storage:link
   ```

### 4. Setup Python NLP Service

```bash
# Navigate to NLP service directory
cd nlp_service

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
# On Linux/Mac:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Download spaCy language model
python -m spacy download en_core_web_sm

# Start the service
python app.py
```

The NLP service will be available at `http://localhost:5000`

## Detailed Setup Instructions

### Flutter Frontend Configuration

1. **Update API Base URL:**
   - Open `lib/services/api_service.dart`
   - Modify the `baseUrl` constant
   - For local development: `http://localhost:8000/api`
   - For production: `https://your-domain.com/api`

2. **Platform-Specific Setup:**

   **Android:**
   - Enable Internet permission (already configured in AndroidManifest.xml)
   - For localhost access on emulator, use `http://10.0.2.2:8000/api`

   **iOS:**
   - Update Info.plist for network permissions (if needed)
   - Allow insecure connections for local development

3. **Build the App:**
   ```bash
   # Android
   flutter build apk
   
   # iOS
   flutter build ios
   
   # Web
   flutter build web
   ```

### Laravel Backend Configuration

1. **Environment Variables (.env):**
   ```env
   APP_NAME=SkillBridge
   APP_ENV=local
   APP_DEBUG=true
   APP_URL=http://localhost:8000
   
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=skillbridge
   DB_USERNAME=root
   DB_PASSWORD=your_password
   
   JWT_SECRET=your-secret-key
   JWT_TTL=60
   
   NLP_SERVICE_URL=http://localhost:5000
   ```

2. **File Storage:**
   - Default: local storage in `storage/app`
   - For production: configure S3 or similar in `.env`

3. **CORS Configuration:**
   - Install spatie/laravel-cors if needed
   - Configure allowed origins for your Flutter app

4. **Queue Configuration (Optional):**
   - For background CV processing
   - Set `QUEUE_CONNECTION=database` or use Redis

### Python NLP Service Configuration

1. **Environment Variables (.env):**
   ```env
   FLASK_ENV=development
   FLASK_DEBUG=True
   HOST=0.0.0.0
   PORT=5000
   ```

2. **Production Deployment:**
   ```bash
   # Use Gunicorn
   pip install gunicorn
   gunicorn -w 4 -b 0.0.0.0:5000 app:app
   ```

3. **NLTK Data (if using NLTK features):**
   ```python
   import nltk
   nltk.download('punkt')
   nltk.download('stopwords')
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

## Common Issues and Solutions

### Issue: "flutter: command not found"
**Solution:** Add Flutter to your PATH:
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

### Issue: "composer: command not found"
**Solution:** Install Composer:
```bash
# Download and install
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
sudo mv composer.phar /usr/local/bin/composer
```

### Issue: Database connection failed
**Solution:**
1. Verify MySQL is running: `sudo service mysql status`
2. Check database credentials in `.env`
3. Ensure database exists: `CREATE DATABASE skillbridge;`

### Issue: JWT token not working
**Solution:**
1. Run `php artisan jwt:secret`
2. Clear config cache: `php artisan config:clear`

### Issue: File upload fails
**Solution:**
1. Check file permissions: `chmod -R 775 storage`
2. Verify max upload size in `php.ini`:
   ```
   upload_max_filesize = 10M
   post_max_size = 10M
   ```

### Issue: NLP service import errors
**Solution:**
1. Ensure virtual environment is activated
2. Reinstall dependencies: `pip install -r requirements.txt --force-reinstall`

## Production Deployment

### Frontend (Flutter)

1. **Build for production:**
   ```bash
   flutter build apk --release
   flutter build ios --release
   flutter build web --release
   ```

2. **Deploy web version:**
   - Upload `build/web` to your hosting
   - Configure web server (Nginx/Apache)

### Backend (Laravel)

1. **Configure production environment:**
   ```bash
   APP_ENV=production
   APP_DEBUG=false
   ```

2. **Optimize:**
   ```bash
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   composer install --optimize-autoloader --no-dev
   ```

3. **Web Server Configuration (Nginx):**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       root /path/to/backend/public;
       
       location / {
           try_files $uri $uri/ /index.php?$query_string;
       }
       
       location ~ \.php$ {
           fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
           fastcgi_index index.php;
           include fastcgi_params;
       }
   }
   ```

### NLP Service

1. **Use production WSGI server:**
   ```bash
   gunicorn -w 4 -b 0.0.0.0:5000 app:app
   ```

2. **Set up as system service (systemd):**
   ```ini
   [Unit]
   Description=SkillBridge NLP Service
   After=network.target
   
   [Service]
   User=www-data
   WorkingDirectory=/path/to/nlp_service
   Environment="PATH=/path/to/venv/bin"
   ExecStart=/path/to/venv/bin/gunicorn -w 4 -b 0.0.0.0:5000 app:app
   
   [Install]
   WantedBy=multi-user.target
   ```

## Security Checklist

- [ ] Change all default passwords
- [ ] Set `APP_DEBUG=false` in production
- [ ] Use HTTPS/SSL for all connections
- [ ] Configure CORS properly
- [ ] Set up rate limiting
- [ ] Implement input validation
- [ ] Use environment variables for secrets
- [ ] Enable file encryption at rest
- [ ] Set up proper file permissions
- [ ] Configure firewall rules
- [ ] Enable database backups
- [ ] Set up monitoring and logging

## Support

For issues or questions:
- Check the API documentation in `API_DOCUMENTATION.md`
- Review backend README in `backend/README.md`
- Review NLP service README in `nlp_service/README.md`
- Check GitHub Issues

## License

This project is for educational purposes.
