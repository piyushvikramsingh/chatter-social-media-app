#!/bin/bash

# Chatter Social Media App - Master Setup Script
# This script sets up the entire application with a single command

set -e  # Exit on any error

echo "🎭 Chatter Social Media App - Complete Setup"
echo "============================================"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

print_header() {
    echo -e "${PURPLE}[SETUP]${NC} $1"
}

# Parse command line arguments
SETUP_MODE="full"
SKIP_FRONTEND=false
SKIP_BACKEND=false
RUN_TESTS=true
START_SERVERS=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --backend-only)
            SETUP_MODE="backend"
            SKIP_FRONTEND=true
            shift
            ;;
        --frontend-only)
            SETUP_MODE="frontend"
            SKIP_BACKEND=true
            shift
            ;;
        --no-tests)
            RUN_TESTS=false
            shift
            ;;
        --no-start)
            START_SERVERS=false
            shift
            ;;
        --help|-h)
            echo "Chatter Setup Script"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --backend-only    Setup only the Laravel backend"
            echo "  --frontend-only   Setup only the Flutter frontend"
            echo "  --no-tests        Skip running tests"
            echo "  --no-start        Don't start servers after setup"
            echo "  --help, -h        Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Full setup with tests and server start"
            echo "  $0 --backend-only     # Setup only backend"
            echo "  $0 --no-tests         # Setup without running tests"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Display setup configuration
print_header "Setup Configuration"
echo "Setup mode: $SETUP_MODE"
echo "Skip backend: $SKIP_BACKEND"
echo "Skip frontend: $SKIP_FRONTEND"
echo "Run tests: $RUN_TESTS"
echo "Start servers: $START_SERVERS"
echo ""

# Check if we're in the right directory
if [ ! -f "README.md" ] || [ ! -d "chatter_backend" ] || [ ! -d "chatter" ]; then
    print_error "This doesn't appear to be the Chatter project root directory."
    print_error "Please run this script from the directory containing chatter_backend and chatter folders."
    exit 1
fi

print_header "Starting Chatter Social Media App Setup"

# Create logs directory
mkdir -p logs

# Setup backend
if [ "$SKIP_BACKEND" = false ]; then
    print_header "Setting up Backend (Laravel)"
    echo ""
    
    if [ -x "./setup-backend.sh" ]; then
        ./setup-backend.sh 2>&1 | tee logs/backend-setup.log
    else
        print_error "Backend setup script not found or not executable"
        exit 1
    fi
    
    echo ""
    print_success "Backend setup completed"
fi

# Setup frontend
if [ "$SKIP_FRONTEND" = false ]; then
    print_header "Setting up Frontend (Flutter)"
    echo ""
    
    if [ -x "./setup-frontend.sh" ]; then
        # Frontend setup might take longer and could have warnings
        ./setup-frontend.sh 2>&1 | tee logs/frontend-setup.log || true
    else
        print_error "Frontend setup script not found or not executable"
        exit 1
    fi
    
    echo ""
    print_success "Frontend setup completed"
fi

# Run health checks
print_header "Running Health Checks"
echo ""

if [ "$SKIP_BACKEND" = false ]; then
    print_status "Checking backend health..."
    
    # Check if composer.json exists and dependencies are installed
    if [ -f "chatter_backend/vendor/autoload.php" ]; then
        print_success "Backend dependencies are installed"
    else
        print_warning "Backend dependencies may not be properly installed"
    fi
    
    # Check if .env file exists
    if [ -f "chatter_backend/.env" ]; then
        print_success "Backend environment file exists"
    else
        print_warning "Backend environment file missing"
    fi
    
    # Check if database file exists (SQLite)
    if [ -f "chatter_backend/database/database.sqlite" ]; then
        print_success "Database file exists"
    else
        print_warning "Database file missing"
    fi
fi

if [ "$SKIP_FRONTEND" = false ]; then
    print_status "Checking frontend health..."
    
    # Check if pubspec.lock exists (indicates dependencies were fetched)
    if [ -f "chatter/pubspec.lock" ]; then
        print_success "Frontend dependencies are installed"
    else
        print_warning "Frontend dependencies may not be properly installed"
    fi
    
    # Check if build directory exists
    if [ -d "chatter/build" ]; then
        print_success "Frontend build directory exists"
    else
        print_warning "Frontend build directory missing"
    fi
