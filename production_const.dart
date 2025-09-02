// Production Configuration for Chatter App
// Copy this content to lib/utilities/const.dart when deploying to production

import 'package:flutter/material.dart';

const String appName = "Chatter";

// 🚀 PRODUCTION CONFIGURATION
// Update these URLs with your actual production backend URL
const String baseURL = "https://your-backend-domain.com/"; // Replace with your actual domain
const String itemBaseURL = "";
const String apiURL = "${baseURL}api/";
const String termsURL = "${baseURL}termsOfUse";
const String privacyURL = "${baseURL}privacyPolicy";
const String helpURL = "https://your-help-domain.com"; // Replace with your help/support URL
const String notificationTopic = "chatter"; // Do not change it

// 🔥 Firebase Configuration (if using Firebase for notifications)
// Configure these in your Firebase console
const String firebaseServerKey = "YOUR_FIREBASE_SERVER_KEY";

// 💳 In-App Purchase Configuration
// Configure these for your app store products
const String premiumSubscriptionId = "chatter_premium_monthly";
const String premiumYearlyId = "chatter_premium_yearly";

// 📊 Analytics Configuration
const String googleAnalyticsId = "GA_MEASUREMENT_ID";

// 🎨 App Theme Configuration
const Color primaryColor = Color(0xFF6C5CE7);
const Color secondaryColor = Color(0xFF74B9FF);

// 📱 App Store Links
const String playStoreUrl = "https://play.google.com/store/apps/details?id=com.yourcompany.chatter";
const String appStoreUrl = "https://apps.apple.com/app/chatter/id123456789";

// 🌐 Social Media Links
const String websiteUrl = "https://your-website.com";
const String supportEmail = "support@your-domain.com";
const String privacyPolicyUrl = "https://your-website.com/privacy";
const String termsOfServiceUrl = "https://your-website.com/terms";

// 🔧 App Configuration
const int maxFileUploadSizeMB = 50;
const int maxVideoLengthSeconds = 60;
const int storyDurationHours = 24;
const int postsPerPage = 20;

// 🎵 Audio Room Configuration
const int maxRoomParticipants = 20;
const int maxRoomDurationHours = 4;

// 📝 Content Limits
const int maxPostLength = 500;
const int maxBioLength = 150;
const int maxUsernameLength = 30;

// 🔔 Notification Settings
const bool enablePushNotifications = true;
const bool enableInAppNotifications = true;

// 🌍 Supported Languages
const List<String> supportedLanguages = [
  'en', // English
  'es', // Spanish  
  'fr', // French
  'de', // German
  'it', // Italian
  'pt', // Portuguese
  'ar', // Arabic
  'hi', // Hindi
  'zh', // Chinese
  'ja', // Japanese
];

// 📍 Default Configuration
const String defaultLanguage = 'en';
const String defaultCountry = 'US';
const String appVersion = '1.0.0';
const String buildNumber = '1';

// 🎯 Feature Flags
const bool enableStories = true;
const bool enableReels = true;
const bool enableAudioRooms = true;
const bool enableDirectMessages = true;
const bool enableGroupMessages = true;
const bool enablePaidSubscription = true;
const bool enableProfileVerification = true;

// 🔐 Security Configuration
const bool enableBiometricAuth = true;
const bool enableTwoFactorAuth = true;
const int sessionTimeoutMinutes = 60;

// 📈 Performance Configuration
const int imageCompressionQuality = 80;
const int videoCompressionQuality = 70;
const bool enableImageCaching = true;
const bool enableLazyLoading = true;

// 💰 Monetization Configuration
const bool enableAds = true;
const String admobAppId = "YOUR_ADMOB_APP_ID";
const String bannerAdUnitId = "YOUR_BANNER_AD_UNIT_ID";
const String interstitialAdUnitId = "YOUR_INTERSTITIAL_AD_UNIT_ID";
const String rewardedAdUnitId = "YOUR_REWARDED_AD_UNIT_ID";

// 🎨 UI Configuration
const double borderRadius = 12.0;
const double cardElevation = 2.0;
const double appBarElevation = 0.0;

// 📱 Platform Specific Configuration
class PlatformConfig {
  static const String androidPackageName = "com.yourcompany.chatter";
  static const String iosAppId = "123456789";
  static const String iosBundleId = "com.yourcompany.chatter";
}

// 🔗 Deep Links Configuration
class DeepLinks {
  static const String scheme = "chatter";
  static const String host = "app";
  static const String profilePath = "/profile";
  static const String postPath = "/post";
  static const String reelPath = "/reel";
  static const String roomPath = "/room";
}

// 📊 Error Tracking Configuration
const String sentryDsn = "YOUR_SENTRY_DSN";
const bool enableCrashlytics = true;
const bool enableErrorReporting = true;
