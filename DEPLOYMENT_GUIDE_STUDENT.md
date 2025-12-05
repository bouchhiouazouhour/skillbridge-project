# SkillBridge Deployment Guide for GitHub Student Pack Users

This guide provides step-by-step instructions for deploying the SkillBridge application using **free** services available through the GitHub Student Developer Pack.

## 🎓 GitHub Student Pack Benefits

As a GitHub Student Pack member, you get free access to:
- **DigitalOcean**: $200 credit for 1 year
- **Heroku**: Free dyno hours (via GitHub Student Pack or alternatives)
- **Railway**: $5 free credit per month
- **Render**: Free tier for web services
- **PlanetScale**: Free MySQL-compatible database
- **MongoDB Atlas**: Free tier database
- **Vercel**: Free for frontend deployment
- **Netlify**: Free for static sites and serverless functions
- **Azure for Students**: $100 credit

## 📋 Quick Deployment Options

| Component | Recommended Free Option | Alternative |
|-----------|------------------------|-------------|
| Flutter Web Frontend | Vercel / Netlify | Firebase Hosting |
| Laravel Backend | Railway / Render | DigitalOcean App Platform |
| Python NLP Service | Railway / Render | DigitalOcean App Platform |
| Database (MySQL) | PlanetScale / Railway | DigitalOcean Managed DB |

---

## 🚀 Option 1: Railway (Recommended - Fastest Setup)

Railway offers the easiest deployment with automatic builds and free tier credits.

### Prerequisites
1. GitHub Student Pack activated
2. Railway account linked to GitHub: https://railway.app
3. Git installed locally

### Step 1: Deploy the Database

