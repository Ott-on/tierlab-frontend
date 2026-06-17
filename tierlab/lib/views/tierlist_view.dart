import 'dart:math';
import 'dart:ui'; // Importante para ativar o arraste com o mouse
import 'package:flutter/material.dart';
import 'package:tierlab/views/formulario_tierlist_view.dart';

// Importações dos seus Models e Services (Ajuste conforme a estrutura de pastas do seu projeto)
import '../models/tierlist_model.dart';
import '../models/user_model.dart';
import '../models/jogos_model.dart'; // Modelo de jogos criado anteriormente
import '../views/detalhes_tierlist_view.dart';
import '../core/services/tierlist_api_service.dart';
import '../core/services/user_api_service.dart';
import '../core/services/supabase_service.dart'; // Service de autenticação criado anteriormente
import '../core/services/jogos_api_service.dart'; // Service de jogos criado anteriormente

/// Configuração para permitir arrastar listas horizontais com o mouse (Web/Desktop)
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class TierListsView extends StatelessWidget {
  // ID do usuário para testes - integre com seu sistema de login/autenticação posterior
  final String usuarioIdLogado = SupabaseService().currentUser!.id;

  final TierlistApiService _tierlistService = TierlistApiService();
  final UserApiService _usuarioService = UserApiService();
  final JogosApiService _jogosService = JogosApiService();

  TierListsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior:
          AppScrollBehavior(), // Aplica a permissão de arraste para todas as listas internas
      child: Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // SEÇÃO: SUAS TIERLISTS
                // ==========================================
                _buildHeaderSecao(
                  titulo: 'Suas Tierlists',
                  onVerMais: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerMaisTierlistsTela(
                          usuarioId: usuarioIdLogado,
                          tierlistService: _tierlistService,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height:
                      200, // Aumentado ligeiramente para comportar o título + descrição confortavelmente
                  child: FutureBuilder<List<dynamic>>(
                    future: _tierlistService.obterPorUsuario(usuarioIdLogado),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return _buildPlaceholderVazio(
                          'Nenhuma tierlist criada.',
                        );
                      }

                      final tierlists = snapshot.data!
                          .map((json) => TierlistModel.fromJson(json))
                          .toList();
                      final quantidadeExibida = min(5, tierlists.length);

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: quantidadeExibida,
                        itemBuilder: (context, index) {
                          final item = tierlists[index];
                          return _buildCardCarrossel(
                            titulo: item.titulo,
                            descricao: item.descricao, // Descrição agora renderizada abaixo
                            imageUrl: item.imageUrl,
                            
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetalhesTierlistView(tierlist: item),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // ==========================================
                // SEÇÃO: SEUS JOGOS
                // ==========================================
                _buildHeaderSecao(
                  titulo: 'Seus Jogos',
                  onVerMais: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerMaisJogosTela(
                          usuarioId: usuarioIdLogado,
                          usuarioService: _usuarioService,
                          jogosService: _jogosService,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: FutureBuilder<List<dynamic>>(
                    // Executa as duas buscas em paralelo para hidratar os dados usando o ID
                    future: Future.wait([
                      _usuarioService.obterJogosDoUsuario(usuarioIdLogado),
                      _jogosService.obterTodosJogos(),
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return _buildPlaceholderVazio(
                          'Erro ao carregar dados dos jogos.',
                        );
                      }

                      final jogosDoUsuario =
                          snapshot.data![0] as List<UsuarioJogoModel>;
                      final todosOsJogosMaster =
                          snapshot.data![1] as List<JogoModel>;

                      if (jogosDoUsuario.isEmpty) {
                        return _buildPlaceholderVazio(
                          'Nenhum jogo adicionado à sua conta.',
                        );
                      }

                      final quantidadeExibida = min(5, jogosDoUsuario.length);

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: quantidadeExibida,
                        itemBuilder: (context, index) {
                          final itemUsuario = jogosDoUsuario[index];

                          // Procura as informações de Título e Imagem na lista master correspondente ao ID
                          final jogoDadosMaster = todosOsJogosMaster.firstWhere(
                            (j) => j.id == itemUsuario.jogoId.toString(),
                            orElse: () => const JogoModel(
                              id: '',
                              titulo: 'Jogo Desconhecido',
                              imageUrl: '',
                            ),
                          );

                          return _buildCardCarrossel(
                            titulo: jogoDadosMaster
                                .titulo, // Título buscado via ID obtido com sucesso
                            descricao:
                                'Status: ${itemUsuario.status}\nHoras: ${itemUsuario.horasJogadas}h',
                            imageUrl: jogoDadosMaster
                                .imageUrl, // Imagem buscada via ID obtida com sucesso
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetalhesJogoTela(
                                    jogoUsuario: itemUsuario,
                                    jogoMaster: jogoDadosMaster,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
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
      ),
    );
  }

  Widget _buildHeaderSecao({
    required String titulo,
    required VoidCallback onVerMais,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onVerMais,
          child: const Text(
            'Ver mais',
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildCardCarrossel({
    required String titulo,
    required String
    descricao, // Você pode remover isso dos parâmetros depois se quiser
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140, // Deixei um pouco mais quadrado
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Imagem do Jogo/Tierlist
            Expanded(
              flex: 3,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white30,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[800],
                      width: double.infinity,
                      child: const Icon(
                        Icons.gamepad,
                        color: Colors.white54,
                        size: 40,
                      ),
                    ),
            ),
            // Título Centralizado (Sem descrição)
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                alignment:
                    Alignment.center, // Centraliza na vertical e horizontal
                child: Text(
                  titulo,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderVazio(String mensagem) {
    return Center(
      child: Text(
        mensagem,
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
    );
  }
}

// ============================================================================
// TELAS DE DETALHES (CLICK)
// ============================================================================

class DetalhesJogoTela extends StatelessWidget {
  final UsuarioJogoModel jogoUsuario;
  final JogoModel jogoMaster;

  const DetalhesJogoTela({
    super.key,
    required this.jogoUsuario,
    required this.jogoMaster,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(jogoMaster.titulo)),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (jogoMaster.imageUrl.isNotEmpty)
            Image.network(jogoMaster.imageUrl, height: 200),
          const SizedBox(height: 16),
          Text(
            jogoMaster.titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Status de progresso: ${jogoUsuario.status}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            'Nota pessoal: ${jogoUsuario.nota}/5',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            'Tempo de jogo: ${jogoUsuario.horasJogadas} horas',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    ),
  );
}

// ============================================================================
// TELAS DE "VER MAIS" COMPLETAS (TRAZENDO TODOS OS ITENS VERTICALMENTE)
// ============================================================================

class VerMaisTierlistsTela extends StatelessWidget {
  final String usuarioId;
  final TierlistApiService tierlistService;

  const VerMaisTierlistsTela({
    super.key,
    required this.usuarioId,
    required this.tierlistService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todas as Suas Tierlists')),
      body: FutureBuilder<List<dynamic>>(
        future: tierlistService.obterPorUsuario(usuarioId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma tierlist encontrada.',
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
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.list, color: Colors.grey),
                  title: Text(
                    item.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    item.descricao,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetalhesTierlistView(tierlist: item),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class VerMaisJogosTela extends StatelessWidget {
  final String usuarioId;
  final UserApiService usuarioService;
  final JogosApiService jogosService;

  const VerMaisJogosTela({
    super.key,
    required this.usuarioId,
    required this.usuarioService,
    required this.jogosService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos os Seus Jogos')),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          usuarioService.obterJogosDoUsuario(usuarioId),
          jogosService.obterTodosJogos(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'Erro ao carregar dados dos jogos.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final jogosDoUsuario = snapshot.data![0] as List<UsuarioJogoModel>;
          final todosOsJogosMaster = snapshot.data![1] as List<JogoModel>;

          if (jogosDoUsuario.isEmpty) {
            return const Center(
              child: Text(
                'Você ainda não possui jogos salvos.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: jogosDoUsuario.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final itemUsuario = jogosDoUsuario[index];

              final jogoDadosMaster = todosOsJogosMaster.firstWhere(
                (j) => j.id == itemUsuario.jogoId.toString(),
                orElse: () => const JogoModel(
                  id: '',
                  titulo: 'Jogo Desconhecido',
                  imageUrl: '',
                ),
              );

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: jogoDadosMaster.imageUrl.isNotEmpty
                      ? Image.network(
                          jogoDadosMaster.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.gamepad, color: Colors.grey),
                  title: Text(
                    jogoDadosMaster.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Status: ${itemUsuario.status} | Nota: ${itemUsuario.nota}/5\nHoras Jogadas: ${itemUsuario.horasJogadas}h',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalhesJogoTela(
                          jogoUsuario: itemUsuario,
                          jogoMaster: jogoDadosMaster,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
