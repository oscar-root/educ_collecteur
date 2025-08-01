// lib/views/dashboard/chef_service_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:educ_collecteur/models/st2_model.dart';
import 'package:educ_collecteur/controllers/auth_controller.dart';
import 'package:educ_collecteur/providers/theme_provider.dart';
import 'package:educ_collecteur/controllers/st2_controller.dart';
import 'statistics_page.dart';
import 'report_generation_page.dart';
import 'saved_reports_page.dart';
import 'package:educ_collecteur/views/st2/st2_detail_view.dart';

class ChefServiceDashboardView extends StatefulWidget {
  const ChefServiceDashboardView({super.key});

  @override
  State<ChefServiceDashboardView> createState() =>
      _ChefServiceDashboardViewState();
}

class _ChefServiceDashboardViewState extends State<ChefServiceDashboardView> {
  // Contrôleurs
  final AuthController _authController = AuthController();
  final ST2Controller _st2Controller = ST2Controller();
  final TextEditingController _searchController = TextEditingController();

  // Variables pour les filtres
  String? _selectedNiveau,
      _selectedProvinceEdu,
      _selectedSousDivision,
      _selectedRegimeGestion,
      _selectedPeriode;

  // Stream pour écouter les données ST2 en temps réel
  late Stream<List<ST2Model>> _st2Stream;

  // Listes pour les menus déroulants des filtres
  final List<String> _niveaux = ['Maternel', 'Primaire', 'Secondaire'];
  final List<String> _provincesEdu = ['HAUT-LOMAMI 1'];
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
  final List<String> _regimesGestion = [
    'ENC',
    'Catholique',
    'Protestant',
    'ECK',
    'ECI',
    'Privée (EPR)'
  ];
  final List<String> _periodes = ['SEMESTRE 1', 'SEMESTRE 2'];

  @override
  void initState() {
    super.initState();
    _st2Stream = _fetchAndFilterForms();
    _searchController.addListener(() => setState(() {}));
  }

  Stream<List<ST2Model>> _fetchAndFilterForms() {
    Query query = FirebaseFirestore.instance
        .collection('st2_forms')
        .orderBy('submittedAt', descending: true);
    if (_selectedNiveau != null)
      query =
          query.where('niveauEcole', isEqualTo: _selectedNiveau!.toLowerCase());
    if (_selectedProvinceEdu != null)
      query = query.where('provinceEducationnelle',
          isEqualTo: _selectedProvinceEdu);
    if (_selectedSousDivision != null)
      query = query.where('sousDivision', isEqualTo: _selectedSousDivision);
    if (_selectedRegimeGestion != null)
      query = query.where('regimeGestion', isEqualTo: _selectedRegimeGestion);
    if (_selectedPeriode != null)
      query = query.where('periode', isEqualTo: _selectedPeriode);
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ST2Model.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }

  void _applyFilters() => setState(() => _st2Stream = _fetchAndFilterForms());

  Future<void> _deleteForm(ST2Model form) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la Suppression"),
        content: Text(
            "Êtes-vous sûr de vouloir supprimer définitivement le formulaire de l'école ${form.schoolName} ?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Annuler")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child:
                  const Text("Supprimer", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await _st2Controller.deleteST2Form(form.id!, context);
    }
  }

  Future<void> _validateForm(ST2Model form) async {
    await _st2Controller.validateST2Form(form.id!, context);
  }

  void _navigateToDetail(ST2Model form) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => ST2DetailView(form: form)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Chef de Service")),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildFilterControls(),
          Expanded(child: _buildFormsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // L'action principale est de voir les formulaires
        tooltip: 'Gérer les ST2',
        child: const Icon(Icons.folder_copy_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // --- BARRE DE NAVIGATION MISE À JOUR ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
                icon: Icons.bar_chart_outlined,
                label: 'Statistiques',
                page: const StatisticsPage()),
            _buildNavItem(
                icon: Icons.history_edu_outlined,
                label: 'Rapports',
                page: const SavedReportsPage()),
            const SizedBox(width: 48), // Espace pour le FAB
            _buildNavItem(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Générer',
                page: const ReportGenerationPage()),
            // L'icône des paramètres a été retirée.
            // On ajoute un SizedBox pour équilibrer l'espace.
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required String label, Widget? page}) {
    return IconButton(
      icon: Icon(icon, color: Colors.grey.shade700),
      onPressed: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page!)),
      tooltip: label,
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text("Chef de Service"),
                accountEmail: Text(
                    _authController.auth.currentUser?.email ?? "Non connecté"),
                currentAccountPicture: const CircleAvatar(
                    child: Icon(Icons.supervisor_account, size: 40)),
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
              ),
              ExpansionTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text("Paramètres"),
                children: [
                  SwitchListTile(
                    title: const Text("Mode Sombre"),
                    secondary: Icon(themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.toggleTheme(value),
                  ),
                ],
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Déconnexion',
                    style: TextStyle(color: Colors.red)),
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

  Widget _buildFormsList() {
    return StreamBuilder<List<ST2Model>>(
      stream: _st2Stream,
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text("Erreur: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Center(
              child:
                  Text("Aucun formulaire ne correspond aux filtres actuels."));

        final forms = snapshot.data!.where((form) {
          final searchQuery = _searchController.text.toLowerCase();
          return form.schoolName.toLowerCase().contains(searchQuery) ||
              form.chefEtablissementName.toLowerCase().contains(searchQuery);
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: forms.length,
          itemBuilder: (context, index) {
            final form = forms[index];
            final isValidated = form.status == 'Validé';
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isValidated
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  child: Icon(
                      isValidated
                          ? Icons.check_circle_outline
                          : Icons.hourglass_top_outlined,
                      color: isValidated ? Colors.green : Colors.orange),
                ),
                title: Text(form.schoolName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Chef: ${form.chefEtablissementName}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'detail') _navigateToDetail(form);
                    if (value == 'validate') _validateForm(form);
                    if (value == 'delete') _deleteForm(form);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'detail', child: Text('Voir les Détails')),
                    if (!isValidated)
                      const PopupMenuItem(
                          value: 'validate', child: Text('Valider')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Supprimer',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
                onTap: () => _navigateToDetail(form),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: const Text("Recherche et Filtres"),
        leading: const Icon(Icons.filter_list),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                        labelText: 'Rechercher par nom (école, chef...)',
                        prefixIcon: Icon(Icons.search))),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _buildDropdown(_niveaux, 'Niveau', _selectedNiveau,
                          (val) => _selectedNiveau = val)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildDropdown(_periodes, 'Période',
                          _selectedPeriode, (val) => _selectedPeriode = val))
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _buildDropdown(
                          _regimesGestion,
                          'Régime',
                          _selectedRegimeGestion,
                          (val) => _selectedRegimeGestion = val)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildDropdown(
                          _sousDivisions,
                          'Sous-division',
                          _selectedSousDivision,
                          (val) => _selectedSousDivision = val))
                ]),
                const SizedBox(height: 10),
                _buildDropdown(_provincesEdu, 'Province Éducationnelle',
                    _selectedProvinceEdu, (val) => _selectedProvinceEdu = val),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("Appliquer les filtres"),
                    onPressed: _applyFilters),
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
      hint: Text(hint),
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10)),
      isExpanded: true,
      items: items
          .map((item) => DropdownMenuItem(
              value: item, child: Text(item, overflow: TextOverflow.ellipsis)))
          .toList(),
      onChanged: (val) => setState(() => onChanged(val)),
    );
  }
}