1. Go to [Railway Dashboard](https://railway.app/dashboard)
2. Click **"New Project"** → **"Provision MySQL"**
3. Railway will create a MySQL database automatically
4. Click on the MySQL service to get connection details:
   - `MYSQL_HOST`
   - `MYSQL_PORT`
   - `MYSQL_DATABASE`
   - `MYSQL_USER`
   - `MYSQL_PASSWORD`

### Step 2: Deploy the Laravel Backend

1. In Railway, click **"New"** → **"GitHub Repo"**
2. Select your fork of `skillbridge-project`
3. Railway will detect Laravel and configure automatically
4. Set the **Root Directory** to `backend`
5. Add environment variables (click on the service → Variables):

```env
APP_NAME=SkillBridge
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:YOUR_APP_KEY_HERE

DB_CONNECTION=mysql
MYSQL_HOST=${{MySQL.MYSQL_HOST}}
MYSQL_PORT=${{MySQL.MYSQL_PORT}}
MYSQL_DATABASE=${{MySQL.MYSQL_DATABASE}}
MYSQL_USER=${{MySQL.MYSQL_USER}}
MYSQL_PASSWORD=${{MySQL.MYSQL_PASSWORD}}

JWT_SECRET=your-random-secret-key-here

NLP_SERVICE_URL=https://your-nlp-service.railway.app
```

6. Generate `APP_KEY` locally:
```bash
cd backend
php artisan key:generate --show
```

7. Copy the generated key to the `APP_KEY` variable

8. In Railway, go to Settings → Build:
   - **Build Command**: `composer install --no-dev --optimize-autoloader`
   - **Start Command**: `php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=$PORT`

9. Add a custom domain or use the Railway-provided URL

### Step 3: Deploy the Python NLP Service

1. In the same Railway project, click **"New"** → **"GitHub Repo"**
2. Select the same repository
3. Set **Root Directory** to `nlp_service`
4. Railway will detect Python and use `requirements.txt`
5. Add environment variables:

```env
FLASK_ENV=production
FLASK_DEBUG=False
HOST=0.0.0.0
PORT=$PORT
```

6. In Settings → Build, set:
   - **Build Command**: `pip install -r requirements.txt && python -m spacy download en_core_web_sm`
   - **Start Command**: `gunicorn app:app --bind 0.0.0.0:$PORT`

7. Update the backend's `NLP_SERVICE_URL` variable with the NLP service URL

### Step 4: Deploy Flutter Web Frontend

**Option A: Vercel (Recommended for Web)**

1. Install Vercel CLI:
```bash
npm i -g vercel
```

2. Build Flutter web:
```bash
flutter build web --release --dart-define=API_BASE_URL=https://your-backend.railway.app/api
```

3. Deploy:
```bash
cd build/web
vercel --prod
```

**Option B: Netlify**

1. Build Flutter web (same as above)
2. Go to [Netlify](https://netlify.com)
3. Drag and drop `build/web` folder
4. Configure redirects by creating `_redirects` file in `web/` folder before building:
```
/*    /index.html   200
```

---

## 🚀 Option 2: Render (Alternative Free Hosting)

Render offers free web services with automatic deployments from GitHub.

### Step 1: Create a Render Account

1. Go to [Render](https://render.com)
2. Sign up with GitHub
3. Connect your repository

### Step 2: Deploy PostgreSQL Database

1. Click **"New"** → **"PostgreSQL"**
2. Choose the **Free** plan
3. Note the connection details (Internal Database URL)

### Step 3: Deploy Laravel Backend

1. Click **"New"** → **"Web Service"**
2. Connect your repository
3. Configure:
   - **Name**: `skillbridge-backend`
   - **Root Directory**: `backend`
   - **Runtime**: Docker
   - **Free Instance Type**

4. Add environment variables:
```env
APP_NAME=SkillBridge
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:YOUR_APP_KEY_HERE
DB_CONNECTION=pgsql
DATABASE_URL=${{PostgreSQL.Internal Database URL}}
JWT_SECRET=your-secret-key
NLP_SERVICE_URL=https://skillbridge-nlp.onrender.com
```

5. Modify `backend/.env` to use PostgreSQL:
```env
DB_CONNECTION=pgsql
```

### Step 4: Deploy NLP Service

1. Click **"New"** → **"Web Service"**
2. Connect your repository
3. Configure:
   - **Name**: `skillbridge-nlp`
   - **Root Directory**: `nlp_service`
   - **Runtime**: Docker
   - **Free Instance Type**

4. Add environment variables:
```env
FLASK_ENV=production
FLASK_DEBUG=False
```

---

## 🚀 Option 3: DigitalOcean App Platform ($200 Credit)

Best for production-grade deployment with more resources.

### Step 1: Redeem GitHub Student Credit

1. Go to [GitHub Education](https://education.github.com/pack)
2. Find DigitalOcean and click **"Get access"**
3. Apply the $200 credit to your account

### Step 2: Create App

1. Go to [DigitalOcean App Platform](https://cloud.digitalocean.com/apps)
2. Click **"Create App"**
3. Select your GitHub repository

### Step 3: Configure Services

The app platform will detect multiple services. Configure each:

**Backend Service:**
- Source Directory: `/backend`
- Run Command: `php artisan serve --host=0.0.0.0 --port=8080`
- HTTP Port: 8080

**NLP Service:**
- Source Directory: `/nlp_service`
- Run Command: `gunicorn app:app --bind 0.0.0.0:5000`
- HTTP Port: 5000

**Database:**
- Add a dev database (MySQL or PostgreSQL)
- Use the connection string in environment variables

### Step 4: Environment Variables

Set all required variables in the App Platform console.

---

## 📱 Mobile App Deployment (Android/iOS)

### Android APK Build

1. Build release APK:
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-backend-url.com/api
```

2. Find APK at `build/app/outputs/flutter-apk/app-release.apk`

3. **Distribution Options:**
   - Share APK directly
   - Upload to [Firebase App Distribution](https://firebase.google.com/docs/app-distribution) (free)
   - Publish to Google Play (requires $25 one-time fee)

### iOS Build (Requires Mac)

1. Build iOS release:
```bash
flutter build ios --release --dart-define=API_BASE_URL=https://your-backend-url.com/api
```

2. **Distribution Options:**
   - TestFlight (free, requires Apple Developer Program $99/year)
   - Ad-hoc distribution

---

## 🔧 Environment Configuration

### Backend Production `.env`

Create `backend/.env.production`:

```env
APP_NAME=SkillBridge
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:GENERATE_THIS_KEY
APP_URL=https://your-backend-url.com

LOG_CHANNEL=stack
LOG_LEVEL=error

# Railway/Render MySQL
DB_CONNECTION=mysql
DB_HOST=your-mysql-host
DB_PORT=3306
DB_DATABASE=your-database
DB_USERNAME=your-username
DB_PASSWORD=your-password

# Or for PostgreSQL (Render)
# DB_CONNECTION=pgsql
# DATABASE_URL=postgresql://...

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

JWT_SECRET=generate-a-secure-random-key
JWT_TTL=60

NLP_SERVICE_URL=https://your-nlp-service-url.com
```

### NLP Service Production `.env`

Create `nlp_service/.env.production`:

```env
FLASK_ENV=production
FLASK_DEBUG=False
HOST=0.0.0.0
PORT=5000
MAX_FILE_SIZE=10
SUPPORTED_FORMATS=pdf,doc,docx
LOG_LEVEL=WARNING
```

### Flutter Production Configuration

Update `lib/config/app_config.dart` for production OR use build flags:

```bash
# Build with production URL
flutter build web --dart-define=API_BASE_URL=https://your-backend.railway.app/api
flutter build apk --dart-define=API_BASE_URL=https://your-backend.railway.app/api
```

---

## 🔒 Security Checklist

Before deploying, ensure:

- [ ] `APP_DEBUG=false` in production
- [ ] Strong `APP_KEY` generated
- [ ] Strong `JWT_SECRET` generated
- [ ] HTTPS enabled (Railway/Render provide this automatically)
- [ ] Database credentials are secure
- [ ] CORS configured for your frontend domain
- [ ] Rate limiting enabled
- [ ] File upload size limits set

### Generate Secure Keys

```bash
# Generate APP_KEY (Laravel)
cd backend
php artisan key:generate --show

# Generate JWT_SECRET (random 32 characters)
openssl rand -base64 32
```

---

## 🛠️ Troubleshooting

### Common Issues

**1. Database Connection Errors**
- Verify database host, port, and credentials
- Check if database is accessible from your service
- Railway/Render provide internal URLs - use those

**2. NLP Service Not Responding**
- Check if NLP service is running: `curl https://your-nlp-service/health`
- Verify `NLP_SERVICE_URL` in backend environment
- Check NLP service logs for Python errors

**3. CORS Errors**
- Add your frontend domain to Laravel CORS config
- Edit `backend/config/cors.php`:
```php
'allowed_origins' => ['https://your-frontend-domain.com'],
```

**4. File Upload Issues**
- Check `upload_max_filesize` and `post_max_size` in PHP
- Verify storage permissions
- Check if storage is configured correctly

**5. JWT Token Errors**
- Regenerate JWT_SECRET
- Clear Laravel cache: `php artisan config:clear`
- Verify token TTL settings

### Checking Service Health

**Backend:**
```bash
curl https://your-backend-url.com/api/health
```

**NLP Service:**
```bash
curl https://your-nlp-service.com/health
```

---

## 📊 Monitoring (Free Options)

1. **UptimeRobot** - Free uptime monitoring (50 monitors)
2. **Better Stack (Logtail)** - Free log management
3. **Sentry** - Free error tracking (5k events/month)

---

## 🎯 Quick Start Summary

**Fastest Path to Deployment (< 30 minutes):**

1. Create Railway account → Link GitHub
2. Deploy MySQL database
3. Deploy backend (root: `backend`)
4. Deploy NLP service (root: `nlp_service`)
5. Build Flutter web with production URL
6. Deploy to Vercel/Netlify

**Total Cost: $0** (within free tier limits)

---

## 📞 Getting Help

- **Railway Discord**: https://discord.gg/railway
- **Render Community**: https://community.render.com
- **Flutter Discord**: https://discord.gg/N7Yshp4
- **Stack Overflow**: Tag with `flutter`, `laravel`, `deployment`

---

## 🔄 Continuous Deployment (CI/CD)

Railway, Render, and Vercel all support automatic deployments when you push to GitHub. Once configured:

1. Make changes locally
2. `git push` to your branch
3. Services automatically rebuild and deploy

No additional CI/CD setup required!

---

**Last Updated:** December 2024
**Guide Version:** 1.0.0
