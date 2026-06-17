// ==========================================
// REQUESTS (O que enviamos para a API)
// ==========================================

/// Request para a rota PATCH /api/Users/me
class UpdateUsuarioMeRequest {
  final String username;
  final String imageUrl;
  final String bio;
  final bool perfilPublico;

  const UpdateUsuarioMeRequest({
    required this.username,
    required this.imageUrl,
    required this.bio,
    required this.perfilPublico,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'imageUrl': imageUrl,
    'bio': bio,
    'perfilPublico': perfilPublico,
  };
}

/// Request para a rota POST /api/Users/{usuarioId}/jogos
class AddUsuarioJogoRequest {
  final int jogoId;
  final String status;
  final int nota;
  final int horasJogadas;

  const AddUsuarioJogoRequest({
    required this.jogoId,
    required this.status,
    required this.nota,
    required this.horasJogadas,
  });

  Map<String, dynamic> toJson() => {
    'jogoId': jogoId,
    'status': status,
    'nota': nota,
    'horasJogadas': horasJogadas,
  };
}

/// Request para a rota PATCH /api/Users/{usuarioId}/jogos/{jogoId}
class UpdateUsuarioJogoRequest {
  final String status;
  final int nota;
  final int horasJogadas;

  const UpdateUsuarioJogoRequest({
    required this.status,
    required this.nota,
    required this.horasJogadas,
  });

  Map<String, dynamic> toJson() => {
    'status': status,
    'nota': nota,
    'horasJogadas': horasJogadas,
  };
}

// ==========================================
// MODELS / RESPONSES (O que recebemos da API)
// ==========================================

class UserModel {
  final String id;
  final String username;
  final String imageUrl;
  final String bio;
  final bool perfilPublico;

  const UserModel({
    required this.id,
    required this.username,
    required this.imageUrl,
    required this.bio,
    required this.perfilPublico,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      bio: json['bio'] ?? '',
      perfilPublico: json['perfilPublico'] ?? false,
    );
  }
}

class UsuarioJogoModel {
  final int jogoId;
  final String status;
  final int nota;
  final int horasJogadas;
  // Caso a API GET retorne dados adicionais como o nome do jogo, você pode adicionar aqui:
  // final String? nomeJogo;

  const UsuarioJogoModel({
    required this.jogoId,
    required this.status,
    required this.nota,
    required this.horasJogadas,
  });

  factory UsuarioJogoModel.fromJson(Map<String, dynamic> json) {
    return UsuarioJogoModel(
      // Se vier como int ou string, o parse garante que vire int
      jogoId: json['jogoId'] != null
          ? int.tryParse(json['jogoId'].toString()) ?? 0
          : 0,
      status: json['status'] ?? '',
      nota: json['nota'] != null
          ? int.tryParse(json['nota'].toString()) ?? 0
          : 0,
      horasJogadas: json['horasJogadas'] != null
          ? int.tryParse(json['horasJogadas'].toString()) ?? 0
          : 0,
    );
  }
}
