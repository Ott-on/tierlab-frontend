import 'package:flutter/material.dart';
import 'package:tierlab/core/services/supabase_service.dart';
import 'package:tierlab/controllers/auth_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _supabaseService = SupabaseService();
  Future<Map<String, dynamic>?>? _profileFuture;

  @override
  void initState() {
    super.initState();
    if (_supabaseService.isAuthenticated) {
      _loadProfile();
    }
  }

  void _loadProfile() {
    _profileFuture = _supabaseService.getProfile();
  }

  Future<void> _updateProfile({
    String? username,
    String? bio,
    bool? isPublic,
  }) async {
    try {
      await _supabaseService.updateProfile(
        username: username,
        bio: bio,
        isPublic: isPublic,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atualizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
      }
    } finally {
      setState(() {
        _loadProfile(); // Recarrega os dados do perfil
      });
    }
  }

  Future<void> _showEditDialog(
    String title,
    String initialValue,
    Function(String) onSave,
  ) async {
    final controller = TextEditingController(text: initialValue);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: _supabaseService.isAuthenticated
          ? _buildProfileView()
          : _buildLoggedOutView(),
    );
  }

  Widget _buildProfileView() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text('Não foi possível carregar o perfil.'),
          );
        }

        final profile = snapshot.data!;
        final username = profile['username'] ?? 'Sem nome de usuário';
        final bio = profile['bio'] ?? 'Sem bio.';
        final isPublic = profile['perfil_publico'] ?? true;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            ListTile(
              title: const Text(
                'Nome de usuário',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                username,
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _showEditDialog(
                  'Editar Nome de Usuário',
                  username,
                  (newValue) => _updateProfile(username: newValue),
                ),
              ),
            ),
            ListTile(
              title: const Text('Bio', style: TextStyle(color: Colors.white)),
              subtitle: Text(bio, style: const TextStyle(color: Colors.grey)),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _showEditDialog(
                  'Editar Bio',
                  bio,
                  (newValue) => _updateProfile(bio: newValue),
                ),
              ),
            ),
            SwitchListTile(
              title: const Text(
                'Perfil Público',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              activeThumbColor: Colors.deepPurpleAccent,
              value: isPublic,
              onChanged: (newValue) {
                _updateProfile(isPublic: newValue);
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await _supabaseService.signOut();
                setState(() {}); // Atualiza a UI para o estado deslogado
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoggedOutView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Você não está autenticado.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AuthController()));
              if (_supabaseService.isAuthenticated) {
                setState(() {
                  _loadProfile(); // Carrega o perfil após o login/registro
                });
              }
            },
            child: const Text('Fazer login / registrar'),
          ),
        ],
      ),
    );
  }
}
