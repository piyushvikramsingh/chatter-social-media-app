#!/bin/bash

# 🚀 Chatter App Quick Deploy Script
# This script helps prepare your app for live deployment

echo "🎯 Chatter App - Quick Deploy Setup"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current directory
CURRENT_DIR=$(pwd)
BACKEND_DIR="$CURRENT_DIR/chatter_backend"
FRONTEND_DIR="$CURRENT_DIR/chatter"

echo -e "${BLUE}📍 Working directory: $CURRENT_DIR${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
echo -e "\n${YELLOW}🔍 Checking dependencies...${NC}"

if command_exists php; then
    echo -e "${GREEN}✅ PHP found: $(php --version | head -n1)${NC}"
else
    echo -e "${RED}❌ PHP not found. Please install PHP 8.0+${NC}"
    exit 1
fi

if command_exists composer; then
    echo -e "${GREEN}✅ Composer found${NC}"
else
    echo -e "${RED}❌ Composer not found. Please install Composer${NC}"
    exit 1
fi

if command_exists flutter; then
    echo -e "${GREEN}✅ Flutter found: $(flutter --version | head -n1)${NC}"
else
    echo -e "${RED}❌ Flutter not found. Please install Flutter${NC}"
    exit 1
fi

# Prepare Backend
echo -e "\n${YELLOW}🔧 Preparing Laravel Backend...${NC}"
cd "$BACKEND_DIR"

if [ ! -f ".env" ]; then
    echo -e "${YELLOW}📝 Creating .env file...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✅ .env file created${NC}"
else
    echo -e "${GREEN}✅ .env file already exists${NC}"
fi

echo -e "${YELLOW}📦 Installing composer dependencies...${NC}"
composer install --optimize-autoloader --no-dev

echo -e "${YELLOW}🔑 Generating application key...${NC}"
php artisan key:generate

echo -e "${YELLOW}🗄️ Running database migrations...${NC}"
php artisan migrate --force

echo -e "${YELLOW}💾 Caching configurations...${NC}"
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Build Flutter Web
echo -e "\n${YELLOW}🌐 Building Flutter Web App...${NC}"
cd "$FRONTEND_DIR"

echo -e "${YELLOW}📱 Getting Flutter dependencies...${NC}"
flutter pub get

echo -e "${YELLOW}🏗️ Building web version...${NC}"
flutter build web --release

# Build Android APK
echo -e "\n${YELLOW}📱 Building Android APK...${NC}"
flutter build apk --release

echo -e "\n${GREEN}🎉 Build Complete!${NC}"
echo -e "${GREEN}===================${NC}"
echo -e "${BLUE}📁 Files ready for deployment:${NC}"
echo -e "   • Backend: $BACKEND_DIR"
echo -e "   • Web App: $FRONTEND_DIR/build/web"
echo -e "   • Android APK: $FRONTEND_DIR/build/app/outputs/flutter-apk/app-release.apk"

echo -e "\n${YELLOW}🚀 Next Steps:${NC}"
echo -e "1. Update production URLs in const.dart"
echo -e "2. Configure production database in .env"
echo -e "3. Deploy backend to hosting platform"
echo -e "4. Deploy web app to Firebase/Netlify"
echo -e "5. Upload APK to Google Play Store"

echo -e "\n${BLUE}📖 For detailed instructions, see: LIVE_DEPLOYMENT_GUIDE.md${NC}"

# Return to original directory
cd "$CURRENT_DIR"

echo -e "\n${GREEN}✨ Ready for live deployment!${NC}"
