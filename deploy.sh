#!/bin/bash

# SkillBridge Deployment Helper Script
# Usage: ./deploy.sh [option]
# Options:
#   build-web    - Build Flutter web for production
#   build-apk    - Build Android APK for production
#   setup-env    - Create environment files from examples
#   check-deps   - Check if all dependencies are installed
#   help         - Show this help message

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  SkillBridge Deployment Helper${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_dependencies() {
    print_header
    echo "Checking dependencies..."
    echo ""

    # Check Flutter
    if command -v flutter &> /dev/null; then
        FLUTTER_VERSION=$(flutter --version | head -n 1)
        print_success "Flutter: $FLUTTER_VERSION"
    else
        print_error "Flutter not found. Install from https://docs.flutter.dev/get-started/install"
    fi

    # Check PHP
    if command -v php &> /dev/null; then
        PHP_VERSION=$(php -v | head -n 1)
        print_success "PHP: $PHP_VERSION"
    else
        print_warning "PHP not found (only needed for backend development)"
    fi

    # Check Composer
    if command -v composer &> /dev/null; then
        COMPOSER_VERSION=$(composer --version)
        print_success "Composer: $COMPOSER_VERSION"
    else
        print_warning "Composer not found (only needed for backend development)"
    fi

    # Check Python
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version)
        print_success "Python: $PYTHON_VERSION"
    else
        print_warning "Python not found (only needed for NLP service development)"
    fi

    # Check Git
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version)
        print_success "Git: $GIT_VERSION"
    else
        print_error "Git not found. Install from https://git-scm.com/"
    fi

    echo ""
}

setup_environment() {
    print_header
    echo "Setting up environment files..."
    echo ""

    # Backend .env
    if [ ! -f "backend/.env" ]; then
        if [ -f "backend/.env.example" ]; then
            cp backend/.env.example backend/.env
            print_success "Created backend/.env from .env.example"
            print_info "Remember to update APP_KEY and JWT_SECRET!"
        else
            print_error "backend/.env.example not found"
        fi
    else
        print_warning "backend/.env already exists, skipping"
    fi

    # NLP Service .env
    if [ ! -f "nlp_service/.env" ]; then
        if [ -f "nlp_service/.env.example" ]; then
            cp nlp_service/.env.example nlp_service/.env
            print_success "Created nlp_service/.env from .env.example"
        else
            print_error "nlp_service/.env.example not found"
        fi
    else
        print_warning "nlp_service/.env already exists, skipping"
    fi

    echo ""
    print_info "Next steps:"
    echo "  1. Update backend/.env with your database credentials"
    echo "  2. Generate APP_KEY: cd backend && php artisan key:generate"
    echo "  3. Generate JWT_SECRET: cd backend && php artisan jwt:secret"
    echo ""
}

validate_url() {
    local url=$1
    # Check if URL matches valid HTTP/HTTPS pattern
    # This regex validates URLs like: https://example.com/api or http://localhost:8000/api
    if [[ ! "$url" =~ ^https?://[a-zA-Z0-9][-a-zA-Z0-9._]*(:[0-9]+)?(/[a-zA-Z0-9._/-]*)?$ ]]; then
        print_error "Invalid URL format: $url"
        echo ""
        echo "URL must be a valid HTTP/HTTPS URL, for example:"
        echo "  https://api.myapp.com/api"
        echo "  https://my-backend.railway.app/api"
        echo "  http://localhost:8000/api"
        exit 1
    fi
    
    # Warn if using HTTP in production
    if [[ "$url" =~ ^http:// ]] && [[ ! "$url" =~ localhost|127\.0\.0\.1|10\.0\.2\.2 ]]; then
        print_warning "Using HTTP instead of HTTPS. For production, HTTPS is strongly recommended."
    fi
}

build_web() {
    print_header
    
    if [ -z "$1" ]; then
        print_error "API_BASE_URL is required"
        echo ""
        echo "Usage: ./deploy.sh build-web https://your-backend-url.com/api"
        exit 1
    fi

    local API_URL="$1"
    
    # Validate the URL format
    validate_url "$API_URL"
    
    print_info "Building Flutter web with API_BASE_URL=$API_URL"
    echo ""

    # Clean previous build
    flutter clean

    # Get dependencies
    flutter pub get

    # Build for web (properly quoted to prevent injection)
    flutter build web --release --dart-define="API_BASE_URL=$API_URL"

    echo ""
    print_success "Web build completed!"
    print_info "Output: build/web/"
    echo ""
    echo "Deploy options:"
    echo "  Vercel:  cd build/web && npx vercel --prod"
    echo "  Netlify: Drag build/web folder to netlify.com"
    echo ""
}

build_apk() {
    print_header
    
    if [ -z "$1" ]; then
        print_error "API_BASE_URL is required"
        echo ""
        echo "Usage: ./deploy.sh build-apk https://your-backend-url.com/api"
        exit 1
    fi

    local API_URL="$1"
    
    # Validate the URL format
    validate_url "$API_URL"
    
    print_info "Building Android APK with API_BASE_URL=$API_URL"
    echo ""

    # Clean previous build
    flutter clean

    # Get dependencies
    flutter pub get

    # Build APK (properly quoted to prevent injection)
    flutter build apk --release --dart-define="API_BASE_URL=$API_URL"

    echo ""
    print_success "APK build completed!"
    print_info "Output: build/app/outputs/flutter-apk/app-release.apk"
    echo ""
}

show_help() {
    print_header
    echo "Usage: ./deploy.sh [command] [arguments]"
    echo ""
    echo "Commands:"
    echo "  check-deps              Check installed dependencies"
    echo "  setup-env               Create .env files from examples"
    echo "  build-web <API_URL>     Build Flutter web for production"
    echo "  build-apk <API_URL>     Build Android APK for production"
    echo "  help                    Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh check-deps"
    echo "  ./deploy.sh setup-env"
    echo "  ./deploy.sh build-web https://api.myapp.com/api"
    echo "  ./deploy.sh build-apk https://api.myapp.com/api"
    echo ""
    echo "For full deployment guide, see DEPLOYMENT_GUIDE_STUDENT.md"
    echo ""
}

# Main script
case "${1:-help}" in
    check-deps)
        check_dependencies
        ;;
    setup-env)
        setup_environment
        ;;
    build-web)
        build_web "$2"
        ;;
    build-apk)
        build_apk "$2"
        ;;
    help|*)
        show_help
        ;;
esac
