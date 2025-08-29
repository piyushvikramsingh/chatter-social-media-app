import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_credentials.dart';

/// Quick test script to verify Supabase configuration
/// This is a standalone test file to verify connection
Future<void> testSupabaseConnection() async {
  try {
    print('🔄 Initializing Supabase with IPv4 pooler configuration...');
    
    await Supabase.initialize(
      url: SupabaseCredentials.supabaseUrl,
      anonKey: SupabaseCredentials.supabaseKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
        timeout: Duration(seconds: 30),
      ),
      postgrestOptions: const PostgrestClientOptions(
        schema: 'public',
      ),
    );
    
    print('✅ Supabase initialized successfully');
    
    // Test basic connectivity
    final client = Supabase.instance.client;
    
    // Test settings table access
    print('🔄 Testing settings table access...');
    final response = await client
        .from('settings')
        .select('id, app_name')
        .limit(1);
    
    print('✅ Settings query successful: ${response.length} records found');
    
    if (response.isNotEmpty) {
      print('📋 App Name: ${response.first['app_name'] ?? 'Not set'}');
    }
    
    print('✅ All Supabase connection tests passed!');
    print('🌐 Using IPv4-compatible pooler: ${SupabaseCredentials.poolerHost}:${SupabaseCredentials.poolerPort}');
    
  } catch (e) {
    print('❌ Supabase connection test failed: $e');
    rethrow;
  }
}

/// Test the connection when this file is run
void main() async {
  await testSupabaseConnection();
}
