// lib/views/dashboard/chef_service_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- IMPORTS DE VOTRE PROJET ---
import 'package:educ_collecteur/models/st2_model.dart';
import 'package:educ_collecteur/controllers/st2_controller.dart';
import 'package:educ_collecteur/controllers/auth_controller.dart';
import 'package:educ_collecteur/providers/theme_provider.dart';
import 'package:educ_collecteur/views/st2/st2_detail_view.dart';
import 'statistics_page.dart';
import 'report_generation_page.dart';
import 'saved_reports_page.dart';

class ChefServiceDashboardView extends StatefulWidget {
  const ChefServiceDashboardView({super.key});
  @override
  State<ChefServiceDashboardView> createState() =>
      _ChefServiceDashboardViewState();
}

class _ChefServiceDashboardViewState extends State<ChefServiceDashboardView> {
  final AuthController _authController = AuthController();
  late final PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    const _ManageFormsPage(),
    const StatisticsPage(),
    const SavedReportsPage(),
    const ReportGenerationPage(),
  ];

  static const List<String> _pageTitles = [
    "Gestion des Formulaires",
    "Statistiques Générales",
    "Rapports Enregistrés",
    "Générer un Rapport"
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade800;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(245),
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex],
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(primaryColor),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
            ]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.blue[100]!,
              hoverColor: Colors.blue[50]!,
              gap: 8,
              activeColor: primaryColor,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.blue[50]!,
              color: Colors.black54,
              tabs: const [
                GButton(icon: Icons.folder_shared_outlined, text: 'Gérer'),
                GButton(icon: Icons.bar_chart_outlined, text: 'Stats'),
                GButton(icon: Icons.inventory_2_outlined, text: 'Rapports'),
                GButton(icon: Icons.picture_as_pdf_outlined, text: 'Générer'),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) => _pageController.animateToPage(index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut),
            ),
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer(Color primaryColor) {
    return Drawer(
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text("Chef de Service",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                accountEmail: Text(
                    _authController.auth.currentUser?.email ?? "Non connecté",
                    style: GoogleFonts.poppins()),
                currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.supervisor_account_rounded,
                        size: 40, color: primaryColor)),
                decoration: BoxDecoration(color: primaryColor),
              ),
              SwitchListTile.adaptive(
                title: Text("Mode Sombre", style: GoogleFonts.poppins()),
                value: isDarkMode,
                onChanged: (value) =>
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleTheme(value),
                secondary: Icon(
                    isDarkMode
                        ? Icons.nightlight_round
                        : Icons.wb_sunny_rounded,
                    color: primaryColor),
                activeColor: primaryColor,
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red.shade700),
                title: Text('Déconnexion',
                    style: GoogleFonts.poppins(color: Colors.red.shade700)),
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

class _ManageFormsPage extends StatefulWidget {
  const _ManageFormsPage();
  @override
  State<_ManageFormsPage> createState() => _ManageFormsPageState();
}

class _ManageFormsPageState extends State<_ManageFormsPage> {
  final ST2Controller _st2Controller = ST2Controller();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<ST2Model>> _formsFuture;

  String? _selectedSousDivision;
  String? _selectedStatus = 'Soumis';

  final List<String> _sousDivisions = [
    'Kamina 1',
    'Kamina 2',
    'Kamina 3',
    'Kabongo 1',
    'Kabongo 2',
    'Kabongo 3',
    'Kabongo 4',
    'Kaniama 1',
    'Kaniama 2',
    'Kayamba 1',
    'Kayamba 2',
    'Kiondo-Kiambidi'
  ];
  final List<String> _statuses = ['Soumis', 'Validé', 'Rejeté', 'Tous'];

  @override
  void initState() {
    super.initState();
    _loadForms();
    _searchController.addListener(() => setState(() {}));
  }

  void _loadForms() {
    setState(() {
      _formsFuture = _st2Controller.getForms(
        context: context,
        sousDivision: _selectedSousDivision,
        status: _selectedStatus == 'Tous' ? null : _selectedStatus,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterControls(),
        Expanded(
          child: FutureBuilder<List<ST2Model>>(
            future: _formsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text("Erreur: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text("Aucun formulaire ne correspond aux filtres.",
                        style: GoogleFonts.poppins()));
              }

              final allForms = snapshot.data!;
              final searchQuery = _searchController.text.toLowerCase();

              final filteredForms = allForms.where((form) {
                return form.schoolName.toLowerCase().contains(searchQuery) ||
                    form.chefEtablissementName
                        .toLowerCase()
                        .contains(searchQuery);
              }).toList();

              if (filteredForms.isEmpty && allForms.isNotEmpty) {
                return Center(
                    child: Text("Aucun résultat pour votre recherche.",
                        style: GoogleFonts.poppins()));
              }

              return RefreshIndicator(
                onRefresh: () async => _loadForms(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                  itemCount: filteredForms.length,
                  itemBuilder: (context, index) {
                    final form = filteredForms[index];
                    return _buildFormCard(form);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(ST2Model form) {
    final statusChip = _buildStatusChip(form.status);
    final submissionDate = form.submittedAt != null
        ? DateFormat('dd/MM/yyyy', 'fr_FR').format(form.submittedAt!)
        : 'N/A';
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        title: Text(form.schoolName,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
                'Chef: ${form.chefEtablissementName}\nSoumis le: $submissionDate',
                style: GoogleFonts.poppins()),
            const SizedBox(height: 8),
            statusChip,
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ST2DetailView(form: form, userRole: "chef_service")));
          _loadForms();
        },
      ),
    );
  }

  Widget _buildFilterControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text("Filtres et Recherche", style: GoogleFonts.poppins()),
        leading: const Icon(Icons.filter_list),
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                      labelText: 'Rechercher par nom (école, chef...)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildDropdown(
                            _sousDivisions,
                            'Sous-division',
                            _selectedSousDivision,
                            (val) => _selectedSousDivision = val)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildDropdown(_statuses, 'Statut',
                            _selectedStatus, (val) => _selectedStatus = val)),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Appliquer"),
                  onPressed: _loadForms,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String hint, String? selectedValue,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: Text(hint, style: GoogleFonts.poppins()),
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12)),
      isExpanded: true,
      items: items
          .map((item) => DropdownMenuItem(
              value: item,
              child: Text(item,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins())))
          .toList(),
      onChanged: (val) => setState(() => onChanged(val)),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color foregroundColor;
    switch (status) {
      case 'Validé':
        backgroundColor = Colors.green.shade100;
        foregroundColor = Colors.green.shade800;
        break;
      case 'Rejeté':
        backgroundColor = Colors.red.shade100;
        foregroundColor = Colors.red.shade800;
        break;
      default:
        backgroundColor = Colors.blue.shade100;
        foregroundColor = Colors.blue.shade800;
    }
    return Chip(
      label: Text(status,
          style:
              TextStyle(fontWeight: FontWeight.bold, color: foregroundColor)),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      side: BorderSide.none,
    );
  }
}
