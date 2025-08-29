class SupabaseCredentials {
  static const String supabaseUrl = 'https://soyztcioiefwsjispiar.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNveXp0Y2lvaWVmd3NqaXNwaWFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQzOTg4MzUsImV4cCI6MjAzOTk3NDgzNX0.G3f2LNDBiXCgXEGEeUw0oKIi2ZhCj7kG4pZ8KJjIhRM';
  
  // Database connection settings for PostgreSQL
  static const String dbHost = 'aws-1-ap-southeast-1.pooler.supabase.com';
  static const int dbPort = 6543; // Session pooler port for IPv4 compatibility
  static const String dbName = 'postgres';
  static const String dbUser = 'postgres.soyztcioiefwsjispiar';
  
  // Connection configuration
  static const bool usePooler = true;
  static const bool ipv4Compatible = true;
  static const int connectionTimeout = 30;
  static const int maxConnections = 10;
  
  // SSL Configuration for secure connections
  static const bool requireSSL = true;
  static const String sslMode = 'require';
}
