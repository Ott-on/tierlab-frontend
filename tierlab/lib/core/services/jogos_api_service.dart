import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/jogos_model.dart'; // Ajuste o caminho do import conforme seu projeto

class JogosApiService {
  static final JogosApiService _instance = JogosApiService._internal();

  factory JogosApiService() => _instance;

  JogosApiService._internal();

  // Mantemos o bypass do ngrok aqui também
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // ==========================================
  // GET: /api/Jogos
  // ==========================================
  Future<List<JogoModel>> obterTodosJogos() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Jogos');

    try {
      final response = await http.get(uri, headers: _headers);
      return _tratarRespostaLista(response);
    } catch (e) {
      throw Exception('Erro de conexão ao buscar jogos: $e');
    }
  }

  // ==========================================
  // GET: /api/Jogos/busca
  // ==========================================
  /// Exemplo de uso: buscarJogos({'titulo': 'Zelda'})
  Future<List<JogoModel>> buscarJogos(Map<String, String> queryParams) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/Jogos/busca',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: _headers);
      return _tratarRespostaLista(response);
    } catch (e) {
      throw Exception('Erro de conexão ao pesquisar jogos: $e');
    }
  }

  // ==========================================
  // FUNÇÕES AUXILIARES
  // ==========================================

  /// Trata o retorno e já converte diretamente para uma Lista de JogoModel
  List<JogoModel> _tratarRespostaLista(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return [];

      final body = jsonDecode(response.body);

      if (body is List) {
        // Mapeia cada item da lista (JSON) para um JogoModel
        return body.map((item) => JogoModel.fromJson(item)).toList();
      }

      if (body is Map<String, dynamic> &&
          body['title'] == 'Internal Server Error') {
        throw Exception('Erro interno do servidor ao buscar jogos.');
      }

      return [];
    }

    if (response.statusCode == 500) {
      throw Exception('Erro interno na API (500).');
    }

    throw Exception(
      'Erro ao buscar jogos (${response.statusCode}): ${response.body}',
    );
  }
}
