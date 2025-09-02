#!/bin/bash

# Chatter Social Media App - Production Deployment Script
# This script handles production deployment with Docker

set -e  # Exit on any error

echo "🚀 Chatter Production Deployment"
echo "================================"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[DEPLOY]${NC} $1"
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
    echo -e "${PURPLE}[STAGE]${NC} $1"
}

# Parse command line arguments
ENVIRONMENT="production"
BUILD_ONLY=false
SKIP_TESTS=false
FORCE_REBUILD=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --staging)
            ENVIRONMENT="staging"
            shift
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --force-rebuild)
            FORCE_REBUILD=true
            shift
            ;;
        --help|-h)
            echo "Chatter Production Deployment Script"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --staging         Deploy to staging environment"
            echo "  --build-only      Only build containers, don't deploy"
            echo "  --skip-tests      Skip running tests before deployment"
            echo "  --force-rebuild   Force rebuild of all containers"
            echo "  --help, -h        Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                       # Deploy to production"
            echo "  $0 --staging            # Deploy to staging"
            echo "  $0 --build-only         # Build containers only"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Display deployment configuration
print_header "Deployment Configuration"
echo "Environment: $ENVIRONMENT"
echo "Build only: $BUILD_ONLY"
echo "Skip tests: $SKIP_TESTS"
echo "Force rebuild: $FORCE_REBUILD"
echo ""

# Check prerequisites
print_header "Checking Prerequisites"

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ] || [ ! -f "README.md" ]; then
    print_error "This doesn't appear to be the Chatter project root directory."
    exit 1
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker and try again."
    exit 1
fi
print_success "Docker detected"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose and try again."
    exit 1
fi
print_success "Docker Compose detected"

# Create logs directory
mkdir -p logs

# Create environment-specific configuration
print_header "Setting up Environment Configuration"

if [ "$ENVIRONMENT" = "production" ]; then
    # Production environment
    export COMPOSE_FILE="docker-compose.yml:docker-compose.prod.yml"
    
    # Create production environment file
    if [ ! -f ".env.production" ]; then
        print_status "Creating production environment template..."
        cat > .env.production << 'EOF'
# Production Environment Configuration
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-domain.com

# Database Configuration
DB_CONNECTION=sqlite
DB_DATABASE=/var/www/html/database/database.sqlite

# Security
API_KEY=CHANGE_THIS_IN_PRODUCTION

# AWS Configuration (Optional)
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=your-s3-bucket

# Firebase Configuration (Optional)
FIREBASE_PROJECT_ID=your-firebase-project
FIREBASE_CLIENT_EMAIL=your-firebase-email
FIREBASE_PRIVATE_KEY="your-firebase-private-key"

# Agora Configuration (Optional)
AGORA_APP_ID=your-agora-app-id
AGORA_APP_CERT=your-agora-certificate
EOF
        print_warning "Please edit .env.production with your actual configuration"
    fi
    
    DOCKER_ENV_FILE=".env.production"
else
    # Staging environment
    export COMPOSE_FILE="docker-compose.yml"
    DOCKER_ENV_FILE=".env.staging"
    
    if [ ! -f ".env.staging" ]; then
        cp docker/backend/.env.docker .env.staging
        print_success "Created staging environment file"
    fi
fi

# Run tests unless skipped
if [ "$SKIP_TESTS" = false ]; then
    print_header "Running Pre-deployment Tests"
    
    if [ -x "./run-tests.sh" ]; then
        ./run-tests.sh 2>&1 | tee logs/pre-deployment-tests.log
        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            print_error "Tests failed! Deployment aborted."
            print_status "Check logs/pre-deployment-tests.log for details"
            exit 1
        fi
        print_success "All tests passed"
    else
        print_warning "Test script not found, skipping tests"
    fi
fi

# Build containers
print_header "Building Docker Containers"

