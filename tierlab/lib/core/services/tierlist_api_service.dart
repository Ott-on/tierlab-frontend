import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/tierlist_model.dart'; // Certifique-se de que este import está correto

class TierlistApiService {
  static final TierlistApiService _instance = TierlistApiService._internal();

  factory TierlistApiService() => _instance;

  TierlistApiService._internal();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  
  // ==========================================
  // GET: /api/Tierlists/genero/{generoId}
  // ==========================================
  Future<List<dynamic>> obterPorGenero(String generoId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tierlists/genero/$generoId');
    final response = await http.get(uri, headers: _headers);
    return _tratarRespostaLista(response);
  }

  // ==========================================
  // GET: /api/Tierlists/usuario/{usuarioId}
  // ==========================================
  Future<List<dynamic>> obterPorUsuario(String usuarioId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tierlists/usuario/$usuarioId');
    final response = await http.get(uri, headers: _headers);
    return _tratarRespostaLista(response);
  }

  // ==========================================
  // GET: /api/Tierlists
  // ==========================================
  Future<List<dynamic>> obterTodas() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tierlists');
    final response = await http.get(uri, headers: _headers);
    return _tratarRespostaLista(response);
  }

  // ==========================================
  // POST: /api/Tierlists
  // ==========================================
  Future<Map<String, dynamic>> criarTierlist(
    CreateTierlistRequest request,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tierlists');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    return _tratarResposta(response);
  }

  // ==========================================
  // GET: /api/Tierlists/busca
  // ==========================================
  // Exemplo de uso: buscarTierlists({'termo': 'rpg', 'ano': '2023'})
  Future<List<dynamic>> buscarTierlists(Map<String, String> queryParams) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tierlists/busca')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    return _tratarRespostaLista(response);
  }

  // ==========================================
  // GET: /api/Tierlists/{id}
  // ==========================================
  Future<Map<String, dynamic>> obterPorId(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tierlists/$id');
    final response = await http.get(uri, headers: _headers);
    return _tratarResposta(response);
  }

  // ==========================================
  // POST: /api/Tierlists/{tierlistId}/jogos
  // ==========================================
  Future<Map<String, dynamic>> adicionarJogo(
      String tierlistId, Map<String, dynamic> jogoData) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tierlists/$tierlistId/jogos');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(jogoData),
    );
    return _tratarResposta(response);
  }

  // ==========================================
  // GET: /api/Tierlists/{tierlistId}/jogos
  // ==========================================
  Future<List<dynamic>> obterJogosDaTierlist(String tierlistId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tierlists/$tierlistId/jogos');
    final response = await http.get(uri, headers: _headers);
    return _tratarRespostaLista(response);
  }

  // ==========================================
  // DELETE: /api/Tierlists/{tierlistId}/jogos/{jogoId}
  // ==========================================
  Future<void> removerJogo(String tierlistId, String jogoId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tierlists/$tierlistId/jogos/$jogoId');
    final response = await http.delete(uri, headers: _headers);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return; // Sucesso ao deletar, não retorna corpo
    }
    _lancarErro(response);
  }

  // ==========================================
  // FUNÇÕES AUXILIARES DE TRATAMENTO DE ERRO
  // ==========================================

  /// Trata retornos que devolvem um Objeto (Map)
  Map<String, dynamic> _tratarResposta(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic> && body['title'] == 'Internal Server Error') {
        throw Exception('A API retornou erro interno. Verifique os dados no backend.');
      }
      return body as Map<String, dynamic>;
    }
    _lancarErro(response);
    return {}; // Nunca será chamado devido ao throw acima
  }

  /// Trata retornos que devolvem uma Lista (Array)
  List<dynamic> _tratarRespostaLista(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return [];
      
      final body = jsonDecode(response.body);
      if (body is List) {
        return body;
      }
      // Caso a API retorne um erro formatado como objeto em uma rota de lista
      if (body is Map<String, dynamic> && body['title'] == 'Internal Server Error') {
        throw Exception('A API retornou erro interno.');
      }
      return [];
    }
    _lancarErro(response);
    return [];
  }

  /// Centraliza o lançamento de exceções baseadas no status code
  void _lancarErro(http.Response response) {
    if (response.statusCode == 500) {
      throw Exception('Erro interno na API (500). O recurso pode não existir ou houve falha no servidor.');
    }
    if (response.statusCode == 404) {
      throw Exception('Recurso não encontrado (404).');
    }
    throw Exception('Erro na requisição (${response.statusCode}): ${response.body}');
  }
}