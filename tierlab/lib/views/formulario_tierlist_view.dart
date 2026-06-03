import 'package:flutter/material.dart';

class FormularioTierlistView extends StatelessWidget {
  const FormularioTierlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova TierList')),
      body: const Center(child: Text('Formulário de TierList')),
    );
  }
}
