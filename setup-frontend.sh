#!/bin/bash

# Chatter Social Media App - Flutter Frontend Setup Script
# This script automates the Flutter frontend setup process

set -e  # Exit on any error

echo "📱 Setting up Chatter Frontend (Flutter)"
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
if [ ! -d "chatter" ]; then
    print_error "chatter directory not found. Please run this script from the project root."
    exit 1
fi

cd chatter

# Check prerequisites
print_status "Checking prerequisites..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed."
    print_status "Installing Flutter SDK..."
    
    # Detect OS and install Flutter accordingly
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        print_status "Detected Linux, installing Flutter..."
        cd /tmp
        wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
        tar xf flutter_linux_3.24.5-stable.tar.xz
        export PATH="$PATH:/tmp/flutter/bin"
        cd - > /dev/null
        print_success "Flutter installed temporarily for this session"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        print_error "Please install Flutter manually on macOS from https://flutter.dev/docs/get-started/install/macos"
        exit 1
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        print_error "Please install Flutter manually on Windows from https://flutter.dev/docs/get-started/install/windows"
        exit 1
    else
        print_error "Unsupported OS. Please install Flutter manually from https://flutter.dev/docs/get-started/install"
        exit 1
    fi
fi

# Verify Flutter installation
print_status "Verifying Flutter installation..."
flutter --version
print_success "Flutter detected"

# Run Flutter doctor to check setup
print_status "Running Flutter doctor..."
flutter doctor

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean
print_success "Build cache cleaned"

# Get Flutter dependencies
print_status "Getting Flutter dependencies..."
flutter pub get
print_success "Flutter dependencies installed"

# Check if Android toolchain is available for building APK
print_status "Checking build capabilities..."
if flutter doctor --verbose 2>&1 | grep -q "Android toolchain.*✓"; then
    print_success "Android toolchain available - APK builds supported"
    ANDROID_BUILD=true
else
    print_warning "Android toolchain not available - APK builds will be skipped"
    ANDROID_BUILD=false
fi

# Create build directory if it doesn't exist
mkdir -p build

# Build for web (most universally available)
print_status "Building Flutter web app..."
flutter build web --release
print_success "Web build completed"

# Build Android APK if possible
if [ "$ANDROID_BUILD" = true ]; then
    print_status "Building Android APK..."
    flutter build apk --release
    print_success "Android APK build completed"
    
    # Show APK location
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        print_success "APK available at: build/app/outputs/flutter-apk/app-release.apk"
    fi
else
    print_warning "Skipping Android build due to missing toolchain"
fi

# Run basic tests
print_status "Running Flutter tests..."
if [ -d "test" ] && [ "$(ls -A test)" ]; then
    flutter test
    print_success "Tests completed"
else
    print_warning "No tests found to run"
fi

print_success "Frontend setup completed successfully!"

if [ "$ANDROID_BUILD" = true ]; then
    print_status "You can run the app with: flutter run"
    print_status "Or install the APK: build/app/outputs/flutter-apk/app-release.apk"
fi

print_status "Web version available in: build/web/"

echo ""
echo -e "${GREEN}✅ Frontend setup complete!${NC}"