import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'views/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carregar .env apenas em mobile/desktop
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Aviso: Não foi possível carregar .env: $e');
    }
  }

  // Inicializar Supabase com credenciais
  // Web: --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  // Mobile/Desktop: .env
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tierlab',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E2E2E),
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
