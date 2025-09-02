#!/bin/bash

# Chatter Social Media App - Start Backend Server
# This script starts the Laravel backend server

echo "🚀 Starting Chatter Backend Server"
echo "=================================="

# Check if we're in the right directory
if [ ! -f "chatter_backend/artisan" ]; then
    echo "❌ Error: chatter_backend directory not found or invalid"
    echo "Please run this script from the project root directory"
    exit 1
fi

cd chatter_backend

# Check if setup has been completed
if [ ! -f ".env" ]; then
    echo "❌ Backend not set up. Running setup first..."
    cd ..
    ./setup-backend.sh
    cd chatter_backend
fi

# Check if database exists
if [ ! -f "database/database.sqlite" ]; then
    echo "⚠️  Database file missing. Creating and migrating..."
    touch database/database.sqlite
    php artisan migrate --force
    php artisan db:seed
fi

echo ""
echo "🌐 Starting Laravel Server..."
echo "📍 URL: http://127.0.0.1:8003"
echo "🔧 Admin Panel: http://127.0.0.1:8003/admin"
echo "🔗 API Base: http://127.0.0.1:8003/api/"
echo ""
echo "📋 Default Credentials:"
echo "   Username: admin"
echo "   Password: password"
echo "   API Key: 123"
echo ""
echo "⏹️  Press Ctrl+C to stop the server"
echo ""

# Start the server
php artisan serve --host=127.0.0.1 --port=8003