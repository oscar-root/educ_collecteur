// lib/views/dashboard/directeur_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // La page d'accueil reçoit maintenant une fonction pour changer l'onglet
    _pages = <Widget>[
      _AccueilDirecteurContent(onCardTapped: _onItemTapped),
      const SavedReportsPage(),
      const StatisticsPage(),
    ];
  }

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
        title: Text(_pageTitles[_selectedIndex], style: GoogleFonts.poppins()),
        backgroundColor: Colors.indigo,
        // En définissant un `drawer`, Flutter ajoute automatiquement
        // l'icône de menu (hamburger) à gauche.
      ),
      // Le drawer est maintenant à gauche
      drawer: _buildSettingsDrawer(context),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.folder_shared_outlined),
              activeIcon: Icon(Icons.folder_shared),
              label: 'Rapports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
      ),
    );
  }

  Drawer _buildSettingsDrawer(BuildContext context) {
    return Drawer(
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text("Directeur Provincial",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                accountEmail: Text(
                    _authController.auth.currentUser?.email ??
                        'non.connecte@email.com',
                    style: GoogleFonts.poppins()),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.school, size: 40, color: Colors.indigo),
                ),
                decoration: const BoxDecoration(color: Colors.indigo),
              ),
              ListTile(
                title: Text("Options",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600)),
              ),
              SwitchListTile(
                title: Text("Mode Sombre", style: GoogleFonts.poppins()),
                secondary: Icon(themeProvider.themeMode == ThemeMode.dark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) =>
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleTheme(value),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: Text('Déconnexion',
                    style: GoogleFonts.poppins(color: Colors.redAccent)),
                onTap: () async {
                  await _authController.signOut();
                  if (mounted)
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AccueilDirecteurContent extends StatelessWidget {
  final Function(int) onCardTapped;
  const _AccueilDirecteurContent({required this.onCardTapped});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bienvenue, Directeur !",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.poppins().fontFamily),
          ),
          const SizedBox(height: 8),
          Text(
            "Supervisez et analysez les données de votre province.",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
                fontFamily: GoogleFonts.poppins().fontFamily),
          ),
          const SizedBox(height: 24),
          _buildDashboardCard(
            context: context,
            icon: Icons.folder_shared_outlined,
            title: 'Consulter les Rapports',
            subtitle:
                'Accédez à tous les rapports générés par le service statistique et planification.',
            onTap: () => onCardTapped(1),
          ),
          const SizedBox(height: 16),
          _buildDashboardCard(
            context: context,
            icon: Icons.bar_chart_outlined,
            title: 'Statistiques Interactives',
            subtitle: 'Visualisez les données clés sous forme de graphiques.',
            onTap: () => onCardTapped(2),
          ),
        ],
      ),
    );
  }

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                          fontFamily: GoogleFonts.poppins().fontFamily),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                          fontFamily: GoogleFonts.poppins().fontFamily),
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
