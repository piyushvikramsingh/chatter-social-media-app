#!/bin/bash

# Chatter Social Media App - Test Runner Script
# This script runs comprehensive tests on the application

echo "🧪 Chatter Test Suite"
echo "===================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
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

# Track test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="${3:-0}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Running: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        local result=$?
        if [ $result -eq $expected_result ]; then
            print_success "$test_name"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            return 0
        else
            print_error "$test_name (exit code: $result, expected: $expected_result)"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            return 1
        fi
    else
        print_error "$test_name (command failed)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Function to test API endpoint
test_api_endpoint() {
    local endpoint="$1"
    local description="$2"
    local expected_status="${3:-200}"
    local api_key="${4:-123}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    print_status "Testing API: $description"
    
    local response=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Content-Type: application/json" \
        -H "APIKEY: $api_key" \
        --connect-timeout 10 \
        --max-time 30 \
        "$endpoint" 2>/dev/null)
    
    if [ "$response" = "$expected_status" ]; then
        print_success "$description (HTTP $response)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        print_error "$description (HTTP $response, expected $expected_status)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Create logs directory
mkdir -p logs

echo "🔧 Environment Tests"
echo "-------------------"

# Basic environment tests
run_test "Project structure check" "test -f README.md && test -d chatter_backend && test -d chatter"
run_test "Backend composer.json exists" "test -f chatter_backend/composer.json"
run_test "Frontend pubspec.yaml exists" "test -f chatter/pubspec.yaml"

echo ""
echo "📦 Dependency Tests"
echo "------------------"

# Check if backend dependencies are installed
run_test "Backend dependencies installed" "test -f chatter_backend/vendor/autoload.php"
run_test "Backend .env file exists" "test -f chatter_backend/.env"
run_test "SQLite database exists" "test -f chatter_backend/database/database.sqlite"

# Check if frontend dependencies are installed
run_test "Frontend dependencies installed" "test -f chatter/pubspec.lock"

echo ""
echo "🖥️ Backend Tests"
echo "---------------"

# Start backend server if not running
BACKEND_STARTED=false
if ! pgrep -f "php artisan serve" > /dev/null; then
    print_status "Starting backend server for testing..."
    cd chatter_backend
    nohup php artisan serve --host=127.0.0.1 --port=8003 > ../logs/test-backend.log 2>&1 &
    echo $! > ../logs/test-backend.pid
    cd ..
    sleep 5
    BACKEND_STARTED=true
    print_status "Backend server started for testing (PID: $(cat logs/test-backend.pid))"
fi

# Test Laravel backend
if [ -d "chatter_backend" ]; then
    print_status "Running Laravel tests..."
    cd chatter_backend
    
    # Test artisan commands
    run_test "Artisan command works" "php artisan --version"
    run_test "Application key set" "grep -q 'APP_KEY=base64:' .env"
    run_test "Database connection" "php artisan migrate:status"
    
    # Run PHPUnit tests if available
    if [ -f "vendor/bin/phpunit" ]; then
        print_status "Running PHPUnit tests..."
        if ./vendor/bin/phpunit --configuration phpunit.xml > ../logs/phpunit.log 2>&1; then
            print_success "PHPUnit tests passed"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            print_warning "Some PHPUnit tests failed (see logs/phpunit.log)"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
    else
        print_warning "PHPUnit not available, skipping unit tests"
    fi
    
    cd ..
fi

echo ""
echo "🌐 API Tests"
echo "-----------"

# Wait a bit more for server to be ready
sleep 2

# Test API endpoints
BASE_URL="http://127.0.0.1:8003"
API_URL="$BASE_URL/api"

# Basic connectivity
test_api_endpoint "$BASE_URL" "Admin panel accessibility"
test_api_endpoint "$API_URL/fetchSetting" "Settings API endpoint"
test_api_endpoint "$API_URL/fetchInterests" "Interests API endpoint"

# Test API with POST requests
print_status "Testing POST API endpoints..."

# Test settings endpoint with POST
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if curl -s -X POST -H "Content-Type: application/json" -H "APIKEY: 123" \
    "$API_URL/fetchSetting" -d '{}' | grep -q "app_name\|success"; then
    print_success "POST Settings API endpoint"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    print_error "POST Settings API endpoint"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

echo ""
echo "📱 Frontend Tests"
echo "----------------"

if [ -d "chatter" ]; then
    cd chatter
    
    # Test Flutter commands
    if command -v flutter &> /dev/null; then
        run_test "Flutter doctor" "flutter doctor --verbose > ../logs/flutter-doctor.log 2>&1"
        run_test "Flutter analyze" "flutter analyze > ../logs/flutter-analyze.log 2>&1"
        
        # Run Flutter tests if available
        if [ -d "test" ] && [ "$(ls -A test 2>/dev/null)" ]; then
            print_status "Running Flutter tests..."
            if flutter test > ../logs/flutter-test.log 2>&1; then
                print_success "Flutter tests passed"
                PASSED_TESTS=$((PASSED_TESTS + 1))
            else
                print_warning "Some Flutter tests failed (see logs/flutter-test.log)"
                FAILED_TESTS=$((FAILED_TESTS + 1))
            fi
            TOTAL_TESTS=$((TOTAL_TESTS + 1))
        else
            print_warning "No Flutter tests found to run"
        fi
    else
        print_warning "Flutter not available, skipping Flutter tests"
    fi
    
    cd ..
fi

echo ""
echo "🐳 Docker Tests"
echo "--------------"

if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
    run_test "Docker available" "docker --version"
    run_test "Docker Compose available" "docker-compose --version"
    
    # Test Docker build (but don't run to avoid conflicts)
    print_status "Testing Docker configuration..."
    run_test "Backend Dockerfile valid" "docker build -f Dockerfile.backend -t chatter-backend-test . > logs/docker-backend-build.log 2>&1"
    
    # Clean up test image
    if docker images | grep -q "chatter-backend-test"; then
        docker rmi chatter-backend-test > /dev/null 2>&1 || true
    fi
else
    print_warning "Docker not available, skipping Docker tests"
fi

# Clean up test backend server if we started it
if [ "$BACKEND_STARTED" = true ] && [ -f "logs/test-backend.pid" ]; then
    print_status "Stopping test backend server..."
    kill $(cat logs/test-backend.pid) 2>/dev/null || true
    rm -f logs/test-backend.pid
fi

echo ""
echo "📊 Test Results"
echo "==============="

echo "Total tests: $TOTAL_TESTS"
echo "Passed: $PASSED_TESTS"
echo "Failed: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    print_success "All tests passed! ✅"
    echo ""
    echo "🎯 Application is ready for:"
    echo "   • Development use"
    echo "   • Production deployment"
    echo "   • Docker containerization"
    exit 0
else
    print_error "$FAILED_TESTS test(s) failed! ❌"
    echo ""
    echo "🔧 Check logs in the logs/ directory:"
    echo "   • logs/test-backend.log"
    echo "   • logs/phpunit.log"
    echo "   • logs/flutter-test.log"
    echo "   • logs/docker-backend-build.log"
    echo ""
    echo "Run ./health-check.sh for more diagnostics"
    exit 1
fi