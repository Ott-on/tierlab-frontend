import '../models/game_model.dart';

class HomeController {
  final List<Game> games = [
    Game(
      name: 'Sonic Mania',
      description: 'Aventura clássica em alta velocidade.',
      image:
          'https://cdn1.epicgames.com/45e7cf3c49054f2fb20b673d9b0ae69e/offer/EGS_SonicMania_Lab42_S5-1360x765-31b5379f91e2451e57e0273339bf68b8.jpg',
    ),
    Game(
      name: 'Resident Evil 4',
      description: 'Survival horror com ação intensa.',
      image:
          'https://store-images.s-microsoft.com/image/apps.17229.14157056169306105.30ae0432-c36b-42e7-9bbb-f85189243ca3.c5486ade-9a07-47ba-a2c5-4e717b3f183a?q=90&w=336&h=200',
    ),
    Game(
      name: 'Hades',
      description: 'Roguelike frenético inspirado na mitologia.',
      image:
          'https://lojaibyte.vteximg.com.br/arquivos/ids/405817/jogo-hades-ps4.jpg',
    ),
  ];
}
