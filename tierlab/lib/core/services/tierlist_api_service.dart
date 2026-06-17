import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/tierlist_model.dart';

class TierlistApiService {
  static final TierlistApiService _instance = TierlistApiService._internal();

  factory TierlistApiService() => _instance;

  TierlistApiService._internal();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  Future<Map<String, dynamic>> criarTierlist(
    CreateTierlistRequest request,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tierlists');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic> &&
          body['title'] == 'Internal Server Error') {
        throw Exception(
          'A API retornou erro interno. Verifique se o usuário existe no backend.',
        );
      }
      return body as Map<String, dynamic>;
    }

    if (response.statusCode == 500) {
      throw Exception(
        'Erro interno na API (500). O usuário pode não estar cadastrado no backend.',
      );
    }

    throw Exception(
      'Erro ao criar tierlist (${response.statusCode}): ${response.body}',
    );
  }
}
