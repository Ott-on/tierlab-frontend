import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl {
    // Web: ler de --dart-define (compilação)
    if (kIsWeb) {
      const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
      return url;
    }
    
    // Mobile/Desktop: ler de .env
    final value = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    return value;
  }

  static String get supabaseAnonKey {
    // Web: ler de --dart-define (compilação)
    if (kIsWeb) {
      const key = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
      return key;
    }
    
    // Mobile/Desktop: ler de .env
    final value = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
    return value;
  }
}