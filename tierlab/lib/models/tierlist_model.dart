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
