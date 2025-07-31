// lib/views/dashboard/admin_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:educ_collecteur/controllers/auth_controller.dart';
import 'package:educ_collecteur/providers/theme_provider.dart';
import 'package:educ_collecteur/models/user_model.dart';
import '../admin/manage_users_view.dart';
import '../admin/archived_users_view.dart';
import '../admin/manage_roles_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  final AuthController _authController = AuthController();
  int _selectedIndex = 0;

  // Liste des pages qui correspondent aux onglets
  // est maintenant 'late final' pour être initialisée dans initState.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      _AdminHomePageContent(), // <- Ne requiert plus de callback
      ManageUsersView(),
      ManageRolesView(),
      ArchivedUsersView(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<String> _pageTitles = [
    'Tableau de Bord Admin',
    'Gérer les Utilisateurs',
    'Gérer les Rôles',
    'Comptes Archivés',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  tooltip: 'Paramètres & Options',
                ),
          ),
        ],
      ),
      endDrawer: _buildSettingsDrawer(context),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Gérer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined),
            activeIcon: Icon(Icons.verified_user),
            label: 'Rôles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            activeIcon: Icon(Icons.archive),
            label: 'Archives',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
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
                accountName: const Text(
                  "Administrateur",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  _authController.auth.currentUser?.email ?? 'admin@email.com',
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  "Options",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              ExpansionTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text("Apparence"),
                initiallyExpanded: true,
                children: [
                  SwitchListTile(
                    title: const Text("Mode Sombre"),
                    secondary: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                    ),
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged:
                        (value) => Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ).toggleTheme(value),
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
                  if (mounted)
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AdminHomePageContent extends StatefulWidget {
  const _AdminHomePageContent();

  @override
  State<_AdminHomePageContent> createState() => _AdminHomePageContentState();
}

class _AdminHomePageContentState extends State<_AdminHomePageContent> {
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsersData();
  }

  Future<List<UserModel>> _fetchUsersData() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('archived', isEqualTo: false)
            .get();
    if (snapshot.docs.isEmpty) return [];
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  Map<String, int> _processData(List<UserModel> users, String field) {
    Map<String, int> counts = {};
    for (var user in users) {
      String key;
      switch (field) {
        case 'role':
          key = user.role;
          break;
        case 'niveauEcole':
          key = user.niveauEcole;
          break;
        default:
          key = 'Inconnu';
      }
      key =
          key.isNotEmpty
              ? key[0].toUpperCase() + key.substring(1)
              : 'Non défini';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  void _refreshData() {
    setState(() {
      _usersFuture = _fetchUsersData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text("Erreur : ${snapshot.error}"));
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Center(child: Text("Aucun utilisateur à analyser."));

        final users = snapshot.data!;
        final roleData = _processData(users, 'role');
        final niveauData = _processData(users, 'niveauEcole');

        return RefreshIndicator(
          onRefresh: () async => _refreshData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Vue d'ensemble des Utilisateurs",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Total des utilisateurs actifs : ${users.length}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                _PieChartCard(title: "Répartition par Rôle", data: roleData),
                _PieChartCard(
                  title: "Répartition par Niveau d'École",
                  data: niveauData,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PieChartCard extends StatelessWidget {
  final String title;
  final Map<String, int> data;
  const _PieChartCard({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.indigo,
      Colors.teal,
      Colors.amber.shade700,
      Colors.red.shade400,
      Colors.purple,
      Colors.green,
    ];
    int colorIndex = 0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child:
                  data.isEmpty
                      ? const Center(child: Text("Pas de données"))
                      : PieChart(
                        PieChartData(
                          sections:
                              data.entries.map((entry) {
                                final color =
                                    colors[colorIndex % colors.length];
                                colorIndex++;
                                return PieChartSectionData(
                                  color: color,
                                  value: entry.value.toDouble(),
                                  title: '${entry.value}',
                                  radius: 80,
                                  titleStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Légende",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children:
                  data.entries.map((entry) {
                    final sectionIndex = data.keys.toList().indexOf(entry.key);
                    final color = colors[sectionIndex % colors.length];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 16, height: 16, color: color),
                        const SizedBox(width: 8),
                        Text("${entry.key} (${entry.value})"),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
