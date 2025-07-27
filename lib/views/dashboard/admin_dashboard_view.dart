// lib/views/dashboard/admin_dashboard_view.dart
import 'package:flutter/material.dart';
import '../admin/manage_users_view.dart'; // AJOUT EN HAUT
import '../admin/archived_users_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    _AdminHomePage(),
    const ManageUsersView(),
    Placeholder(),
    const ArchivedUsersView(), // 👈
    Placeholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSidebar(),
      appBar: AppBar(
        title: const Text('Administration – Gestion Utilisateurs'),
        backgroundColor: Colors.indigo,
      ),
      body: _pages[_selectedIndex],
    );
  }

  Drawer _buildSidebar() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Admin",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "admineducnc@gmail.com",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard_outlined,
            label: 'Tableau de bord',
            index: 0,
          ),
          _buildDrawerItem(
            icon: Icons.group_outlined,
            label: 'Utilisateurs',
            index: 1,
          ),
          _buildDrawerItem(
            icon: Icons.verified_user_outlined,
            label: 'Rôles & autorisations',
            index: 2,
          ),
          _buildDrawerItem(
            icon: Icons.archive_outlined,
            label: 'Comptes archivés',
            index: 3,
          ),
          _buildDrawerItem(
            icon: Icons.bar_chart_outlined,
            label: 'Vue ST2 globale',
            index: 4,
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              // TODO: Déconnexion
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(label),
      selected: _selectedIndex == index,
      selectedTileColor: Colors.indigo.shade50,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context); // Fermer le drawer
      },
    );
  }
}

class _AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Bienvenue, Administrateur 👑",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        _dashboardCard(
          icon: Icons.group,
          title: 'Gérer les utilisateurs',
          subtitle: 'Ajouter, modifier, supprimer les comptes utilisateurs',
          onTap: () {},
        ),
        _dashboardCard(
          icon: Icons.verified_user,
          title: 'Gérer les rôles',
          subtitle: 'Attribuer ou retirer des autorisations',
          onTap: () {},
        ),
        _dashboardCard(
          icon: Icons.archive,
          title: 'Voir comptes archivés',
          subtitle: 'Historique des utilisateurs supprimés',
          onTap: () {},
        ),
        _dashboardCard(
          icon: Icons.bar_chart,
          title: 'Rapports ST2 globaux',
          subtitle: 'Superviser tous les envois et indicateurs',
          onTap: () {},
        ),
      ],
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
        leading: Icon(icon, size: 34, color: Colors.indigo),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
