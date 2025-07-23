import 'package:flutter/material.dart';

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

  // Dropdown values
  String? _periode;
  String? _province;
  String? _sousDivision;
  String? _regime;
  String? _mecanisation;
  String? _occupation;

  final _periodes = ['SEMESTRE 1', 'SEMESTRE 2'];
  final _provinces = [
    'Kinshasa',
    'Haut-Katanga',
    'Haut-Lomami',
    'Lomami',
    'Lualaba',
    'Tanganyika',
    'Kasaï',
    'Kasaï-Central',
    'Kasaï-Oriental',
    'Sankuru',
    'Maniema',
    'Sud-Kivu',
    'Nord-Kivu',
    'Ituri',
    'Tshopo',
    'Bas-Uele',
    'Haut-Uele',
    'Tshuapa',
    'Mongala',
    'Nord-Ubangi',
    'Sud-Ubangi',
    'Équateur',
    'Maï-Ndombe',
    'Kwilu',
    'Kwango',
    'Kongo-Central',
  ];
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
      // Envoyer les données
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
        decoration: _inputDecoration(label),
        style: const TextStyle(fontSize: 13),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Champ requis';
          if (type == TextInputType.number && double.tryParse(value) == null) {
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
                    "Ville",
                    TextInputType.text,
                  ),
                  _buildTextField(
                    _territoireController,
                    "Territoire ou commune",
                    TextInputType.text,
                  ),
                  _buildTextField(
                    _villageController,
                    "Village",
                    TextInputType.text,
                  ),
                  _buildTextField(
                    _provinceEducController,
                    "Province éducationnelle",
                    TextInputType.text,
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
                    _refJuridiqueController,
                    "Réf. juridique (arrêté)",
                    TextInputType.text,
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
                    "Les locaux sont-ils utilisés par un 2ème établissement ?",
                    sharedLocaux,
                    (val) => setState(() => sharedLocaux = val!),
                  ),
                  if (sharedLocaux)
                    _buildTextField(
                      _nomSecondEtsController,
                      "Nom du 2ème établissement",
                      TextInputType.text,
                    ),
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
                    "Dispose-t-il d’une cour de récréation ?",
                    hasCour,
                    (val) => setState(() => hasCour = val!),
                  ),
                  _buildCheckbox(
                    "Dispose-t-il d’un terrain de sport ?",
                    hasTerrain,
                    (val) => setState(() => hasTerrain = val!),
                  ),
                  _buildCheckbox(
                    "Dispose-t-il d’une clôture ?",
                    hasCloture,
                    (val) => setState(() => hasCloture = val!),
                  ),
                  if (hasCloture) ...[
                    _buildCheckbox(
                      "En dur",
                      enDur,
                      (val) => setState(() => enDur = val!),
                    ),
                    _buildCheckbox(
                      "En semi dur",
                      semiDur,
                      (val) => setState(() => semiDur = val!),
                    ),
                    _buildCheckbox(
                      "En haie",
                      haie,
                      (val) => setState(() => haie = val!),
                    ),
                    _buildCheckbox(
                      "Autres",
                      autreCloture,
                      (val) => setState(() => autreCloture = val!),
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

            // PAGE 3 - vide
            const Center(
              child: Text("Page 3 : DONNÉES PÉDAGOGIQUES (à implémenter)"),
            ),

            // PAGE 4 - vide
            const Center(
              child: Text("Page 4 : INFRASTRUCTURES (à implémenter)"),
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
}
