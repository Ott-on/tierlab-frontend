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
    required String username,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  /// Faz logout do usuário atual
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Busca o perfil do usuário na tabela 'usuarios'
  Future<Map<String, dynamic>?> getProfile() async {
    if (currentUser == null) return null;
    try {
      final response = await client
          .from('usuarios')
          .select()
          .eq('id', currentUser!.id)
          .single();
      return response;
    } catch (e) {
      // Pode não haver um perfil ainda se o trigger falhou ou é um usuário antigo
      print('Erro ao buscar perfil: $e');
      return null;
    }
  }

  /// Atualiza o perfil do usuário
  Future<void> updateProfile({
    String? username,
    String? bio,
    bool? isPublic,
  }) async {
    if (currentUser == null) return;
    final updates = <String, dynamic>{};

    if (username != null) {
      updates['username'] = username;
      try {
        await client.auth.updateUser(
          UserAttributes(data: {'username': username}),
        );
      } catch (_) {}
    }
    if (bio != null) {
      updates['bio'] = bio;
    }
    if (isPublic != null) {
      updates['perfil_publico'] = isPublic;
    }

    if (updates.isEmpty) return;

    await client.from('usuarios').update(updates).eq('id', currentUser!.id);
  }
}
