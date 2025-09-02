#!/bin/bash

# Chatter Social Media App - Backend Setup Script
# This script automates the Laravel backend setup process

set -e  # Exit on any error

echo "🚀 Setting up Chatter Backend (Laravel)"
echo "========================================"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -d "chatter_backend" ]; then
    print_error "chatter_backend directory not found. Please run this script from the project root."
    exit 1
fi

cd chatter_backend

# Check prerequisites
print_status "Checking prerequisites..."

# Check PHP
if ! command -v php &> /dev/null; then
    print_error "PHP is not installed. Please install PHP 8.0+ and try again."
    exit 1
fi

php_version=$(php -v | head -n1 | cut -d' ' -f2 | cut -d'.' -f1,2)
required_version="8.0"
if [ "$(printf '%s\n' "$required_version" "$php_version" | sort -V | head -n1)" = "$required_version" ]; then
    print_success "PHP $php_version detected"
else
    print_error "PHP $php_version detected, but PHP 8.0+ is required"
    exit 1
fi

# Check Composer
if ! command -v composer &> /dev/null; then
    print_error "Composer is not installed. Please install Composer and try again."
    exit 1
fi
print_success "Composer detected"

# Check Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js and try again."
    exit 1
fi
print_success "Node.js $(node --version) detected"

# Check npm
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed. Please install npm and try again."
    exit 1
fi
print_success "npm $(npm --version) detected"

# Install PHP dependencies
print_status "Installing PHP dependencies with Composer..."
composer install --optimize-autoloader --no-interaction --prefer-dist
print_success "PHP dependencies installed"

# Install Node.js dependencies
print_status "Installing Node.js dependencies..."
npm install
print_success "Node.js dependencies installed"

# Set up environment file
print_status "Setting up environment configuration..."
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_success "Created .env from .env.example"
    else
        print_warning ".env.example not found, creating basic .env file"
        cat > .env << EOL
APP_NAME="Chatter Social Media"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://127.0.0.1:8003

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=sqlite
DB_DATABASE=\${PWD}/database/database.sqlite

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DRIVER=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

API_KEY=123
EOL
    fi
else
    print_warning ".env file already exists, skipping creation"
fi

# Generate application key
print_status "Generating application key..."
php artisan key:generate --force
print_success "Application key generated"

# Set up database
print_status "Setting up database..."
if [ ! -f "database/database.sqlite" ]; then
    touch database/database.sqlite
    print_success "SQLite database file created"
else
    print_warning "Database file already exists"
fi

# Run database migrations
print_status "Running database migrations..."
php artisan migrate --force
print_success "Database migrations completed"

# Clear and cache configuration
print_status "Optimizing application..."
php artisan config:clear
php artisan config:cache
php artisan route:clear
php artisan route:cache
php artisan view:clear
php artisan view:cache
print_success "Application optimized"

# Set proper permissions
print_status "Setting file permissions..."
chmod -R 755 .
chmod -R 775 storage
chmod -R 775 bootstrap/cache
print_success "File permissions set"

# Build frontend assets
print_status "Building frontend assets..."
npm run production
print_success "Frontend assets built"

print_success "Backend setup completed successfully!"
print_status "You can now start the server with: php artisan serve --host=127.0.0.1 --port=8003"
print_status "Admin panel will be available at: http://127.0.0.1:8003"
print_status "Default admin credentials: admin / password"

echo ""
echo -e "${GREEN}✅ Backend setup complete!${NC}"