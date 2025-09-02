# 🔧 Chatter Social Media App - Troubleshooting Guide

This guide helps you resolve common issues when setting up and running the Chatter Social Media App.

## 🚀 Quick Fixes

### "Command not found" errors
```bash
# If setup.sh is not executable
chmod +x setup.sh setup-backend.sh setup-frontend.sh health-check.sh run-tests.sh

# If you're on Windows and getting bash errors
# Use Git Bash, WSL, or run setup-windows.bat instead
```

### Database issues
```bash
# If SQLite database file is missing
cd chatter_backend
touch database/database.sqlite
php artisan migrate --force
php artisan db:seed

# If database permissions are wrong
chmod 664 database/database.sqlite
chmod 775 database/
```

### Laravel server won't start
```bash
# Check if .env file exists and is configured
cd chatter_backend
cp .env.example .env
php artisan key:generate

# Check if dependencies are installed
composer install --no-interaction --prefer-dist

# Clear Laravel cache
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

## 📋 Common Issues

### 1. Setup Script Fails

**Problem**: `./setup.sh` exits with errors

**Solutions**:
```bash
# Check prerequisites
php --version     # Should be 8.0+
composer --version
node --version

# Run individual setup scripts
./setup-backend.sh   # Set up Laravel backend only
./setup-frontend.sh  # Set up Flutter frontend only

# Check detailed logs
ls -la logs/
cat logs/backend-setup.log
```

### 2. Composer Install Hangs

**Problem**: Composer asking for GitHub token or hanging

**Solutions**:
```bash
# Use prefer-dist and no-interaction flags
cd chatter_backend
composer install --no-interaction --prefer-dist --ignore-platform-reqs

# If you have rate limiting issues, create a GitHub personal access token
composer config -g github-oauth.github.com YOUR_GITHUB_TOKEN
```

### 3. Flutter Not Found

**Problem**: `flutter: command not found`

**Solutions**:
```bash
# Install Flutter (Linux/macOS)
# See: https://flutter.dev/docs/get-started/install

# On Ubuntu/Debian
sudo snap install flutter --classic

# On macOS with Homebrew
brew install --cask flutter

# Add to PATH
export PATH="$PATH:/usr/local/bin/flutter/bin"
```

### 4. API Endpoints Return Errors

**Problem**: API calls return 500 or database errors

**Solutions**:
```bash
# Check if Laravel server is running
curl http://127.0.0.1:8003

# Check database connection
cd chatter_backend
php artisan migrate:status

# Reseed database if needed
php artisan db:seed

# Check .env configuration
grep DB_ .env
# Should show:
# DB_CONNECTION=sqlite
# DB_DATABASE=/full/path/to/database.sqlite
```

### 5. Docker Issues

**Problem**: Docker containers won't start or build

**Solutions**:
```bash
# Check Docker is running
docker --version
docker-compose --version

# Clean up and rebuild
docker-compose down -v
docker system prune -f
docker-compose build --no-cache

# Check logs
docker-compose logs backend
docker-compose logs frontend

# Test individual container builds
docker build -f Dockerfile.backend -t test-backend .
```

### 6. Permission Denied Errors

**Problem**: Various permission errors on Linux/macOS

**Solutions**:
```bash
# Fix script permissions
chmod +x *.sh

# Fix Laravel storage permissions
cd chatter_backend
chmod -R 775 storage bootstrap/cache
chown -R $USER:www-data storage bootstrap/cache

# Fix database permissions
chmod 664 database/database.sqlite
chmod 775 database/
```

### 7. Port Already in Use

**Problem**: "Port 8003 already in use"

**Solutions**:
```bash
# Find process using port 8003
lsof -i :8003
# or
netstat -tulpn | grep 8003

# Kill the process
kill -9 PID_NUMBER

# Use different port
cd chatter_backend
php artisan serve --host=127.0.0.1 --port=8004
```

### 8. Node.js/npm Issues

**Problem**: npm install fails or Node.js version issues

**Solutions**:
```bash
# Update Node.js (using nvm recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install node
nvm use node

# Clear npm cache
npm cache clean --force

# Install with legacy peer deps if needed
cd chatter_backend
npm install --legacy-peer-deps
```

## 🔍 Debugging Tools

### Health Check Script
```bash
# Comprehensive system check
./health-check.sh

# Check specific components
./health-check.sh | grep -E "(PASS|FAIL)"
```

### Test Runner
```bash
# Run all tests
./run-tests.sh

# Check test logs
ls -la logs/
cat logs/backend-test.log
cat logs/flutter-test.log
```

### Manual API Testing
```bash
# Test basic connectivity
curl http://127.0.0.1:8003

# Test API endpoint
curl -X POST \
  -H "Content-Type: application/json" \
  -H "APIKEY: 123" \
  http://127.0.0.1:8003/api/fetchSetting

# Test admin panel
curl -I http://127.0.0.1:8003/admin
```

### Log Files Location
```bash
# Application logs
tail -f logs/backend-setup.log
tail -f logs/frontend-setup.log
tail -f logs/backend-server.log

# Laravel logs
tail -f chatter_backend/storage/logs/laravel.log

# Docker logs
docker-compose logs -f backend
docker-compose logs -f frontend
```

## 🐛 Advanced Debugging

### Laravel Debugging
```bash
cd chatter_backend

# Enable debug mode
sed -i 's/APP_DEBUG=false/APP_DEBUG=true/' .env

# Clear all caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Run artisan commands to check status
php artisan migrate:status
php artisan route:list
php artisan config:show database
```

### Flutter Debugging
```bash
cd chatter

# Clean and rebuild
flutter clean
flutter pub get

# Run with verbose output
flutter run --verbose

# Check for issues
flutter doctor --verbose
flutter analyze
```

### Database Debugging
```bash
cd chatter_backend

# Check database file exists and has content
ls -la database/database.sqlite
file database/database.sqlite

# Connect to SQLite database
sqlite3 database/database.sqlite
.tables
.schema settings
SELECT * FROM settings LIMIT 1;
.quit
```

## 📞 Getting Help

### Self-Help Resources
1. Run `./health-check.sh` for automated diagnostics
2. Check `logs/` directory for detailed error messages
3. Review this troubleshooting guide
4. Check the main README.md for setup instructions

### Reporting Issues
When reporting issues, please include:
- Operating system and version
- PHP, Node.js, Flutter versions
- Full error messages
- Output of `./health-check.sh`
- Contents of relevant log files

### Quick Recovery Commands
```bash
# Reset everything and start over
./setup.sh --force-rebuild

# Reset just the backend
cd chatter_backend
rm -f .env database/database.sqlite
./setup-backend.sh

# Reset just the frontend
cd chatter
flutter clean
./setup-frontend.sh
```

---

**Remember**: Most issues can be resolved by running `./setup.sh` again or checking the health status with `./health-check.sh`.