@echo off
REM Chatter Social Media App - Windows Setup Script
REM This script automates the setup process on Windows

echo 🎭 Chatter Social Media App - Windows Setup
echo ============================================

REM Check if we're in the right directory
if not exist "README.md" (
    echo ERROR: Please run this script from the project root directory
    pause
    exit /b 1
)

if not exist "chatter_backend" (
    echo ERROR: chatter_backend directory not found
    pause
    exit /b 1
)

if not exist "chatter" (
    echo ERROR: chatter directory not found
    pause
    exit /b 1
)

echo [INFO] Checking prerequisites...

REM Check PHP
php --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: PHP is not installed or not in PATH
    echo Please install PHP 8.0+ from https://windows.php.net/
    pause
    exit /b 1
)
echo [SUCCESS] PHP detected

REM Check Composer
composer --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Composer is not installed or not in PATH
    echo Please install Composer from https://getcomposer.org/
    pause
    exit /b 1
)
echo [SUCCESS] Composer detected

REM Check Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Node.js not detected, some features may not work
    echo Install from https://nodejs.org/
) else (
    echo [SUCCESS] Node.js detected
)

echo.
echo [INFO] Setting up backend...
cd chatter_backend

REM Install PHP dependencies
echo [INFO] Installing PHP dependencies...
composer install --optimize-autoloader
if %errorlevel% neq 0 (
    echo ERROR: Failed to install PHP dependencies
    cd ..
    pause
    exit /b 1
)

REM Install Node dependencies
echo [INFO] Installing Node.js dependencies...
npm install
if %errorlevel% neq 0 (
    echo WARNING: Failed to install Node.js dependencies
)

REM Setup environment
echo [INFO] Setting up environment...
if not exist ".env" (
    if exist ".env.example" (
        copy ".env.example" ".env"
        echo [SUCCESS] Created .env from .env.example
    ) else (
        echo APP_NAME="Chatter Social Media" > .env
        echo APP_ENV=local >> .env
        echo APP_KEY= >> .env
        echo APP_DEBUG=true >> .env
        echo APP_URL=http://127.0.0.1:8003 >> .env
        echo. >> .env
        echo DB_CONNECTION=sqlite >> .env
        echo DB_DATABASE=database/database.sqlite >> .env
        echo. >> .env
        echo API_KEY=123 >> .env
        echo [SUCCESS] Created basic .env file
    )
)

REM Create database file
echo [INFO] Setting up database...
if not exist "database\database.sqlite" (
    type nul > database\database.sqlite
    echo [SUCCESS] SQLite database file created
)

REM Generate application key
echo [INFO] Generating application key...
php artisan key:generate --force

REM Run migrations
echo [INFO] Running database migrations...
php artisan migrate --force

REM Build assets
echo [INFO] Building frontend assets...
npm run production

echo [SUCCESS] Backend setup completed!

cd ..

echo.
echo [INFO] Setting up frontend...
cd chatter

REM Check Flutter
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/docs/get-started/install/windows
    echo Skipping Flutter setup...
    cd ..
    goto :summary
)

echo [INFO] Getting Flutter dependencies...
flutter pub get

echo [INFO] Building Flutter web app...
flutter build web --release

echo [SUCCESS] Frontend setup completed!

cd ..

:summary
echo.
echo ================================
echo ✅ Setup Complete!
echo ================================
echo.
echo 🖥️  Backend (Laravel):
echo    Start: cd chatter_backend ^&^& php artisan serve --host=127.0.0.1 --port=8003
echo    URL: http://127.0.0.1:8003
echo    Admin: http://127.0.0.1:8003/admin (admin/password)
echo.
echo 📱 Frontend (Flutter):
echo    Run: cd chatter ^&^& flutter run
echo    Web: chatter\build\web\
echo.
echo 🧪 Testing:
echo    Health check: health-check.sh (requires Git Bash or WSL)
echo    Run tests: run-tests.sh (requires Git Bash or WSL)
echo.
echo 📚 Documentation:
echo    README.md - Getting started
echo    AWS_DEPLOYMENT_GUIDE.md - Production deployment
echo.

pause