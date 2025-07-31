// lib/views/dashboard/chef_service_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:educ_collecteur/models/st2_model.dart';
import 'package:educ_collecteur/controllers/auth_controller.dart';
import 'package:educ_collecteur/providers/theme_provider.dart';
import 'statistics_page.dart';
import 'report_generation_page.dart';
import 'saved_reports_page.dart'; // <-- 1. IMPORTEZ LA NOUVELLE PAGE

class ChefServiceDashboardView extends StatefulWidget {
  const ChefServiceDashboardView({super.key});

  @override
  State<ChefServiceDashboardView> createState() =>
      _ChefServiceDashboardViewState();
}

class _ChefServiceDashboardViewState extends State<ChefServiceDashboardView> {
  // Contrôleurs
  final AuthController _authController = AuthController();
  final TextEditingController _searchController = TextEditingController();

  // Variables pour les filtres
  String? _selectedNiveau;
  String? _selectedProvinceEdu;
  String? _selectedSousDivision;
  String? _selectedRegimeGestion;
  String? _selectedPeriode;

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
    'Kiondo-Kiambidi',
  ];
  final List<String> _regimesGestion = [
    'ENC',
    'Catholique',
    'Protestant',
    'ECK',
    'ECI',
    'Privée (EPR)',
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

    // Correction de la syntaxe des 'if' pour plus de clarté
    if (_selectedNiveau != null) {
      query = query.where(
        'niveauEcole',
        isEqualTo: _selectedNiveau!.toLowerCase(),
      );
    }
    if (_selectedProvinceEdu != null) {
      query = query.where(
        'provinceEducationnelle',
        isEqualTo: _selectedProvinceEdu,
      );
    }
    if (_selectedSousDivision != null) {
      query = query.where('sousDivision', isEqualTo: _selectedSousDivision);
    }
    if (_selectedRegimeGestion != null) {
      query = query.where('regimeGestion', isEqualTo: _selectedRegimeGestion);
    }
    if (_selectedPeriode != null) {
      query = query.where('periode', isEqualTo: _selectedPeriode);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) => ST2Model.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList(),
    );
  }

  void _applyFilters() {
    setState(() {
      _st2Stream = _fetchAndFilterForms();
    });
  }

  Future<void> _deleteForm(ST2Model form) async {
    // Votre logique de suppression ici (non affichée pour la clarté)
  }
  Future<void> _validateForm(ST2Model form) async {
    // Votre logique de validation ici (non affichée pour la clarté)
  }
  void _editForm(ST2Model form) {
    // Votre logique d'édition ici (non affichée pour la clarté)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Chef de Service")),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildFilterControls(),
          Expanded(
            child: StreamBuilder<List<ST2Model>>(
              stream: _st2Stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("ERREUR DU STREAMBUILDER: ${snapshot.error}");
                  return Center(child: Text("Erreur: ${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun formulaire ne correspond aux filtres actuels.",
                    ),
                  );
                }

                final forms =
                    snapshot.data!.where((form) {
                      final searchQuery = _searchController.text.toLowerCase();
                      return form.schoolName.toLowerCase().contains(
                            searchQuery,
                          ) ||
                          form.chefEtablissementName.toLowerCase().contains(
                            searchQuery,
                          );
                    }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: forms.length,
                  itemBuilder: (context, index) {
                    final form = forms[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                          form.schoolName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Chef: ${form.chefEtablissementName}\nStatut: ${form.status}',
                          style: TextStyle(
                            color:
                                form.status == 'Validé'
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _editForm(form);
                            if (value == 'delete') _deleteForm(form);
                            if (value == 'validate') _validateForm(form);
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Modifier'),
                                ),
                                if (form.status != 'Validé')
                                  const PopupMenuItem(
                                    value: 'validate',
                                    child: Text('Valider'),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Supprimer',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/st2_detail_view',
                            arguments: form,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le menu latéral (Drawer)
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
                  _authController.auth.currentUser?.email ?? "Non connecté",
                ),
                currentAccountPicture: const CircleAvatar(
                  child: Icon(Icons.supervisor_account, size: 40),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.folder_copy_outlined),
                title: const Text('Gérer les ST2'),
                onTap: () => Navigator.of(context).pop(),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Générer un rapport'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportGenerationPage(),
                    ),
                  );
                },
              ),
              // --- 2. AJOUT DU NOUVEL ÉLÉMENT DE MENU ---
              ListTile(
                leading: const Icon(Icons.history_edu_outlined),
                title: const Text('Rapports Enregistrés'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedReportsPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart_outlined),
                title: const Text('Statistiques'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsPage(),
                    ),
                  );
                },
              ),
              ExpansionTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text("Paramètres"),
                children: [
                  SwitchListTile(
                    title: const Text("Mode Sombre"),
                    secondary: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      final provider = Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      );
                      provider.toggleTheme(value);
                    },
                  ),
                ],
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Déconnexion'),
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

  /// Construit les contrôles de filtre et de recherche
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
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        _niveaux,
                        'Niveau',
                        _selectedNiveau,
                        (val) => _selectedNiveau = val,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdown(
                        _periodes,
                        'Période',
                        _selectedPeriode,
                        (val) => _selectedPeriode = val,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        _regimesGestion,
                        'Régime',
                        _selectedRegimeGestion,
                        (val) => _selectedRegimeGestion = val,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdown(
                        _sousDivisions,
                        'Sous-division',
                        _selectedSousDivision,
                        (val) => _selectedSousDivision = val,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDropdown(
                  _provincesEdu,
                  'Province Éducationnelle',
                  _selectedProvinceEdu,
                  (val) => _selectedProvinceEdu = val,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text("Appliquer les filtres"),
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget helper pour construire un menu déroulant.
  Widget _buildDropdown(
    List<String> items,
    String hint,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: Text(hint),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      isExpanded: true,
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
      onChanged: (val) => setState(() => onChanged(val)),
    );
  }
}
