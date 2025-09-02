# 🎭 Chatter - Ultimate Social Media App

A feature-rich social media application built with **Flutter** and **Laravel** backend, offering real-time chat, posts, stories, reels, and audio rooms functionality.

## 🚀 Features

### 📱 Mobile App (Flutter)
- ✅ **User Authentication** - Login, Register, Social Login
- ✅ **Posts & Stories** - Create, share, and interact with content
- ✅ **Reels** - Short video content with music
- ✅ **Audio Rooms** - Voice chat rooms with multiple participants
- ✅ **Real-time Chat** - Private and group messaging
- ✅ **User Profiles** - Customizable profiles with verification
- ✅ **Follow System** - Follow/unfollow users
- ✅ **Interests** - Tag and discover content by interests
- ✅ **Push Notifications** - Firebase messaging integration
- ✅ **Reports & Moderation** - Content reporting system

### 🖥️ Admin Panel (Laravel)
- ✅ **User Management** - View, edit, block users
- ✅ **Content Moderation** - Manage posts, stories, reels
- ✅ **Room Management** - Monitor and control audio rooms
- ✅ **Analytics Dashboard** - User and content statistics
- ✅ **Settings Control** - App configuration and limits
- ✅ **Notification System** - Send platform-wide notifications

## 🛠️ Tech Stack

### Frontend (Mobile)
- **Flutter** - Cross-platform mobile development
- **GetX** - State management
- **Firebase** - Authentication, messaging, analytics
- **Agora** - Real-time voice/video communication

### Backend
- **Laravel 9** - PHP framework
- **SQLite** - Database
- **Firebase Admin SDK** - Push notifications
- **Agora SDK** - Audio/video token generation

## 🏗️ Project Structure

```
chatter-ultimate-social/
├── chatter/                    # Flutter mobile app
│   ├── lib/
│   │   ├── screens/           # UI screens
│   │   ├── models/            # Data models
│   │   ├── common/            # API services & utilities
│   │   └── utilities/         # Constants & helpers
│   ├── android/               # Android configuration
│   ├── ios/                   # iOS configuration
│   └── build/                 # Built APK files
├── chatter_backend/           # Laravel backend
│   ├── app/                   # Laravel application code
│   ├── database/              # Database files & migrations
│   ├── routes/                # API & web routes
│   └── public/                # Web admin panel assets
└── Documentation/             # Project documentation
```

## 🚦 Getting Started

### 🚀 Quick Start (Automated Setup)

**One-command setup for the entire application:**

```bash
# Clone the repository
git clone https://github.com/piyushvikramsingh/chatter-social-media-app.git
cd chatter-social-media-app

# Run automated setup
./setup.sh
```

**Platform-specific setup:**
- **Linux/macOS**: `./setup.sh`
- **macOS with Homebrew**: `./setup-macos.sh`
- **Windows**: `setup-windows.bat`

### 🐳 Docker Deployment (Recommended)

**Deploy with Docker Compose:**
```bash
# Build and start all services
docker-compose up -d

# Access the application
# Backend: http://localhost:8003
# Frontend: http://localhost:3000
# Database Manager: http://localhost:8080
```

**Production deployment:**
```bash
./deploy-production.sh
```

### 📋 Manual Setup (Advanced)

If you prefer manual setup or need to troubleshoot:

#### Prerequisites
- **PHP** (8.0+) - Backend runtime
- **Composer** - PHP dependency manager  
- **Node.js** (16+) - For building assets
- **Flutter SDK** (3.0+) - Mobile app development
- **Docker** (optional) - For containerized deployment

#### Backend Setup
```bash
# Automated backend setup
./setup-backend.sh

# OR Manual setup:
cd chatter_backend
composer install --no-interaction --prefer-dist
npm install
cp .env.example .env
# Edit .env to use SQLite: DB_CONNECTION=sqlite
touch database/database.sqlite
php artisan key:generate
php artisan migrate --force
php artisan db:seed
php artisan serve --host=127.0.0.1 --port=8003
```

#### Frontend Setup
```bash
# Automated frontend setup  
./setup-frontend.sh

# OR Manual setup:
cd chatter
flutter pub get
flutter build web --release
flutter run  # For mobile development
```

### 🔑 API Configuration

The app uses API key authentication. Default configuration:
```
Base URL: http://127.0.0.1:8003/api/
Headers: {
  "Content-Type": "application/json",
  "APIKEY": "123"
}
```

### 🧪 Testing & Health Checks

```bash
# Run comprehensive tests
./run-tests.sh

# Check application health
./health-check.sh

# Test API endpoints
curl -H "APIKEY: 123" http://127.0.0.1:8003/api/fetchSetting
```

## 📦 Built APK Files

Pre-built APK files are available in `chatter/build/app/outputs/flutter-apk/`:
- `app-debug.apk` (368MB) - Debug build
- `app-release.apk` (338MB) - Production build

## 🌐 Deployment

### 🚀 Quick Deployment Options

**Docker Deployment (Recommended):**
```bash
# Development
docker-compose up -d

# Production
./deploy-production.sh
```

**Traditional Deployment:**
```bash
# Backend only
./setup-backend.sh && ./start-backend.sh

# Full stack
./setup.sh
```

### 🐳 Docker Services

When using `docker-compose up -d`, the following services are available:

- **Backend API**: http://localhost:8003/api/
- **Admin Panel**: http://localhost:8003/admin (admin/password)  
- **Frontend Web**: http://localhost:3000
- **Database Manager**: http://localhost:8080

### 🔧 Management Commands

```bash
# Health checks
./health-check.sh

# Run tests  
./run-tests.sh

# Start/stop services
docker-compose up -d
docker-compose down

# View logs
docker-compose logs -f [service]

# Update deployment
git pull && ./deploy-production.sh
```

### AWS Deployment
See `AWS_DEPLOYMENT_GUIDE.md` for detailed AWS deployment instructions.

### Production Checklist
See `PRODUCTION_READINESS_CHECKLIST.md` for production deployment requirements.

## 🧪 Testing

### Backend API Testing
```bash
# Test settings endpoint
curl -X POST -H "APIKEY: 123" http://127.0.0.1:8003/api/fetchSetting

# Test interests endpoint  
curl -X POST -H "APIKEY: 123" http://127.0.0.1:8003/api/fetchInterests
```

### Admin Login Testing
```bash
php test_admin_login.php
```

## 📋 Current Status

✅ **Backend:** Fully functional Laravel API
✅ **Database:** SQLite database with admin access
✅ **Flutter App:** Successfully builds and runs
✅ **API Integration:** Working connectivity between app and backend
✅ **Authentication:** Admin panel accessible
✅ **Build System:** Both debug and release APKs generated

## 🔐 Security Notes

- Change default admin credentials before production
- Update API key from default value (123)
- Configure proper environment variables
- Set up SSL certificates for production
- Review Firebase security rules

## 📚 Documentation

- `IMPLEMENTATION_STATUS.md` - Current implementation status
- `PRODUCTION_READINESS_CHECKLIST.md` - Production deployment checklist
- `SUPABASE_CONFIGURATION.md` - Supabase integration guide
- `AWS_DEPLOYMENT_GUIDE.md` - AWS deployment instructions

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Check the documentation files
- Review the implementation status
- Test using the provided testing scripts

---

**Built with ❤️ using Flutter & Laravel**
