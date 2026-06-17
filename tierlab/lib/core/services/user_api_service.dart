import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/user_model.dart'; // Certifique-se de que este import está correto

class UserApiService {
  static final UserApiService _instance = UserApiService._internal();

  factory UserApiService() => _instance;

  UserApiService._internal();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // ==========================================
  // GET: /api/Users/me
  // ==========================================
  Future<UserModel> obterPerfilMe() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Users/me');
    final response = await http.get(uri, headers: _headers);

    final data = _tratarResposta(response);
    return UserModel.fromJson(data);
  }

  // ==========================================
  // PATCH: /api/Users/me
  // ==========================================
  // O Swagger mostra que aceita um query param opcional "usuarioId"
  Future<void> atualizarPerfilMe(
    UpdateUsuarioMeRequest request, {
    String? usuarioId,
  }) async {
    Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/Users/me');
    if (usuarioId != null && usuarioId.isNotEmpty) {
      uri = uri.replace(queryParameters: {'usuarioId': usuarioId});
    }

    final response = await http.patch(
      uri,
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) return;
    _lancarErro(response);
  }

  // ==========================================
  // GET: /api/Users/{id}
  // ==========================================
  Future<UserModel> obterUsuarioPorId(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Users/$id');
    final response = await http.get(uri, headers: _headers);

    final data = _tratarResposta(response);
    return UserModel.fromJson(data);
  }

  // ==========================================
  // POST: /api/Users/{usuarioId}/jogos
  // ==========================================
  Future<void> adicionarJogo(
    String usuarioId,
    AddUsuarioJogoRequest request,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Users/$usuarioId/jogos');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) return;
    _lancarErro(response);
  }

  // ==========================================
  // GET: /api/Users/{usuarioId}/jogos
  // ==========================================
  Future<List<UsuarioJogoModel>> obterJogosDoUsuario(String usuarioId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Users/$usuarioId/jogos');
    final response = await http.get(uri, headers: _headers);

    return _tratarRespostaLista(response);
  }

  // ==========================================
  // PATCH: /api/Users/{usuarioId}/jogos/{jogoId}
  // ==========================================
  Future<void> atualizarJogo(
    String usuarioId,
    String jogoId,
    UpdateUsuarioJogoRequest request,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/Users/$usuarioId/jogos/$jogoId',
    );
    final response = await http.patch(
      uri,
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) return;
    _lancarErro(response);
  }

  // ==========================================
  // DELETE: /api/Users/{usuarioId}/jogos/{jogoId}
  // ==========================================
  Future<void> removerJogo(String usuarioId, String jogoId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/Users/$usuarioId/jogos/$jogoId',
    );
    final response = await http.delete(uri, headers: _headers);

    if (response.statusCode >= 200 && response.statusCode < 300) return;
    _lancarErro(response);
  }

  // ==========================================
  // FUNÇÕES AUXILIARES
  // ==========================================

  Map<String, dynamic> _tratarResposta(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic> &&
          body['title'] == 'Internal Server Error') {
        throw Exception('Erro interno da API.');
      }
      return body as Map<String, dynamic>;
    }
    _lancarErro(response);
    return {};
  }

  List<UsuarioJogoModel> _tratarRespostaLista(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return [];
      final body = jsonDecode(response.body);
      if (body is List) {
        return body.map((item) => UsuarioJogoModel.fromJson(item)).toList();
      }
      if (body is Map<String, dynamic> &&
          body['title'] == 'Internal Server Error') {
        throw Exception('Erro interno do servidor ao buscar jogos.');
      }
      return [];
    }
    _lancarErro(response);
    return [];
  }

  void _lancarErro(http.Response response) {
    if (response.statusCode == 500)
      throw Exception('Erro interno no servidor (500).');
    if (response.statusCode == 404)
      throw Exception('Recurso não encontrado (404).');
    throw Exception(
      'Erro na requisição (${response.statusCode}): ${response.body}',
    );
  }
}
