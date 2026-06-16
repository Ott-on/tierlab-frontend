import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../core/services/supabase_service.dart';
import '../core/services/tierlist_api_service.dart';
import '../core/services/user_api_service.dart';
import '../models/tierlist_model.dart';

class FormularioTierlistView extends StatefulWidget {
  const FormularioTierlistView({super.key});

  @override
  State<FormularioTierlistView> createState() => _FormularioTierlistViewState();
}

class _FormularioTierlistViewState extends State<FormularioTierlistView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _supabaseService = SupabaseService();
  final _tierlistApiService = TierlistApiService();
  final _userApiService = UserApiService();

  static const _visibilidadeOpcoes = [
    ('public', 'Público'),
    ('private', 'Privado'),
  ];

  String _visibilidade = _visibilidadeOpcoes.first.$1;
  bool _isLoading = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _abrirLogin() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AuthController()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    if (!_supabaseService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faça login para criar uma tierlist.'),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final user = _supabaseService.currentUser!;
      final profile = await _supabaseService.getProfile();
      final username = profile?['username'] as String? ??
          user.userMetadata?['username'] as String?;

      await _userApiService.sincronizarUsuario(
        usuarioId: user.id,
        email: user.email ?? '',
        username: username,
      );

      final request = CreateTierlistRequest(
        usuarioId: user.id,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        visibilidade: _visibilidade,
      );

      await _tierlistApiService.criarTierlist(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tierlist criada com sucesso!')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha: $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = _supabaseService.isAuthenticated;

    return Scaffold(
      appBar: AppBar(title: const Text('Nova TierList')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isAuthenticated) ...[
                const Text(
                  'Você precisa estar autenticado para criar uma tierlist.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _abrirLogin,
                  child: const Text('Fazer Login / Registrar'),
                ),
                const SizedBox(height: 24),
              ],
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      enabled: isAuthenticated && !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o título da tierlist.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descricaoController,
                      enabled: isAuthenticated && !_isLoading,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe a descrição da tierlist.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      enabled: isAuthenticated && !_isLoading,
                      keyboardType: TextInputType.url,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'URL da imagem',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe a URL da imagem.';
                        }
                        final uri = Uri.tryParse(value.trim());
                        if (uri == null ||
                            !uri.hasScheme ||
                            !uri.host.isNotEmpty) {
                          return 'Informe uma URL válida.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FormField<String>(
                      initialValue: _visibilidade,
                      builder: (field) => DropdownButtonFormField<String>(
                        initialValue: field.value,
                        dropdownColor: const Color(0xFF2E2E2E),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Visibilidade',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                        items: _visibilidadeOpcoes
                            .map(
                              (opcao) => DropdownMenuItem(
                                value: opcao.$1,
                                child: Text(opcao.$2),
                              ),
                            )
                            .toList(),
                        onChanged: isAuthenticated && !_isLoading
                            ? (value) {
                                if (value != null) {
                                  field.didChange(value);
                                  _visibilidade = value;
                                }
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            isAuthenticated && !_isLoading ? _submit : null,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                            : const Text('Criar Tierlist'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
