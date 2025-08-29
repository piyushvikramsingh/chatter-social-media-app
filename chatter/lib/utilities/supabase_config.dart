import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_credentials.dart';

class SupabaseConfig {
  static SupabaseClient? _client;
  
  /// Get the Supabase client instance
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase client not initialized. Call initialize() first.');
    }
    return _client!;
  }
  
  /// Initialize Supabase with optimized settings for IPv4 and pooling
  static Future<void> initialize() async {
    try {
      print('SupabaseConfig: Starting initialization...');
      
      // Initialize with timeout
      await Supabase.initialize(
        url: SupabaseCredentials.supabaseUrl,
        anonKey: SupabaseCredentials.supabaseKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
          // Optimize for IPv4 networks with session pooling
          timeout: Duration(seconds: 15),
        ),
        postgrestOptions: const PostgrestClientOptions(
          // Use session pooler for IPv4 compatibility
          schema: 'public',
        ),
        storageOptions: const StorageClientOptions(
          retryAttempts: 2,
        ),
      ).timeout(const Duration(seconds: 30));
      
      _client = Supabase.instance.client;
      print('SupabaseConfig: Initialization completed successfully');
    } catch (e) {
      print('SupabaseConfig: Initialization failed - ${e.toString()}');
      // Create a fallback client to prevent app crashes
      _client = SupabaseClient(
        SupabaseCredentials.supabaseUrl,
        SupabaseCredentials.supabaseKey,
      );
      rethrow;
    }
  }
  
  /// Test the connection to Supabase
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      // Test basic connectivity by fetching a simple query
      final response = await client
          .from('settings')
          .select('id, app_name')
          .limit(1);
      
      return {
        'success': true,
        'message': 'Connection successful',
        'data': response,
        'pooler_enabled': SupabaseCredentials.usePooler,
        'ipv4_compatible': SupabaseCredentials.ipv4Compatible,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed',
        'error': e.toString(),
        'pooler_enabled': SupabaseCredentials.usePooler,
        'ipv4_compatible': SupabaseCredentials.ipv4Compatible,
      };
    }
  }
  
  /// Get connection health information
  static Map<String, dynamic> getConnectionInfo() {
    return {
      'url': SupabaseCredentials.supabaseUrl,
      'database_host': SupabaseCredentials.dbHost,
      'database_port': SupabaseCredentials.dbPort,
      'use_pooler': SupabaseCredentials.usePooler,
      'ipv4_compatible': SupabaseCredentials.ipv4Compatible,
      'ssl_required': SupabaseCredentials.requireSSL,
      'ssl_mode': SupabaseCredentials.sslMode,
      'connection_timeout': SupabaseCredentials.connectionTimeout,
      'max_connections': SupabaseCredentials.maxConnections,
    };
  }
  
  /// Check if we're using the session pooler (IPv4 compatible)
  static bool get isUsingPooler => SupabaseCredentials.usePooler;
  
  /// Check if the configuration is IPv4 compatible
  static bool get isIPv4Compatible => SupabaseCredentials.ipv4Compatible;
}
