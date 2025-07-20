import 'package:flutter/material.dart';

class DirecteurDashboardView extends StatelessWidget {
  const DirecteurDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Directeur')),
      body: const Center(child: Text('Bienvenue Directeur')),
    );
  }
}
