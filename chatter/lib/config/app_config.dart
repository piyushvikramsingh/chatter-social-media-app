// Production Configuration for AWS Deployment
class ProductionConfig {
  // API Configuration
  static const String baseUrl = 'https://your-domain.com/api/';
  static const String mediaBaseUrl = 'https://chatter-app-storage-prod.s3.amazonaws.com/';
  
  // AWS S3 Configuration
  static const String awsRegion = 'us-east-1';
  static const String s3Bucket = 'chatter-app-storage-prod';
  
  // App Configuration
  static const String appName = 'Chatter';
  static const String appVersion = '1.0.0';
  
  // Firebase Configuration (for push notifications)
  static const String firebaseProjectId = 'your-firebase-project-id';
  
  // Agora Configuration (for video calls)
  static const String agoraAppId = 'your-agora-app-id';
  
  // Development vs Production
  static const bool isProduction = true;
  static const bool enableDebugLogging = false;
  
  // API Timeouts
  static const int apiTimeoutSeconds = 30;
  static const int uploadTimeoutSeconds = 120;
  
  // File Upload Limits
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 100;
  static const int maxAudioSizeMB = 25;
}

// Development Configuration
class DevelopmentConfig {
  static const String baseUrl = 'http://localhost:8003/api/';
  static const String mediaBaseUrl = 'http://localhost:8003/storage/';
  static const bool isProduction = false;
  static const bool enableDebugLogging = true;
}

// Environment selector
class AppConfig {
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  
  static String get baseUrl => isProduction 
    ? ProductionConfig.baseUrl 
    : DevelopmentConfig.baseUrl;
    
  static String get mediaBaseUrl => isProduction 
    ? ProductionConfig.mediaBaseUrl 
    : DevelopmentConfig.mediaBaseUrl;
    
  static bool get enableDebugLogging => isProduction 
    ? ProductionConfig.enableDebugLogging 
    : DevelopmentConfig.enableDebugLogging;
}
