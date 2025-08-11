// lib/views/dashboard/directeur_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:educ_collecteur/controllers/auth_controller.dart';
import 'package:educ_collecteur/providers/theme_provider.dart';

// Importez les pages réelles qui seront affichées
import 'saved_reports_page.dart';
import 'statistics_page.dart';

class DirecteurDashboardView extends StatefulWidget {
  const DirecteurDashboardView({super.key});

  @override
  State<DirecteurDashboardView> createState() => _DirecteurDashboardViewState();
}

class _DirecteurDashboardViewState extends State<DirecteurDashboardView> {
  final AuthController _authController = AuthController();
  int _selectedIndex = 0; // Index pour la BottomNavigationBar

  // --- MISE À JOUR DE LA LISTE DES PAGES ---
  // On utilise maintenant les vraies pages que vous avez créées.
  static final List<Widget> _pages = <Widget>[
    const _AccueilDirecteurContent(), // Onglet 0: Accueil
    const SavedReportsPage(), // Onglet 1: Rapports Enregistrés
    const StatisticsPage(), // Onglet 2: Statistiques
  ];

  // Titres correspondants pour l'AppBar
  static const List<String> _pageTitles = [
    'Tableau de Bord Directeur',
    'Rapports Enregistrés',
    'Statistiques Globales',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitles[_selectedIndex],
        ), // Le titre change avec la page
        actions: [
          // On ajoute un bouton pour ouvrir le drawer des paramètres/déconnexion
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  tooltip: 'Menu',
                ),
          ),
        ],
      ),
      // Le Drawer est maintenant un EndDrawer pour ne pas interférer avec le bouton "retour"
      endDrawer: _buildSettingsDrawer(context),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      // --- AJOUT DE LA BOTTOMNAVIGATIONBAR ---
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined),
            activeIcon: Icon(Icons.folder_shared),
            label: 'Rapports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Les couleurs s'adaptent au thème
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
      ),
    );
  }

  /// Construit un Drawer simplifié pour les paramètres et la déconnexion.
  Drawer _buildSettingsDrawer(BuildContext context) {
    return Drawer(
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text(
                  "Directeur Provincial",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  _authController.auth.currentUser?.email ??
                      'non.connecte@email.com',
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Icon(
                    Icons.school,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Options",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ExpansionTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text("Paramètres"),
                children: [
                  SwitchListTile(
                    title: const Text("Mode Sombre"),
                    secondary: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                    ),
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).toggleTheme(value);
                    },
                  ),
                ],
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () async {
                  await _authController.signOut();
                  if (mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Contenu de la page d'accueil du Directeur
class _AccueilDirecteurContent extends StatelessWidget {
  const _AccueilDirecteurContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- EMOJI RETIRÉ ---
          Text(
            "Bienvenue, Directeur !",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Supervisez et analysez les données de votre province.",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          _buildDashboardCard(
            context: context,
            icon: Icons.folder_shared_outlined,
            title: 'Consulter les Rapports',
            subtitle: 'Accédez à tous les rapports générés par les services.',
            onTap: () {
              // Cette carte n'est plus nécessaire car c'est un onglet
              // Mais on peut la garder comme raccourci
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Accédez via l'onglet 'Rapports' en bas."),
                ),
              );
            },
          ),
          _buildDashboardCard(
            context: context,
            icon: Icons.bar_chart_outlined,
            title: 'Statistiques Interactives',
            subtitle: 'Visualisez les données clés sous forme de graphiques.',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Accédez via l'onglet 'Stats' en bas."),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Construit une carte cliquable pour le tableau de bord
  Widget _buildDashboardCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
