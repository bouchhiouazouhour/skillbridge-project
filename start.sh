#!/bin/bash

echo "🚀 Starting SkillBridge Application"
echo "====================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command_exists php; then
    echo "❌ PHP is not installed"
    exit 1
fi

if ! command_exists composer; then
    echo "❌ Composer is not installed"
    exit 1
fi

if ! command_exists python3; then
    echo "❌ Python 3 is not installed"
    exit 1
fi

echo "✅ All prerequisites found"

# Start Backend
echo ""
echo "🔧 Starting Laravel Backend..."
if [ ! -d "backend" ]; then
    echo "❌ Backend directory not found"
    exit 1
fi
cd backend
if [ ! -f ".env" ]; then
    echo "⚠️  No .env file found. Copying from .env.example..."
    cp .env.example .env
fi

if [ ! -d "vendor" ]; then
    echo "📦 Installing backend dependencies..."
    composer install
fi

php artisan serve --host=0.0.0.0 --port=8000 &
BACKEND_PID=$!
echo "✅ Backend started on http://localhost:8000 (PID: $BACKEND_PID)"

# Start NLP Service
echo ""
echo "🤖 Starting NLP Service..."
cd ../nlp_service

if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate

if [ ! -f "venv/installed" ]; then
    echo "📦 Installing NLP dependencies..."
    pip install -r requirements.txt
    python -m spacy download en_core_web_sm
    touch venv/installed
fi

python app.py &
NLP_PID=$!
echo "✅ NLP Service started on http://localhost:5000 (PID: $NLP_PID)"

echo ""
echo "✅ SkillBridge is now running!"
echo "====================================="
echo "📱 Backend API: http://localhost:8000"
echo "🤖 NLP Service: http://localhost:5000"
echo ""
echo "Press Ctrl+C to stop all services"

# Trap Ctrl+C to kill both services
trap "echo ''; echo '🛑 Stopping services...'; kill $BACKEND_PID $NLP_PID; exit" INT

# Wait for processes
wait
