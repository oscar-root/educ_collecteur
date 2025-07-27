// lib/views/dashboard/directeur_dashboard_view.dart
import 'package:flutter/material.dart';

class DirecteurDashboardView extends StatefulWidget {
  const DirecteurDashboardView({super.key});

  @override
  State<DirecteurDashboardView> createState() => _DirecteurDashboardViewState();
}

class _DirecteurDashboardViewState extends State<DirecteurDashboardView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _AccueilDirecteur(),
    Placeholder(), // Visualiser les rapports
    Placeholder(), // Statistiques interactives (charts)
    Placeholder(), // Impression ou téléchargement
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSidebar(),
      appBar: AppBar(
        title: const Text('Espace Directeur – Supervision'),
        backgroundColor: Colors.teal,
      ),
      body: _pages[_selectedIndex],
    );
  }

  Drawer _buildSidebar() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.teal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.supervisor_account,
                    size: 40,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Directeur Provincial H-L 1",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "direction@educ.nc",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard_outlined,
            label: 'Accueil',
            index: 0,
          ),
          _buildDrawerItem(
            icon: Icons.folder_shared,
            label: 'Consulter les rapports',
            index: 1,
          ),
          _buildDrawerItem(
            icon: Icons.bar_chart_outlined,
            label: 'Statistiques interactives',
            index: 2,
          ),
          _buildDrawerItem(
            icon: Icons.print_outlined,
            label: 'Imprimer / Télécharger',
            index: 3,
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
      leading: Icon(icon, color: Colors.teal),
      title: Text(label),
      selected: _selectedIndex == index,
      selectedTileColor: Colors.teal.shade50,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context); // Ferme le Drawer
      },
    );
  }
}

class _AccueilDirecteur extends StatelessWidget {
  const _AccueilDirecteur();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Bienvenue Directeur 👨‍💼",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        _dashboardCard(
          icon: Icons.folder_shared,
          title: 'Visualiser les rapports ST2',
          subtitle: 'Tous les rapports soumis par les chefs de service',
          onTap: () {
            // Naviguer vers la vue de tous les rapports
          },
        ),
        _dashboardCard(
          icon: Icons.bar_chart,
          title: 'Statistiques interactives',
          subtitle: 'Visualiser les données des écoles sous forme graphique',
          onTap: () {
            // Aller vers les charts dynamiques
          },
        ),
        _dashboardCard(
          icon: Icons.print,
          title: 'Imprimer ou exporter',
          subtitle: 'Télécharger ou imprimer les rapports ST2 consolidés',
          onTap: () {
            // Aller vers impression PDF/export
          },
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
        leading: Icon(icon, size: 34, color: Colors.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
