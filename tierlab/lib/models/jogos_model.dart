class JogoModel {
  final String id;
  final String titulo;
  final String imageUrl;

  const JogoModel({
    required this.id,
    required this.titulo,
    required this.imageUrl,
  });

  factory JogoModel.fromJson(Map<String, dynamic> json) {
    return JogoModel(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'imageUrl': imageUrl,
  };
}