fi

# Run tests if requested
if [ "$RUN_TESTS" = true ]; then
    print_header "Running Tests"
    echo ""
    
    if [ "$SKIP_BACKEND" = false ]; then
        print_status "Running backend tests..."
        cd chatter_backend
        if [ -f "vendor/bin/phpunit" ]; then
            ./vendor/bin/phpunit --configuration phpunit.xml || print_warning "Some backend tests failed"
        else
            print_warning "PHPUnit not available, skipping backend tests"
        fi
        cd ..
    fi
    
    if [ "$SKIP_FRONTEND" = false ]; then
        print_status "Running frontend tests..."
        cd chatter
        if command -v flutter &> /dev/null; then
            flutter test || print_warning "Some frontend tests failed"
        else
            print_warning "Flutter not available, skipping frontend tests"
        fi
        cd ..
    fi
fi

# Start servers if requested
if [ "$START_SERVERS" = true ]; then
    print_header "Starting Development Servers"
    echo ""
    
    if [ "$SKIP_BACKEND" = false ]; then
        print_status "Starting Laravel backend server..."
        print_status "Backend will be available at: http://127.0.0.1:8003"
        print_status "Use Ctrl+C to stop the server"
        
        # Create a startup script for the backend
        cat > start-backend.sh << 'EOF'
#!/bin/bash
cd chatter_backend
echo "🚀 Starting Chatter Backend Server..."
echo "Available at: http://127.0.0.1:8003"
echo "Admin panel: http://127.0.0.1:8003/admin"
echo "API base: http://127.0.0.1:8003/api/"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""
php artisan serve --host=127.0.0.1 --port=8003
EOF
        chmod +x start-backend.sh
        
        if [ "$SKIP_FRONTEND" = true ]; then
            # If only backend, start it in foreground
            ./start-backend.sh
        else
            # If both, start backend in background
            print_status "Starting backend in background..."
            nohup ./start-backend.sh > logs/backend-server.log 2>&1 &
            echo $! > logs/backend-server.pid
            sleep 3
            print_success "Backend server started (PID: $(cat logs/backend-server.pid))"
        fi
    fi
    
    if [ "$SKIP_FRONTEND" = false ] && command -v flutter &> /dev/null; then
        print_status "Frontend can be started with:"
        echo "  cd chatter && flutter run"
        echo "  Or serve the web build from: chatter/build/web/"
    fi
fi

# Final summary
echo ""
print_header "Setup Complete! 🎉"
echo ""

if [ "$SKIP_BACKEND" = false ]; then
    echo "🖥️  Backend (Laravel):"
    echo "   URL: http://127.0.0.1:8003"
    echo "   Admin: http://127.0.0.1:8003/admin (admin/password)"
    echo "   API: http://127.0.0.1:8003/api/"
    echo ""
fi

if [ "$SKIP_FRONTEND" = false ]; then
    echo "📱 Frontend (Flutter):"
    echo "   Run: cd chatter && flutter run"
    echo "   Web: chatter/build/web/"
    if [ -f "chatter/build/app/outputs/flutter-apk/app-release.apk" ]; then
        echo "   APK: chatter/build/app/outputs/flutter-apk/app-release.apk"
    fi
    echo ""
fi

echo "📋 Useful commands:"
echo "   ./start-backend.sh      - Start backend server"
echo "   ./health-check.sh       - Run health checks"
echo "   ./run-tests.sh          - Run test suite"
echo ""

echo "📚 Documentation:"
echo "   README.md                    - Getting started"
echo "   AWS_DEPLOYMENT_GUIDE.md      - Production deployment"
echo "   PRODUCTION_READINESS_CHECKLIST.md - Production checklist"
echo ""

if [ -f "logs/backend-server.pid" ]; then
    echo "🔧 Running processes:"
    echo "   Backend server PID: $(cat logs/backend-server.pid)"
    echo "   Stop with: kill $(cat logs/backend-server.pid)"
    echo ""
fi

print_success "Chatter Social Media App is ready to use!"