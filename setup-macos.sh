#!/bin/bash

# Chatter Social Media App - macOS Setup Script
# This script automates the setup process on macOS

echo "🎭 Chatter Social Media App - macOS Setup"
echo "=========================================="

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

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS. Use setup.sh for other platforms."
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "README.md" ] || [ ! -d "chatter_backend" ] || [ ! -d "chatter" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

print_status "Checking and installing prerequisites for macOS..."

# Check and install Homebrew
if ! command -v brew &> /dev/null; then
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_success "Homebrew installed"
else
    print_success "Homebrew already installed"
fi

# Check and install PHP
if ! command -v php &> /dev/null; then
    print_status "Installing PHP..."
    brew install php
    print_success "PHP installed"
else
    php_version=$(php -v | head -n1 | cut -d' ' -f2)
    print_success "PHP $php_version already installed"
fi

# Check and install Composer
if ! command -v composer &> /dev/null; then
    print_status "Installing Composer..."
    brew install composer
    print_success "Composer installed"
else
    print_success "Composer already installed"
fi

# Check and install Node.js
if ! command -v node &> /dev/null; then
    print_status "Installing Node.js..."
    brew install node
    print_success "Node.js installed"
else
    node_version=$(node --version)
    print_success "Node.js $node_version already installed"
fi

# Check and install Flutter
if ! command -v flutter &> /dev/null; then
    print_status "Installing Flutter..."
    brew install --cask flutter
    print_success "Flutter installed"
    
    # Configure Flutter
    print_status "Configuring Flutter..."
    flutter config --enable-web
    flutter doctor
else
    print_success "Flutter already installed"
fi

# Install Xcode Command Line Tools if needed
if ! xcode-select -p &> /dev/null; then
    print_status "Installing Xcode Command Line Tools..."
    xcode-select --install
    print_warning "Please complete the Xcode Command Line Tools installation and run this script again"
    exit 1
fi

print_success "All prerequisites installed!"

# Run the main setup script
print_status "Running main setup script..."
./setup.sh

print_success "macOS setup completed!"

echo ""
echo "🍎 macOS Specific Notes:"
echo "======================="
echo ""
echo "• For iOS development, install Xcode from the App Store"
echo "• Flutter Doctor output saved to logs/flutter-doctor.log"
echo "• Use 'brew services' to manage background services"
echo ""
echo "📱 iOS Development:"
echo "• flutter run (for iOS simulator)"
echo "• flutter build ios (for device/App Store)"
echo ""
echo "🔧 Development Tools:"
echo "• VS Code: brew install --cask visual-studio-code"
echo "• Android Studio: brew install --cask android-studio"
echo ""