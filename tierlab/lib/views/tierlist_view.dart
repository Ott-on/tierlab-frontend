import 'package:flutter/material.dart';
import 'package:tierlab/views/formulario_tierlist_view.dart';

class TierlistsView extends StatelessWidget {
  const TierlistsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tierlists')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Suas Tierlists',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Placeholder for the tierlist cards
            SizedBox(
              height: 150, // Placeholder height for cards
              child: Center(
                child: Text(
                  'Cards de tierlist aqui',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Tierlists Salvas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Placeholder for the saved tierlist cards
            SizedBox(
              height: 150, // Placeholder height for cards
              child: Center(
                child: Text(
                  'Cards de tierlist salvas aqui',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
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
