import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço simplificado para interações com Supabase
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  /// Getter para o cliente Supabase
  SupabaseClient get client => Supabase.instance.client;

  /// Getter para o usuário autenticado atual
  User? get currentUser => client.auth.currentUser;

  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => currentUser != null;

  /// Faz login com email e senha
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Registra um novo usuário
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Faz logout do usuário atual
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}