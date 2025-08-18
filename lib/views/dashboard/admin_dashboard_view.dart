// lib/views/dashboard/admin_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      _AdminHomePageContent(),
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
        backgroundColor: Colors.indigo,
        title: Text(_pageTitles[_selectedIndex], style: GoogleFonts.poppins()),
        // CORRIGÉ: L'icône de droite (actions) est supprimée.
        // Flutter ajoutera automatiquement l'icône "menu" à gauche car un `drawer` est défini.
      ),
      // CORRIGÉ: Le drawer est maintenant à gauche.
      drawer: _buildSettingsDrawer(context),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group),
              label: 'Gérer'),
          BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_outlined),
              activeIcon: Icon(Icons.verified_user),
              label: 'Rôles'),
          BottomNavigationBarItem(
              icon: Icon(Icons.archive_outlined),
              activeIcon: Icon(Icons.archive),
              label: 'Archives'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
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
                accountName: Text("Administrateur",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                accountEmail: Text(
                    _authController.auth.currentUser?.email ??
                        'admin@email.com',
                    style: GoogleFonts.poppins()),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings,
                      size: 40, color: Colors.indigo),
                ),
                decoration: const BoxDecoration(color: Colors.indigo),
              ),
              ListTile(
                title: Text("Options",
                    style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold)),
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
    final snapshot = await FirebaseFirestore.instance
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
      key = key.isNotEmpty
          ? key[0].toUpperCase() + key.substring(1)
          : 'Non défini';
      if (key.isNotEmpty && key != 'Non défini')
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
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text("Vue d'ensemble",
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _KpiCard(
                  title: "Utilisateurs Actifs",
                  value: users.length.toString(),
                  icon: Icons.group_outlined,
                  color: Colors.indigo),
              const SizedBox(height: 24),
              _PieChartCard(title: "Répartition par Rôle", data: roleData),
              const SizedBox(height: 24),
              _BarChartCard(
                  title: "Répartition par Niveau d'École", data: niveauData),
            ],
          ),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(width: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.grey.shade600)),
          ])
        ]),
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  final String title;
  final Map<String, int> data;
  const _BarChartCard({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.teal,
      Colors.orange.shade700,
      Colors.purple
    ];
    final barGroups = <BarChartGroupData>[];
    int index = 0;

    data.forEach((key, value) {
      barGroups.add(BarChartGroupData(x: index, barRods: [
        BarChartRodData(
            toY: value.toDouble(),
            color: colors[index % colors.length],
            width: 22,
            borderRadius: BorderRadius.circular(6))
      ]));
      index++;
    });

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontFamily: GoogleFonts.poppins().fontFamily)),
          const SizedBox(height: 24),
          SizedBox(
            height: 160, // CORRIGÉ: Taille réduite
            child: data.isEmpty
                ? const Center(child: Text("Pas de données"))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= data.keys.length)
                                    return const SizedBox.shrink();
                                  final key =
                                      data.keys.elementAt(value.toInt());
                                  return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(key,
                                          style:
                                              const TextStyle(fontSize: 12)));
                                },
                                reservedSize: 30)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1),
                      barTouchData: BarTouchData(touchTooltipData:
                          BarTouchTooltipData(getTooltipItem:
                              (group, groupIndex, rod, rodIndex) {
                        final key = data.keys.elementAt(group.x);
                        return BarTooltipItem(
                            '$key\n',
                            const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                              TextSpan(
                                  text: rod.toY.toInt().toString(),
                                  style: TextStyle(
                                      color: rod.color,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500))
                            ]);
                      })),
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}

class _PieChartCard extends StatefulWidget {
  final String title;
  final Map<String, int> data;
  const _PieChartCard({required this.title, required this.data});
  @override
  State<_PieChartCard> createState() => _PieChartCardState();
}

class _PieChartCardState extends State<_PieChartCard> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.indigo,
      Colors.green,
      Colors.amber.shade700,
      Colors.red.shade400
    ];
    int colorIndex = 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          Text(widget.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontFamily: GoogleFonts.poppins().fontFamily)),
          const SizedBox(height: 20),
          SizedBox(
            height: 150, // CORRIGÉ: Taille réduite
            child: widget.data.isEmpty
                ? const Center(child: Text("Pas de données"))
                : PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                          touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      }),
                      sections: widget.data.entries.map((entry) {
                        final isTouched =
                            widget.data.keys.toList().indexOf(entry.key) ==
                                touchedIndex;
                        final radius = isTouched ? 60.0 : 50.0; // Rayon ajusté
                        final color = colors[colorIndex % colors.length];
                        colorIndex++;
                        return PieChartSectionData(
                          color: color,
                          value: entry.value.toDouble(),
                          title: '${entry.value}',
                          radius: radius,
                          titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 2)
                              ]),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 50, // Espace central ajusté
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.center,
            children: widget.data.entries.map((entry) {
              final sectionIndex = widget.data.keys.toList().indexOf(entry.key);
              final color = colors[sectionIndex % colors.length];
              return Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 16, height: 16, color: color),
                const SizedBox(width: 8),
                Text("${entry.key} (${entry.value})"),
              ]);
            }).toList(),
          ),
        ]),
      ),
    );
  }
}
