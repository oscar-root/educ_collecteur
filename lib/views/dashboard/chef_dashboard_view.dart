import 'package:flutter/material.dart';

class ChefDashboardView extends StatelessWidget {
  const ChefDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Chef d’établissement')),
      body: const Center(child: Text('Bienvenue Chef d’établissement')),
    );
  }
}
