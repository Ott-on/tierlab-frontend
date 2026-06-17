import 'jogos_model.dart';

// ==========================================
// REQUESTS (O que enviamos para a API)
// ==========================================

class CreateTierlistRequest {
  final String usuarioId;
  final String titulo;
  final String descricao;
  final String imageUrl;
  final String visibilidade;

  const CreateTierlistRequest({
    required this.usuarioId,
    required this.titulo,
    required this.descricao,
    required this.imageUrl,
    required this.visibilidade,
  });

  Map<String, dynamic> toJson() => {
    'usuarioId': usuarioId,
    'titulo': titulo,
    'descricao': descricao,
    'imageUrl': imageUrl,
    'visibilidade': visibilidade,
  };
}

/// Request para a rota POST /api/Tierlists/{tierlistId}/jogos
class AddJogoRequest {
  final String jogoId;
  final String tier;
  final String posicao; // Exemplo: "1" para o primeiro jogo da tier

  const AddJogoRequest({
    required this.jogoId,
    required this.tier,
    required this.posicao,
  });

  Map<String, dynamic> toJson() => {
    'jogoId': jogoId,
    'tier': tier,
    'status': tier, // Envia tanto 'tier' quanto 'status' para compatibilidade
    'posicao': posicao,
  };
}

// ==========================================
// MODELS / RESPONSES (O que recebemos da API)
// ==========================================

class TierlistModel {
  final String id; // A API C# geralmente retorna um Id (Guid ou Int)
  final String usuarioId;
  final String titulo;
  final String descricao;
  final String imageUrl;
  final String visibilidade;
  final List<JogoModel>? jogos; // Pode vir nulo dependendo da rota

  const TierlistModel({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.descricao,
    required this.imageUrl,
    required this.visibilidade,
    this.jogos,
  });

  factory TierlistModel.fromJson(Map<String, dynamic> json) {
    return TierlistModel(
      // Se a sua API C# usar "Id" com i maiúsculo, altere aqui: json['Id']
      id: json['id']?.toString() ?? '',
      usuarioId: json['usuarioId']?.toString() ?? '',
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      visibilidade: json['visibilidade'] ?? '',
      // Mapeia a lista de jogos se ela vier no JSON
      jogos: json['jogos'] != null
          ? (json['jogos'] as List)
                .map((item) => JogoModel.fromJson(item))
                .toList()
          : null,
    );
  }
}


