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
  // --- NOUVELLE LOGIQUE DE NAVIGATION PAR ONGLETS ---
  int _selectedIndex = 0;

  // Liste des vues (ou "pages") à afficher dans le corps du Scaffold
  final List<Widget> _pages = [
    const _FormsManagementPage(), // La page de gestion des formulaires est maintenant le premier onglet
    const StatisticsPage(),
    const SavedReportsPage(),
    const ReportGenerationPage(),
  ];

  // Titres correspondants pour la barre d'applications
  final List<String> _pageTitles = [
    'Gestion des Formulaires',
    'Statistiques',
    'Rapports Enregistrés',
    'Génération de Rapports'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_pageTitles[_selectedIndex]), // Le titre change dynamiquement
      ),
      drawer: _buildDrawer(),
      // Le corps du Scaffold est maintenant un IndexedStack.
      // Il affiche seulement l'onglet actif tout en gardant les autres en mémoire pour une navigation rapide.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // --- NOUVELLE BARRE DE NAVIGATION STANDARD ET ÉQUILIBRÉE ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed, // Empêche les icônes de bouger
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_copy_outlined),
            label: 'Gérer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Statistiques',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu_outlined),
            label: 'Rapports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.picture_as_pdf_outlined),
            label: 'Générer',
          ),
        ],
      ),
    );
  }

  // Le widget pour le menu latéral reste inchangé.
  Drawer _buildDrawer() {
    final authController = AuthController();
    return Drawer(
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text("Chef de Service"),
                accountEmail: Text(
                    authController.auth.currentUser?.email ?? "Non connecté"),
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
                  await authController.signOut();
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

// --- NOUVEAU WIDGET : GESTION DES FORMULAIRES ---
// L'ancienne logique du body est encapsulée dans son propre widget pour un code plus propre.

class _FormsManagementPage extends StatefulWidget {
  const _FormsManagementPage();

  @override
  State<_FormsManagementPage> createState() => __FormsManagementPageState();
}

class __FormsManagementPageState extends State<_FormsManagementPage> {
  final ST2Controller _st2Controller = ST2Controller();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedNiveau,
      _selectedProvinceEdu,
      _selectedSousDivision,
      _selectedRegimeGestion,
      _selectedPeriode;
  late Stream<List<ST2Model>> _st2Stream;

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    return Column(
      children: [
        _buildFilterControls(),
        Expanded(child: _buildFormsList()),
      ],
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

        if (forms.isEmpty)
          return const Center(
              child: Text("Aucun formulaire trouvé pour cette recherche."));

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
