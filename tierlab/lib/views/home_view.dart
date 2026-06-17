import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tierlab/views/formulario_tierlist_view.dart';

import '../core/services/tierlist_api_service.dart';
import '../models/tierlist_model.dart';
import 'detalhes_tierlist_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TierlistApiService _tierlistService = TierlistApiService();
  late Future<List<TierlistModel>> _tierlistsFuture;

  final Map<String, String> _generos = {
    '1': 'Action',
    '2': 'RPG',
    '3': 'Shooter',
    '4': 'Puzzle',
    '5': 'Adventure',
    '6': 'Indie',
    '7': 'Platformer',
    '8': 'Massively Multiplayer',
    '9': 'Sports',
    '10': 'Racing',
    '11': 'Simulation',
    '12': 'Arcade',
    '13': 'Casual',
    '14': 'Strategy',
    '15': 'Fighting',
    '16': 'Family',
    '17': 'Educational',
    '18': 'Card',
    '19': 'Board Games',
  };

  String _selectedGeneroId = '1';

  @override
  void initState() {
    super.initState();
    _tierlistsFuture = _carregarTierlistsPopulares();
  }

  Future<List<TierlistModel>> _carregarTierlistsPopulares() async {
    try {
      final data = await _tierlistService.obterTodas();
      final list = data.map((json) => TierlistModel.fromJson(json)).toList();
      list.shuffle();
      return list.take(5).toList();
    } catch (e) {
      print('Erro ao carregar tierlists populares: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tierlab')),
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'TierLists Populares',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<TierlistModel>>(
              future: _tierlistsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 240,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox(
                    height: 240,
                    child: Center(
                      child: Text(
                        'Nenhuma tierlist popular encontrada.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  );
                }

                final popularTierlists = snapshot.data!;

                return CarouselSlider(
                  options: CarouselOptions(
                    height: 240,
                    enlargeCenterPage: true,
                    autoPlay: popularTierlists.length > 1,
                    viewportFraction: 0.8,
                  ),
                  items: popularTierlists.map((tierlist) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalhesTierlistView(tierlist: tierlist),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: AspectRatio(
                                aspectRatio: 18 / 9,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        tierlist.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.grey[800],
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: const Icon(
                                            Icons.image,
                                            color: Colors.white30,
                                            size: 48,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              const Color.fromRGBO(0, 0, 0, 0.7),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              tierlist.titulo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              tierlist.descricao,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[400], fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGeneroId,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E1E1E),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        items: _generos.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedGeneroId = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerMaisGenerosTela(
                            generoId: _selectedGeneroId,
                            generoNome: _generos[_selectedGeneroId] ?? 'Gênero',
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver Mais',
                          style: TextStyle(color: Colors.amber[800]),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.amber[800],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<dynamic>>(
              future: _tierlistService.obterPorGenero(_selectedGeneroId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 135,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox(
                    height: 135,
                    child: Center(
                      child: Text(
                        'Nenhuma tierlist encontrada para este gênero.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                final genreTierlists = snapshot.data!
                    .map((json) => TierlistModel.fromJson(json))
                    .toList();
                final displayedTierlists = genreTierlists.take(5).toList();

                return SizedBox(
                  height: 135,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: displayedTierlists.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final tierlist = displayedTierlists[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalhesTierlistView(tierlist: tierlist),
                            ),
                          );
                        },
                        child: Container(
                          width: 135,
                          margin: const EdgeInsets.only(right: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[850]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Image.network(
                                  tierlist.imageUrl,
                                  height: 85,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 85,
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.list_alt,
                                      color: Colors.white30,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tierlist.titulo,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (tierlist.descricao.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        tierlist.descricao,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormularioTierlistView(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class VerMaisGenerosTela extends StatelessWidget {
  final String generoId;
  final String generoNome;
  final TierlistApiService tierlistService = TierlistApiService();

  VerMaisGenerosTela({
    super.key,
    required this.generoId,
    required this.generoNome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('Tierlists: $generoNome'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: tierlistService.obterPorGenero(generoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma tierlist encontrada para este gênero.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final tierlists = snapshot.data!
              .map((json) => TierlistModel.fromJson(json))
              .toList();

          return ListView.builder(
            itemCount: tierlists.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final item = tierlists[index];
              return TierlistItemCard(
                tierlist: item,
                tierlistService: tierlistService,
              );
            },
          );
        },
      ),
    );
  }
}

class TierlistItemCard extends StatefulWidget {
  final TierlistModel tierlist;
  final TierlistApiService tierlistService;

  const TierlistItemCard({
    super.key,
    required this.tierlist,
    required this.tierlistService,
  });

  @override
  State<TierlistItemCard> createState() => _TierlistItemCardState();
}

class _TierlistItemCardState extends State<TierlistItemCard> {
  late Future<Map<String, dynamic>> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = widget.tierlistService.obterPorId(widget.tierlist.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        String? descricaoFinal;
        TierlistModel itemExibido = widget.tierlist;

        if (snapshot.hasData && !snapshot.hasError) {
          try {
            final fullModel = TierlistModel.fromJson(snapshot.data!);
            itemExibido = fullModel;
            if (fullModel.descricao.trim().isNotEmpty) {
              descricaoFinal = fullModel.descricao;
            }
          } catch (_) {}
        }

        return Card(
          color: const Color(0xFF1E1E1E),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: itemExibido.imageUrl.isNotEmpty
                  ? Image.network(
                      itemExibido.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[800],
                        child: const Icon(Icons.list_alt, color: Colors.grey),
                      ),
                    )
                  : const Icon(Icons.list, color: Colors.grey),
            ),
            title: Text(
              itemExibido.titulo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: descricaoFinal != null
                ? Text(
                    descricaoFinal,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  )
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalhesTierlistView(tierlist: itemExibido),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
