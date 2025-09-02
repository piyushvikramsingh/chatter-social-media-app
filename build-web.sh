#!/bin/bash

# 🌐 Build Flutter Web without Audio Features
# This script creates a web-compatible version by temporarily excluding audio room features

echo "🌐 Building Chatter Web App (without audio rooms)..."

cd chatter

# Create temporary web-only pubspec.yaml
cp pubspec.yaml pubspec.yaml.backup

# Remove problematic web dependencies
sed -i '' '/agora_rtc_engine:/d' pubspec.yaml
sed -i '' '/agora_uikit:/d' pubspec.yaml

echo "📦 Getting dependencies..."
flutter pub get

echo "🏗️ Building for web..."
flutter build web --release --web-renderer html

# Restore original pubspec.yaml
mv pubspec.yaml.backup pubspec.yaml

echo "✅ Web build complete!"
echo "📁 Location: build/web/"
echo "🚀 Deploy this folder to any web hosting service"

# Instructions
echo ""
echo "🎯 Quick Deployment Options:"
echo "1. Firebase Hosting: firebase deploy --only hosting"
echo "2. Netlify: Drag & drop build/web folder"
echo "3. Vercel: Connect GitHub repo"
echo "4. GitHub Pages: Upload to gh-pages branch"
