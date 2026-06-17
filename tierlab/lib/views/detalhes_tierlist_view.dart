import 'package:flutter/material.dart';

import '../core/services/supabase_service.dart';
import '../core/services/jogos_api_service.dart';
import '../core/services/tierlist_api_service.dart';
import '../models/jogos_model.dart';
import '../models/tierlist_model.dart';

class DetalhesTierlistView extends StatefulWidget {
  final TierlistModel tierlist;

  const DetalhesTierlistView({super.key, required this.tierlist});

  @override
  State<DetalhesTierlistView> createState() => _DetalhesTierlistViewState();
}

class _DetalhesTierlistViewState extends State<DetalhesTierlistView> {
  final JogosApiService _jogosService = JogosApiService();
  final TierlistApiService _tierlistService = TierlistApiService();
  final TextEditingController _searchController = TextEditingController();

  TierlistModel? _tierlistDetalhes;

  // Board com os jogos em cada tier
  Map<String, List<JogoModel>> board = {
    'S': [],
    'A': [],
    'B': [],
    'C': [],
    'D': [],
    'E': [],
    'F': [],
  };

  // Cópia do estado original para detectar mudanças
  Map<String, List<JogoModel>> boardOriginal = {
    'S': [],
    'A': [],
    'B': [],
    'C': [],
    'D': [],
    'E': [],
    'F': [],
  };

  // Lista de todos os jogos disponíveis
  List<JogoModel> allJogos = [];
  List<JogoModel> filteredJogos = [];

  bool _carregando = true;
  bool _salvando = false;
  String _searchText = '';
  String? _ownerId;

  bool get _eDono {
    final loggedInUserId = SupabaseService().currentUser?.id;
    final ownerId = _ownerId ?? _tierlistDetalhes?.usuarioId ?? widget.tierlist.usuarioId;
    return loggedInUserId != null && loggedInUserId == ownerId;
  }

