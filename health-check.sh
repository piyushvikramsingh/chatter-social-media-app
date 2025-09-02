#!/bin/bash

# Chatter Social Media App - Health Check Script
# This script verifies that all components are running properly

echo "🔍 Chatter Health Check"
echo "======================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[CHECK]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Track overall health
OVERALL_STATUS=0

# Function to check HTTP endpoint
check_endpoint() {
    local url=$1
    local name=$2
    local expected_code=${3:-200}
    
    print_status "Checking $name at $url"
    
    response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 --max-time 30 "$url" 2>/dev/null)
    
    if [ "$response" = "$expected_code" ]; then
        print_success "$name is responding (HTTP $response)"
        return 0
    else
        print_error "$name is not responding (HTTP $response)"
        return 1
    fi
}

# Function to check if process is running
check_process() {
    local process_name=$1
    local friendly_name=$2
    
    print_status "Checking if $friendly_name is running"
    
    if pgrep -f "$process_name" > /dev/null; then
        local pid=$(pgrep -f "$process_name" | head -1)
        print_success "$friendly_name is running (PID: $pid)"
        return 0
    else
        print_error "$friendly_name is not running"
        return 1
    fi
}

# Function to check file exists
check_file() {
    local file_path=$1
    local friendly_name=$2
    
    print_status "Checking if $friendly_name exists"
    
    if [ -f "$file_path" ]; then
        print_success "$friendly_name exists"
        return 0
    else
        print_error "$friendly_name not found at $file_path"
        return 1
    fi
}

# Function to check directory exists
check_directory() {
    local dir_path=$1
    local friendly_name=$2
    
    print_status "Checking if $friendly_name exists"
    
    if [ -d "$dir_path" ]; then
        print_success "$friendly_name exists"
        return 0
    else
        print_error "$friendly_name not found at $dir_path"
        return 1
    fi
}

echo "🔧 Infrastructure Checks"
echo "------------------------"

# Check if we're in the right directory
if ! check_file "README.md" "Project README"; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Check dependencies
print_status "Checking system dependencies"

if command -v php &> /dev/null; then
    php_version=$(php -v | head -n1 | cut -d' ' -f2)
    print_success "PHP $php_version installed"
else
    print_error "PHP not found"
    OVERALL_STATUS=1
fi

if command -v composer &> /dev/null; then
    composer_version=$(composer --version | cut -d' ' -f3)
    print_success "Composer $composer_version installed"
else
    print_error "Composer not found"
    OVERALL_STATUS=1
fi

if command -v node &> /dev/null; then
    node_version=$(node --version)
    print_success "Node.js $node_version installed"
else
    print_warning "Node.js not found (optional for development)"
fi

echo ""
echo "📁 File System Checks"
echo "---------------------"

# Backend checks
check_directory "chatter_backend" "Backend directory" || OVERALL_STATUS=1
check_file "chatter_backend/composer.json" "Backend composer.json" || OVERALL_STATUS=1
check_file "chatter_backend/.env" "Backend environment file" || OVERALL_STATUS=1
check_file "chatter_backend/artisan" "Laravel artisan command" || OVERALL_STATUS=1

if [ -f "chatter_backend/.env" ]; then
    check_file "chatter_backend/database/database.sqlite" "SQLite database file" || OVERALL_STATUS=1
fi

# Frontend checks
check_directory "chatter" "Frontend directory" || OVERALL_STATUS=1
check_file "chatter/pubspec.yaml" "Flutter pubspec.yaml" || OVERALL_STATUS=1

echo ""
echo "🌐 Service Checks"
echo "-----------------"

# Check for running backend server
BACKEND_RUNNING=false
if check_process "php artisan serve" "Laravel backend server"; then
    BACKEND_RUNNING=true
    # Test backend endpoints
    if check_endpoint "http://127.0.0.1:8003/api/fetchSetting" "Backend API (Settings)"; then
        print_success "Backend API is functional"
    else
        print_error "Backend API is not responding properly"
        OVERALL_STATUS=1
    fi
    
    if check_endpoint "http://127.0.0.1:8003" "Backend admin panel"; then
        print_success "Backend admin panel is accessible"
    else
        print_warning "Backend admin panel may not be accessible"
    fi
else
    print_warning "Backend server is not running"
    print_status "Start it with: ./start-backend.sh"
fi

# Check Docker services (if running)
echo ""
echo "🐳 Docker Service Checks"
echo "------------------------"

if command -v docker &> /dev/null; then
    print_success "Docker is installed"
    
    # Check if Docker services are running
    if docker-compose ps --services 2>/dev/null | grep -q "backend"; then
        print_status "Checking Docker services"
        
        # Check backend container
        if docker-compose ps backend | grep -q "Up"; then
            print_success "Docker backend container is running"
            check_endpoint "http://localhost:8003/api/fetchSetting" "Docker backend API" || OVERALL_STATUS=1
        else
            print_warning "Docker backend container is not running"
        fi
        
        # Check frontend container
        if docker-compose ps frontend | grep -q "Up"; then
            print_success "Docker frontend container is running"
            check_endpoint "http://localhost:3000" "Docker frontend" || OVERALL_STATUS=1
        else
            print_warning "Docker frontend container is not running"
        fi
    else
        print_status "Docker services are not running"
        print_status "Start them with: docker-compose up -d"
    fi
else
    print_warning "Docker not found (optional)"
fi

echo ""
echo "📊 Health Summary"
echo "================"

if [ $OVERALL_STATUS -eq 0 ]; then
    print_success "All critical health checks passed! ✅"
    echo ""
    echo "🎯 Available Services:"
    if [ "$BACKEND_RUNNING" = true ]; then
        echo "   • Backend API: http://127.0.0.1:8003/api/"
        echo "   • Admin Panel: http://127.0.0.1:8003/admin"
    fi
    echo "   • Docker: docker-compose up -d"
    echo ""
    echo "🧪 Test API:"
    echo "   curl -H 'APIKEY: 123' http://127.0.0.1:8003/api/fetchSetting"
else
    print_error "Some health checks failed! ❌"
    echo ""
    echo "🔧 Quick fixes:"
    echo "   • Run setup: ./setup.sh"
    echo "   • Start backend: ./start-backend.sh"
    echo "   • Check logs: ls -la logs/"
fi

exit $OVERALL_STATUS