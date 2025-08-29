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

### Prerequisites
- **Flutter SDK** (3.0+)
- **PHP** (8.0+)
- **Composer**
- **Node.js** (for Laravel Mix)
- **Android Studio** / **Xcode**

### 🔧 Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd chatter_backend
   ```

2. **Install dependencies:**
   ```bash
   composer install
   npm install
   ```

3. **Start the server:**
   ```bash
   php artisan serve --host=127.0.0.1 --port=8003
   ```

4. **Access admin panel:**
   - URL: `http://127.0.0.1:8003`
   - Username: `admin`
   - Password: `password`

### 📱 Flutter App Setup

1. **Navigate to Flutter directory:**
   ```bash
   cd chatter
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### 🔑 API Configuration

The app uses API key authentication. Make sure your API calls include:
```
Headers: {
  "Content-Type": "application/json",
  "APIKEY": "123"
}
```

## 📦 Built APK Files

Pre-built APK files are available in `chatter/build/app/outputs/flutter-apk/`:
- `app-debug.apk` (368MB) - Debug build
- `app-release.apk` (338MB) - Production build

## 🌐 Deployment

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
