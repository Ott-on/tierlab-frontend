import 'package:flutter/material.dart';
import 'package:tierlab/core/services/supabase_service.dart';
import 'package:tierlab/screens/auth_screen.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (SupabaseService().isAuthenticated) ...[
              Text(
                'Bem-vindo, ${SupabaseService().currentUser?.email ?? 'Usuário'}!',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await SupabaseService().signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usuário desconectado.')),
                    );
                    setState(() {});
                  }
                },
                child: const Text('Logout'),
              ),
            ] else ...[
              const Text(
                'Você não está autenticado.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
                  if (context.mounted) {
                    setState(() {});
                  }
                },
                child: const Text('Fazer login / registrar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
