import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

class UserApiService {
  static final UserApiService _instance = UserApiService._internal();

  factory UserApiService() => _instance;

  UserApiService._internal();

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  /// Garante que o usuário autenticado no Supabase exista na API C#.
  Future<void> sincronizarUsuario({
    required String usuarioId,
    required String email,
    String? username,
    String? imageUrl,
  }) async {
    final query = <String, String>{
      'usuarioId': usuarioId,
      'email': email,
      if (username != null && username.isNotEmpty) 'username': username,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Users/me')
        .replace(queryParameters: query);

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(
      'Erro ao sincronizar usuário (${response.statusCode}): ${response.body}',
    );
  }
}
