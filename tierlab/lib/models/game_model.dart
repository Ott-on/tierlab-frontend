class Game {
  final String name;
  final String description;
  final String image;

  Game({required this.name, required this.description, required this.image});

  factory Game.fromMap(Map<String, String> map) {
    return Game(
      name: map['name']!,
      description: map['description']!,
      image: map['image']!,
    );
  }
}
