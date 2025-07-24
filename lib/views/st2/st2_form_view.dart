import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ST2FormView extends StatefulWidget {
  const ST2FormView({super.key});

  @override
  State<ST2FormView> createState() => _ST2FormViewState();
}

class _ST2FormViewState extends State<ST2FormView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers Page 1
  final _nomEtsController = TextEditingController();
  final _adresseEtsController = TextEditingController();
  final _nomChefController = TextEditingController();
  final _telChefController = TextEditingController();
  final _villeController = TextEditingController();
  final _territoireController = TextEditingController();
  final _villageController = TextEditingController();
  final _provinceEducController = TextEditingController();
  final _refJuridiqueController = TextEditingController();
  final _matriculeSecopeController = TextEditingController();
  String? niveauEcole;

  final TextEditingController _nbEnseignantsTotal = TextEditingController();

  // Pour classes autorisées et organisées
  Map<String, TextEditingController> classesAutorisees = {};
  Map<String, TextEditingController> classesOrganisees = {};

  // Pour effectifs garçons et filles
  Map<String, TextEditingController> effectifGarcons = {};
  Map<String, TextEditingController> effectifFilles = {};

  // Pour les enseignants
  List<Map<String, TextEditingController>> enseignants = [];
  // Page 4 - Manuels scolaires
  Map<String, Map<String, TextEditingController>> manuelsParAnnee = {
    'Français': {},
    'Mathématiques': {},
    'Eveil': {},
    'ECM': {},
    'Transversaux': {},
    'Autres': {},
  };

  // Page 4 - Équipements
  Map<String, TextEditingController> bonsEtats = {};
  Map<String, TextEditingController> mauvaisEtats = {};

  @override
  void initState() {
    super.initState();

    // Mise à jour automatique des enseignants selon le total renseigné
    _nbEnseignantsTotal.addListener(() {
      final total = int.tryParse(_nbEnseignantsTotal.text) ?? 0;

      // On recrée les lignes du tableau enseignant
      if (enseignants.length != total) {
        enseignants = List.generate(
          total,
          (_) => {
            'nom': TextEditingController(),
            'sexe': TextEditingController(),
            'age': TextEditingController(),
            'matricule': TextEditingController(),
            'salaire': TextEditingController(),
            'annee': TextEditingController(),
            'qualification': TextEditingController(),
          },
        );

        // Rafraîchir l'UI
        setState(() {});
      }
    });
    final annees = ['1ère', '2ème', '3ème', '4ème', '5ème', '6ème'];
    final matieres = [
      'Français',
      'Mathématiques',
      'Eveil',
      'ECM',
      'Transversaux',
      'Autres',
    ];

    for (final matiere in matieres) {
      for (final annee in annees) {
        manuelsParAnnee[matiere]![annee] = TextEditingController();
      }
    }

    final equipements = [
      'Tableaux',
      'Tables',
      'Chaises',
      'Ordinateurs',
      'Photocopieuses',
      'Kits scientifiques',
      'Équipements spécifiques',
    ];

    for (final eq in equipements) {
      bonsEtats[eq] = TextEditingController();
      mauvaisEtats[eq] = TextEditingController();
    }
  }

  // Dropdown values
  String? _periode;
  String? _province;
  String? _sousDivision;
  String? _regime;
  String? _mecanisation;
  String? _occupation;
  String? _provinceEduc;

  final _periodes = ['SEMESTRE 1', 'SEMESTRE 2'];
  final _provinces = ['Haut-Lomami'];
  final _sousDivisions = [
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
  final _regimes = [
    'ENC',
    'Catholique',
    'Protestant',
    'ECK',
    'ECI',
    'Salutiste (ECS)',
    'Fraternité (ECF)',
    'Privée (EPR)',
    'Autres',
  ];
  final _pronvinceEduc = ['Haut-Lomami 1'];
  final _mecanisations = ['Mécanisé et payé', 'Mécanisé et non payé'];
  final _occupations = ['Propriétaire', 'Co-propriétaire', 'Locataire'];

  // Controllers Page 2
  bool hasProgrammes = false;
  bool hasCOPA = false;
  bool copaOp = false;
  final _nbFemmesCOPAController = TextEditingController();
  bool hasCOGES = false;
  bool cogesOp = false;
  final _nbReunionCOGESController = TextEditingController();
  final _nbFemmesCOGESController = TextEditingController();
  bool sharedLocaux = false;
  final _nomSecondEtsController = TextEditingController();
  bool hasEau = false;
  bool eauRobinet = false, eauForage = false, eauSource = false;
  bool hasEnergie = false;
  bool elec = false, solaire = false, groupe = false;
  bool hasLatrines = false;
  final _nbLatrinesController = TextEditingController();
  final _nbFillesLatrinesController = TextEditingController();
  bool hasCour = false;
  bool hasTerrain = false;
  bool hasCloture = false;
  bool enDur = false, semiDur = false, haie = false, autreCloture = false;
  bool hasBudget = false;
  bool hasPlanAction = false;
  final _nbEnsFormesController = TextEditingController();
  final _nbEnsPositifsController = TextEditingController();
  final _nbEnsInspectesController = TextEditingController();
  bool hasGovEleves = false;

  @override
  void dispose() {
    _nomEtsController.dispose();
    _adresseEtsController.dispose();
    _nomChefController.dispose();
    _telChefController.dispose();
    _villeController.dispose();
    _territoireController.dispose();
    _villageController.dispose();
    _provinceEducController.dispose();
    _refJuridiqueController.dispose();
    _matriculeSecopeController.dispose();
    _nbFemmesCOPAController.dispose();
    _nbReunionCOGESController.dispose();
    _nbFemmesCOGESController.dispose();
    _nomSecondEtsController.dispose();
    _nbLatrinesController.dispose();
    _nbFillesLatrinesController.dispose();
    _nbEnsFormesController.dispose();
    _nbEnsPositifsController.dispose();
    _nbEnsInspectesController.dispose();

    _nbEnseignantsTotal.dispose();
    for (final c in classesAutorisees.values) c.dispose();
    for (final c in classesOrganisees.values) c.dispose();
    for (final c in effectifGarcons.values) c.dispose();
    for (final c in effectifFilles.values) c.dispose();
    for (final e in enseignants) {
      for (final c in e.values) c.dispose();
    }
    for (final m in manuelsParAnnee.values) {
      for (final c in m.values) {
        c.dispose();
      }
    }

    for (final c in bonsEtats.values) {
      c.dispose();
    }
    for (final c in mauvaisEtats.values) {
      c.dispose();
    }

    super.dispose();
  }

  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      if (_currentPage < 3) {
        setState(() => _currentPage++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      print("✅ Formulaire ST2 soumis avec succès !");
    }
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontSize: 13),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.blue),
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        inputFormatters:
            type == TextInputType.number
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
        decoration: _inputDecoration(label),
        style: const TextStyle(fontSize: 13),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Champ requis';
          if (type == TextInputType.number && int.tryParse(value) == null) {
            return 'Nombre invalide';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    void Function(String?)? onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: _inputDecoration(label),
        style: const TextStyle(fontSize: 13, color: Colors.black),
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Sélectionnez une option' : null,
      ),
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    void Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formulaire ST2")),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // PAGE 1
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField(
                    _nomEtsController,
                    "Nom de l'établissement",
                    TextInputType.text,
                  ),
                  _buildTextField(
                    _adresseEtsController,
                    "Adresse de l'établissement",
                    TextInputType.text,
                  ),
                  _buildTextField(
                    _nomChefController,
                    "Nom du chef de l'établissement",
                    TextInputType.text,
                  ),
                  _buildTextField(
                    _telChefController,
                    "Téléphone du chef d’établissement",
                    TextInputType.number,
                  ),
                  _buildDropdown(
                    "Période",
                    _periode,
                    _periodes,
                    (val) => setState(() => _periode = val),
                  ),
                  _buildDropdown(
                    "Province",
                    _province,
                    _provinces,
                    (val) => setState(() => _province = val),
                  ),
                  _buildTextField(
                    _villeController,
                    "Ville ou village",
                    TextInputType.text,
                  ),
                  _buildTextField(
                    _territoireController,
                    "Territoire ou commune",
                    TextInputType.text,
                  ),

                  _buildDropdown(
                    "Province Educationnelle",
                    _provinceEduc,
                    _pronvinceEduc,
                    (val) => setState(() => _provinceEduc = val),
                  ),
                  _buildDropdown(
                    "Sous-division",
                    _sousDivision,
                    _sousDivisions,
                    (val) => setState(() => _sousDivision = val),
                  ),
                  _buildDropdown(
                    "Régime de gestion",
                    _regime,
                    _regimes,
                    (val) => setState(() => _regime = val),
                  ),

                  _buildTextField(
                    _matriculeSecopeController,
                    "N° Matricule SECOPE",
                    TextInputType.number,
                  ),
                  _buildDropdown(
                    "L’établissement est",
                    _mecanisation,
                    _mecanisations,
                    (val) => setState(() => _mecanisation = val),
                  ),
                  _buildDropdown(
                    "Statut d’occupation parcellaire",
                    _occupation,
                    _occupations,
                    (val) => setState(() => _occupation = val),
                  ),
                ],
              ),
            ),

            // PAGE 2
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCheckbox(
                    "Des programmes officiels de cours ?",
                    hasProgrammes,
                    (val) => setState(() => hasProgrammes = val!),
                  ),
                  _buildCheckbox(
                    "Dispose-t-il d’un COPA ?",
                    hasCOPA,
                    (val) => setState(() => hasCOPA = val!),
                  ),
                  if (hasCOPA) ...[
                    _buildCheckbox(
                      "Le COPA est-il opérationnel ?",
                      copaOp,
                      (val) => setState(() => copaOp = val!),
                    ),
                    _buildTextField(
                      _nbFemmesCOPAController,
                      "Nombre de femmes dans le COPA",
                      TextInputType.number,
                    ),
                  ],
                  _buildCheckbox(
                    "Dispose-t-il d’un COGES ?",
                    hasCOGES,
                    (val) => setState(() => hasCOGES = val!),
                  ),
                  if (hasCOGES) ...[
                    _buildCheckbox(
                      "Le COGES est-il opérationnel ?",
                      cogesOp,
                      (val) => setState(() => cogesOp = val!),
                    ),
                    _buildTextField(
                      _nbReunionCOGESController,
                      "Nombre de réunions COGES (an)",
                      TextInputType.number,
                    ),
                    _buildTextField(
                      _nbFemmesCOGESController,
                      "Nombre de femmes dans le COGES",
                      TextInputType.number,
                    ),
                  ],

                  _buildCheckbox(
                    "Dispose-t-il d’un point d’eau ?",
                    hasEau,
                    (val) => setState(() => hasEau = val!),
                  ),
                  if (hasEau) ...[
                    _buildCheckbox(
                      "Robinet",
                      eauRobinet,
                      (val) => setState(() => eauRobinet = val!),
                    ),
                    _buildCheckbox(
                      "Forage/puits",
                      eauForage,
                      (val) => setState(() => eauForage = val!),
                    ),
                    _buildCheckbox(
                      "Source",
                      eauSource,
                      (val) => setState(() => eauSource = val!),
                    ),
                  ],
                  _buildCheckbox(
                    "Dispose-t-il d’une source d’énergies ?",
                    hasEnergie,
                    (val) => setState(() => hasEnergie = val!),
                  ),
                  if (hasEnergie) ...[
                    _buildCheckbox(
                      "Électrique",
                      elec,
                      (val) => setState(() => elec = val!),
                    ),
                    _buildCheckbox(
                      "Solaire",
                      solaire,
                      (val) => setState(() => solaire = val!),
                    ),
                    _buildCheckbox(
                      "Groupe électrogène",
                      groupe,
                      (val) => setState(() => groupe = val!),
                    ),
                  ],
                  _buildCheckbox(
                    "Dispose-t-il de latrines (WC) ?",
                    hasLatrines,
                    (val) => setState(() => hasLatrines = val!),
                  ),
                  if (hasLatrines) ...[
                    _buildTextField(
                      _nbLatrinesController,
                      "Nombre de compartiments",
                      TextInputType.number,
                    ),
                    _buildTextField(
                      _nbFillesLatrinesController,
                      "Dont pour les filles",
                      TextInputType.number,
                    ),
                  ],

                  _buildCheckbox(
                    "Dispose-t-il de prévisions budgétaires ?",
                    hasBudget,
                    (val) => setState(() => hasBudget = val!),
                  ),
                  _buildCheckbox(
                    "Dispose-t-il d’un plan d’action opérationnel ?",
                    hasPlanAction,
                    (val) => setState(() => hasPlanAction = val!),
                  ),
                  _buildTextField(
                    _nbEnsFormesController,
                    "Nombre d’enseignants formés",
                    TextInputType.number,
                  ),
                  if (_nbEnsFormesController.text.isNotEmpty &&
                      int.tryParse(_nbEnsFormesController.text) != null &&
                      int.parse(_nbEnsFormesController.text) > 0)
                    _buildTextField(
                      _nbEnsPositifsController,
                      "Enseignants cotés positivement",
                      TextInputType.number,
                    ),
                  _buildTextField(
                    _nbEnsInspectesController,
                    "Nombre d’inspections pédagogiques C3",
                    TextInputType.number,
                  ),
                  _buildCheckbox(
                    "Existe-t-il un Gouvernement d’Élèves opérationnel ?",
                    hasGovEleves,
                    (val) => setState(() => hasGovEleves = val!),
                  ),
                ],
              ),
            ),
            // page 3
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdown(
                    "Niveau de l'école",
                    niveauEcole,
                    ['MATERNEL', 'PRIMAIRE', 'SECONDAIRE'],
                    (val) => setState(() {
                      niveauEcole = val;
                      classesAutorisees.clear();
                      classesOrganisees.clear();
                      effectifGarcons.clear();
                      effectifFilles.clear();
                    }),
                  ),
                  const SizedBox(height: 10),

                  if (niveauEcole != null) ...[
                    const Text(
                      "NOMBRE DE CLASSES AUTORISÉES ET ORGANISÉES",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._buildClassesInputs(niveauEcole!),
                    const SizedBox(height: 20),

                    const Text(
                      "NOMBRE TOTAL D’ENSEIGNANTS",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _buildTextField(
                      _nbEnseignantsTotal,
                      "Nombre total d’enseignants",
                      TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    if (enseignants.isNotEmpty) ...[
                      const Text(
                        "INFORMATIONS RELATIVES AU PERSONNEL ENSEIGNANT",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      for (int i = 0; i < enseignants.length; i++)
                        Column(
                          children: [
                            _buildTextField(
                              enseignants[i]['nom']!,
                              "Nom enseignant n°${i + 1}",
                              TextInputType.text,
                            ),
                            _buildTextField(
                              enseignants[i]['sexe']!,
                              "Sexe (H/F)",
                              TextInputType.text,
                            ),
                            _buildTextField(
                              enseignants[i]['age']!,
                              "Âge",
                              TextInputType.number,
                            ),
                            _buildTextField(
                              enseignants[i]['matricule']!,
                              "N° Matricule (SECOPE)",
                              TextInputType.text,
                            ),
                            _buildTextField(
                              enseignants[i]['salaire']!,
                              "Situation salariale (Payé/Non Payé)",
                              TextInputType.text,
                            ),
                            _buildTextField(
                              enseignants[i]['annee']!,
                              "Année d'engagement",
                              TextInputType.number,
                            ),
                            _buildTextField(
                              enseignants[i]['qualification']!,
                              "Qualification",
                              TextInputType.text,
                            ),
                            const Divider(),
                          ],
                        ),
                    ],

                    const Text(
                      "EFFECTIFS DES ÉLÈVES INSCRITS PAR SEXE ET ANNÉE D’ÉTUDES",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ..._buildEffectifInputs(niveauEcole!),
                  ],
                ],
              ),
            ),

            // PAGE 4
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nombre de manuels disponibles utilisables par année d’études",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  ...manuelsParAnnee.entries.map((entry) {
                    final matiere = entry.key;
                    final controllers = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          matiere,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children:
                              [
                                '1ère',
                                '2ème',
                                '3ème',
                                '4ème',
                                '5ème',
                                '6ème',
                              ].map((annee) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: TextField(
                                      controller: controllers[annee],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: annee,
                                        border: const UnderlineInputBorder(),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 20),
                  Text(
                    "TOTAL MANUELS : ${_calculerTotalManuels()}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const Divider(height: 40),

                  const Text(
                    "NOMBRE D’ÉQUIPEMENTS EXISTANTS",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  ...bonsEtats.keys.map((equipement) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equipement,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: bonsEtats[equipement],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Bon état",
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: mauvaisEtats[equipement],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Mauvais état",
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "TOTAL bon état : ${_calculerTotalEquipement(bonsEtats)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "TOTAL mauvais état : ${_calculerTotalEquipement(mauvaisEtats)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _previousPage,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Précédent"),
                ),
              ),
            if (_currentPage > 0 && _currentPage < 3) const SizedBox(width: 10),
            if (_currentPage < 3)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _nextPage,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Suivant"),
                ),
              ),
            if (_currentPage == 3)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.check),
                  label: const Text("Soumettre"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 👉 Fonction pour la somme automatique
  int _somme(Map<String, TextEditingController> map) {
    return map.values
        .map((c) => int.tryParse(c.text) ?? 0)
        .fold(0, (a, b) => a + b);
  }

  // 👉 Fonction pour construire les inputs des classes autorisées/organisées
  List<Widget> _buildClassesInputs(String niveau) {
    final niveaux =
        {
          'MATERNEL': ['1ère année', '2ème année', '3ème année'],
          'PRIMAIRE': ['1ère', '2ème', '3ème', '4ème', '5ème', '6ème'],
          'SECONDAIRE': ['7ème', '8ème', '1ère', '2ème', '3ème', '4ème'],
        }[niveau]!;

    return niveaux.map((niv) {
      classesAutorisees[niv] ??= TextEditingController();
      classesOrganisees[niv] ??= TextEditingController();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Expanded(
              child: _buildTextField(
                classesAutorisees[niv]!,
                "$niv - Autorisées",
                TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                classesOrganisees[niv]!,
                "$niv - Organisées",
                TextInputType.number,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  int _calculerTotalManuels() {
    int total = 0;
    for (final matiere in manuelsParAnnee.values) {
      for (final c in matiere.values) {
        total += int.tryParse(c.text) ?? 0;
      }
    }
    return total;
  }

  int _calculerTotalEquipement(Map<String, TextEditingController> map) {
    return map.values.fold(0, (sum, c) => sum + (int.tryParse(c.text) ?? 0));
  }

  // 👉 Fonction pour construire les inputs des effectifs garçons/filles
  List<Widget> _buildEffectifInputs(String niveau) {
    final classes =
        {
          'MATERNEL': ['1ère', '2ème', '3ème'],
          'PRIMAIRE': ['1ère', '2ème', '3ème', '4ème', '5ème', '6ème'],
          'SECONDAIRE': ['1ère', '2ème', '3ème', '4ème', '5ème', '6ème'],
        }[niveau]!;

    return [
      ...classes.map((c) {
        effectifGarcons[c] ??= TextEditingController();
        effectifFilles[c] ??= TextEditingController();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Expanded(
                child: _buildTextField(
                  effectifGarcons[c]!,
                  "$c - Garçons",
                  TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  effectifFilles[c]!,
                  "$c - Filles",
                  TextInputType.number,
                ),
              ),
            ],
          ),
        );
      }),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: Text(
              "Total garçons: ${_somme(effectifGarcons)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              "Total filles: ${_somme(effectifFilles)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ];
  }
}
