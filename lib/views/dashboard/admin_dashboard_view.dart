// lib/views/dashboard/admin_dashboard_view.dart
import 'package:flutter/material.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Administrateur')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _dashboardCard(
            icon: Icons.group,
            title: 'Gérer les utilisateurs',
            subtitle: 'Ajouter, modifier, supprimer les comptes',
            onTap: () {
              // Naviguer vers gestion des comptes
            },
          ),
          _dashboardCard(
            icon: Icons.analytics,
            title: 'Vue globale ST2',
            subtitle: 'Superviser tous les envois et rapports',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.indigo),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