  // Cores das tiers
  final Map<String, Color> tierColors = {
    'S': Colors.red[400]!,
    'A': Colors.orange[400]!,
    'B': Colors.yellow[600]!,
    'C': Colors.green[400]!,
    'D': Colors.blue[400]!,
    'E': Colors.indigo[400]!,
    'F': Colors.grey[600]!,
  };

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  Future<void> _inicializarDados() async {
    try {
      print('🔄 Iniciando carregamento de dados...');

      // Carrega os dados detalhados da tierlist para obter a descrição atualizada
      TierlistModel? detalhesCarregados;
      try {
        final tierlistJson = await _tierlistService.obterPorId(widget.tierlist.id);
        detalhesCarregados = TierlistModel.fromJson(tierlistJson);
        print('📥 Detalhes da tierlist (GET /api/Tierlists/{id}) carregados com sucesso.');
      } catch (e) {
        print('⚠️ Erro ao carregar detalhes da tierlist via API: $e');
      }

      // Busca o ownerId diretamente do Supabase já que a API C# não o retorna
      String? ownerIdDoSupabase;
      try {
        final tierlistIdParsed = int.tryParse(widget.tierlist.id);
        if (tierlistIdParsed != null) {
          final supabaseData = await SupabaseService().client
              .from('tierlists')
              .select('usuario_id')
              .eq('id', tierlistIdParsed)
              .single();
          ownerIdDoSupabase = supabaseData['usuario_id']?.toString();
          print('📥 Owner ID do Supabase: $ownerIdDoSupabase');
        }
      } catch (e) {
        print('⚠️ Erro ao buscar ownerId no Supabase: $e');
      }

      // Carrega os jogos da tierlist
      final jogosDaTierlist = await _tierlistService.obterJogosDaTierlist(
        widget.tierlist.id,
      );
      print('📥 Jogos da tierlist carregados: ${jogosDaTierlist.length}');

      // Carrega todos os jogos disponíveis
      final todosOsJogos = await _jogosService.obterTodosJogos();
      print('📥 Todos os jogos carregados: ${todosOsJogos.length}');

      if (!mounted) return;

      setState(() {
        if (detalhesCarregados != null) {
          _tierlistDetalhes = detalhesCarregados;
        }
        _ownerId = ownerIdDoSupabase;
        // Limpa o board antes de popular
        board.forEach((key, list) => list.clear());

        // Distribui os jogos da tierlist
        for (var item in jogosDaTierlist) {
          if (item is Map<String, dynamic>) {
            final jogo = JogoModel.fromJson(item);
            String tier = (item['tier']?.toString() ?? '').toUpperCase();
            if (board.containsKey(tier)) {
              board[tier]!.add(jogo);
              print('  ➕ ${jogo.titulo} → $tier');
            } else {
              print('  ⚠️ Jogo ${jogo.titulo} tem tier inválido ou não mapeado: $tier');
            }
          }
        }

        // Copia para o original
        boardOriginal.forEach((key, list) => list.clear());
        board.forEach((tier, jogos) {
          boardOriginal[tier] = List<JogoModel>.from(jogos);
        });

        // Define todos os jogos
        allJogos = todosOsJogos;
        filteredJogos = List<JogoModel>.from(todosOsJogos);

        _carregando = false;
      });

      print('✅ Dados carregados com sucesso!');
    } catch (e) {
      print('❌ Erro ao carregar: $e');
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filtrarJogos(String termo) {
    setState(() {
      _searchText = termo;
      if (termo.isEmpty) {
        filteredJogos = List<JogoModel>.from(allJogos);
      } else {
        filteredJogos = allJogos
            .where(
              (jogo) => jogo.titulo.toLowerCase().contains(termo.toLowerCase()),
            )
            .toList();
      }
      print('🔍 Filtrados ${filteredJogos.length} jogos para: "$termo"');
    });
  }

  void _removerJogo(JogoModel jogo) {
    setState(() {
      board.forEach((key, list) {
        list.removeWhere((item) => item.id == jogo.id);
      });
      print('➖ Jogo ${jogo.titulo} removido');
    });
  }

  void _moverJogo(JogoModel jogo, String novoTier) {
    setState(() {
      String tierAnterior = '';
      // Encontra onde o jogo está
      for (var entry in board.entries) {
        if (entry.value.any((j) => j.id == jogo.id)) {
          tierAnterior = entry.key;
          break;
        }
      }

      // Remove de onde estava
      board.forEach((key, list) {
        list.removeWhere((item) => item.id == jogo.id);
      });

      // Adiciona no novo tier
      board[novoTier]!.add(jogo);
      print('↔️ Jogo ${jogo.titulo} movido de $tierAnterior → $novoTier');
    });
  }

  Future<void> _salvar() async {
    if (_salvando) return;

    setState(() => _salvando = true);

    try {
      List<Future<void>> requisicoes = [];

      // Detecta mudanças
      board.forEach((tierAtual, jogosAtuais) {
        for (var jogoAtual in jogosAtuais) {
          String tierOriginal = '';
          for (var entry in boardOriginal.entries) {
            if (entry.value.any((j) => j.id == jogoAtual.id)) {
              tierOriginal = entry.key;
              break;
            }
          }

          // Se é novo ou mudou de tier
          if (tierOriginal.isEmpty || tierOriginal != tierAtual) {
            final posicao = board[tierAtual]!.indexOf(jogoAtual).toString();
            final request = AddJogoRequest(
              jogoId: jogoAtual.id,
              tier: tierAtual,
              posicao: posicao,
            );
            print(
              '💾 Salvando: ${jogoAtual.titulo} ($tierOriginal → $tierAtual)',
            );
            requisicoes.add(
              _tierlistService.adicionarJogo(
                widget.tierlist.id,
                request.toJson(),
              ),
            );
          }
        }
      });

      // Detecta jogos removidos da tierlist
      boardOriginal.forEach((tierOriginal, jogosOriginais) {
        for (var jogoOriginal in jogosOriginais) {
          final aindaExiste = board.values.any(
            (tier) => tier.any((j) => j.id == jogoOriginal.id),
          );
          if (!aindaExiste) {
            print(
              '🗑️ Removendo: ${jogoOriginal.titulo} de $tierOriginal',
            );
            requisicoes.add(
              _tierlistService.removerJogo(
                widget.tierlist.id,
                jogoOriginal.id,
              ),
            );
          }
        }
      });

      if (requisicoes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ℹ️ Nenhuma alteração para salvar'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } else {
        await Future.wait(requisicoes);

        // Atualiza o original
        boardOriginal.forEach((key, list) => list.clear());
        board.forEach((tier, jogos) {
          boardOriginal[tier] = List<JogoModel>.from(jogos);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${requisicoes.length} alteração(ões) salva(s)!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        print('✅ ${requisicoes.length} mudanças salvas com sucesso!');
      }
    } catch (e) {
      print('❌ Erro ao salvar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Scaffold(
        appBar: AppBar(title: const Text('TierLab')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'TierLab',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          if (_eDono)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header da tierlist
            if ((_tierlistDetalhes?.imageUrl ?? widget.tierlist.imageUrl).isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.network(
                      _tierlistDetalhes?.imageUrl ?? widget.tierlist.imageUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.grey[800],
                        child: const Icon(Icons.image, color: Colors.white54),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Card de Detalhes (Título, Descrição e Visibilidade)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E1E1E),
                    Color(0xFF151515),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[800]!.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tierlistDetalhes?.titulo ?? widget.tierlist.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if ((_tierlistDetalhes?.descricao ?? widget.tierlist.descricao).isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border(
                          left: BorderSide(
                            color: Colors.purpleAccent[400]!,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notes_rounded,
                            color: Colors.purpleAccent[100],
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _tierlistDetalhes?.descricao ?? widget.tierlist.descricao,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 14,
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Sem descrição disponível',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tiers
            ..._buildTiers(),

            if (_eDono) ...[
              const SizedBox(height: 32),

              // Seção de adicionar jogos
              const Text(
                'Adicionar Jogos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Campo de busca
              TextField(
                controller: _searchController,
                onChanged: _filtrarJogos,
                decoration: InputDecoration(
                  hintText: 'Buscar jogo...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filtrarJogos('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Lista de jogos disponíveis
              if (filteredJogos.isEmpty)
                Center(
                  child: Text(
                    _searchText.isEmpty
                        ? 'Nenhum jogo disponível'
                        : 'Nenhum resultado encontrado',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                )
              else
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredJogos.length,
                    itemBuilder: (context, index) {
                      final jogo = filteredJogos[index];
                      final jaAdicionado = board.values.any(
                        (tier) => tier.any((j) => j.id == jogo.id),
                      );

                      final cardContent = Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                              border: jaAdicionado
                                  ? Border.all(
                                      color: Colors.green,
                                      width: 2,
                                    )
                                  : null,
                              image: jogo.imageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(jogo.imageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: jogo.imageUrl.isEmpty
                                ? const Icon(
                                    Icons.gamepad,
                                    color: Colors.white54,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 80,
                            child: Text(
                              jogo.titulo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: jaAdicionado
                            ? Opacity(
                                opacity: 0.5,
                                child: cardContent,
                              )
                            : Draggable<JogoModel>(
                                data: jogo,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Opacity(
                                    opacity: 0.8,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(8),
                                        image: jogo.imageUrl.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(jogo.imageUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: jogo.imageUrl.isEmpty
                                        ? const Icon(
                                            Icons.gamepad,
                                            color: Colors.white54,
                                          )
                                        : null,
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: cardContent,
                                ),
                                child: cardContent,
                              ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTiers() {
    return ['S', 'A', 'B', 'C', 'D', 'E', 'F'].map((tier) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildTierRow(tier),
      );
    }).toList();
  }

  Widget _buildTierRow(String tier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 70,
              decoration: BoxDecoration(
                color: tierColors[tier],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  tier,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _eDono
                  ? DragTarget<JogoModel>(
                      onAcceptWithDetails: (details) {
                        _moverJogo(details.data, tier);
                      },
                      builder: (context, candidateData, rejectedData) {
                        return _buildTierContent(tier, candidateData.isNotEmpty);
                      },
                    )
                  : _buildTierContent(tier, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierContent(String tier, bool isCandidate) {
    final jogos = board[tier]!;
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(8),
      color: isCandidate ? Colors.white10 : Colors.transparent,
      child: jogos.isEmpty
          ? Center(
              child: Text(
                _eDono ? 'Arraste jogos aqui' : 'Nenhum jogo neste tier',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: jogos.map((jogo) {
                return SizedBox(
                  width: 80,
                  height: 80,
                  child: _buildJogoCard(jogo),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildJogoCard(JogoModel jogo) {
    if (!_eDono) {
      return _buildJogoItemUI(jogo);
    }

    return Draggable<JogoModel>(
      data: jogo,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(6),
              image: jogo.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(jogo.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: jogo.imageUrl.isEmpty
                ? const Icon(Icons.videogame_asset, color: Colors.white54)
                : null,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildJogoItemUI(jogo)),
      child: Stack(
        children: [
          _buildJogoItemUI(jogo),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _removerJogo(jogo),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJogoItemUI(JogoModel jogo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(6),
        image: jogo.imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(jogo.imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: jogo.imageUrl.isEmpty
          ? const Icon(Icons.videogame_asset, color: Colors.white54)
          : null,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