BUILD_ARGS=""
if [ "$FORCE_REBUILD" = true ]; then
    BUILD_ARGS="--no-cache"
    print_status "Force rebuilding all containers..."
else
    print_status "Building containers..."
fi

# Build backend
print_status "Building backend container..."
docker build $BUILD_ARGS -f Dockerfile.backend -t chatter-backend:$ENVIRONMENT . 2>&1 | tee logs/docker-backend-build.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    print_error "Backend container build failed!"
    exit 1
fi
print_success "Backend container built"

# Build frontend
print_status "Building frontend container..."
docker build $BUILD_ARGS -f Dockerfile.frontend -t chatter-frontend:$ENVIRONMENT . 2>&1 | tee logs/docker-frontend-build.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    print_error "Frontend container build failed!"
    exit 1
fi
print_success "Frontend container built"

# Create production docker-compose override if needed
if [ "$ENVIRONMENT" = "production" ] && [ ! -f "docker-compose.prod.yml" ]; then
    print_status "Creating production Docker Compose override..."
    cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  backend:
    image: chatter-backend:production
    environment:
      - APP_ENV=production
      - APP_DEBUG=false
    restart: unless-stopped
    
  frontend:
    image: chatter-frontend:production
    restart: unless-stopped
    
  nginx:
    profiles: []  # Enable nginx for production
EOF
    print_success "Production override created"
fi

# Stop here if build-only
if [ "$BUILD_ONLY" = true ]; then
    print_success "Build completed successfully!"
    echo ""
    echo "🐳 Built containers:"
    echo "   • chatter-backend:$ENVIRONMENT"
    echo "   • chatter-frontend:$ENVIRONMENT"
    echo ""
    echo "To deploy, run: docker-compose --env-file $DOCKER_ENV_FILE up -d"
    exit 0
fi

# Deploy containers
print_header "Deploying Application"

print_status "Stopping existing containers..."
docker-compose --env-file $DOCKER_ENV_FILE down 2>/dev/null || true

print_status "Starting new containers..."
docker-compose --env-file $DOCKER_ENV_FILE up -d

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 10

# Health check
print_header "Performing Health Check"

MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -f http://localhost:8003/api/fetchSetting >/dev/null 2>&1; then
        print_success "Backend is responding"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
        print_error "Backend health check failed after $MAX_RETRIES attempts"
        print_status "Check logs with: docker-compose logs backend"
        exit 1
    fi
    
    print_status "Waiting for backend to start... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

# Check frontend
if curl -f http://localhost:3000 >/dev/null 2>&1; then
    print_success "Frontend is responding"
else
    print_warning "Frontend may not be responding properly"
fi

# Final deployment summary
print_header "Deployment Complete! 🎉"

echo ""
echo "🌐 Application URLs:"
echo "   • Backend API: http://localhost:8003/api/"
echo "   • Admin Panel: http://localhost:8003/admin"
echo "   • Frontend: http://localhost:3000"
if docker-compose ps database-manager 2>/dev/null | grep -q "Up"; then
    echo "   • Database Manager: http://localhost:8080"
fi

echo ""
echo "🔧 Management Commands:"
echo "   • View logs: docker-compose logs -f [service]"
echo "   • Stop services: docker-compose down"
echo "   • Update: git pull && $0"
echo "   • Backup database: docker cp chatter-backend:/var/www/html/database/database.sqlite backup-$(date +%Y%m%d).sqlite"

echo ""
echo "📊 Container Status:"
docker-compose ps

echo ""
print_success "Chatter Social Media App deployed successfully in $ENVIRONMENT mode!"

if [ "$ENVIRONMENT" = "production" ]; then
    echo ""
    print_warning "Production Checklist:"
    echo "   • Update .env.production with real credentials"
    echo "   • Set up SSL certificates"
    echo "   • Configure domain names"
    echo "   • Set up backup procedures"
    echo "   • Configure monitoring"
    echo "   • Review security settings"
fi