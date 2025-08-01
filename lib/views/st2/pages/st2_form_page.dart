// lib/st2/pages/st2_form_page.dart

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:educ_collecteur/controllers/st2_controller.dart';
import 'package:educ_collecteur/models/st2_model.dart';

// Helper class (inchangée)
class _TeacherControllers {
  final TextEditingController nom = TextEditingController();
  final TextEditingController matricule = TextEditingController();
  final TextEditingController anneeEngagement = TextEditingController();
  String? sexe;
  String? situationSalariale;
  String? qualification;

  void dispose() {
    nom.dispose();
    matricule.dispose();
    anneeEngagement.dispose();
  }
}

class ST2FormPage extends StatefulWidget {
  const ST2FormPage({super.key});

  @override
  State<ST2FormPage> createState() => _ST2FormPageState();
}

class _ST2FormPageState extends State<ST2FormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ST2Controller _st2Controller = ST2Controller();

  // NOUVELLE VARIABLE D'ÉTAT POUR LE STEPPER
  int _currentStep = 0;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _niveauEcole;

  // ... (tous vos contrôleurs et notifiers restent identiques) ...
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  String? _selectedPeriode;
  final TextEditingController _villeVillageController = TextEditingController();
  final TextEditingController _refJuridiqueController = TextEditingController();
  final TextEditingController _idDinacopeController = TextEditingController();
  String? _selectedProvince = 'HAUT-LOMAMI';
  String? _selectedProvinceEdu = 'HAUT-LOMAMI 1';
  String? _selectedSousDivision;
  String? _selectedRegimeGestion;
  String? _selectedStatutEtablissement;
  bool? _hasProgrammesOfficiels;
  bool? _hasLatrines;
  final TextEditingController _latrinesTotalController =
      TextEditingController();
  final TextEditingController _latrinesFillesController =
      TextEditingController();
  bool? _hasPrevisionsBudgetaires;
  final TextEditingController _totalEnseignantsController =
      TextEditingController();
  List<_TeacherControllers> _teacherControllers = [];
  Map<String, TextEditingController> _classesOrganiseesControllers = {};
  Map<String, TextEditingController> _effectifsGarconsControllers = {};
  Map<String, TextEditingController> _effectifsFillesControllers = {};
  Map<String, Map<String, TextEditingController>> _manuelsControllers = {};
  Map<String, TextEditingController> _equipementsBonEtatControllers = {};
  Map<String, TextEditingController> _equipementsMauvaisEtatControllers = {};
  final ValueNotifier<int> _totalClassesOrganiseesNotifier = ValueNotifier(0);
  final ValueNotifier<int> _totalElevesNotifier = ValueNotifier(0);
  final Map<String, ValueNotifier<int>> _totalManuelsParClasseNotifier = {};
  final ValueNotifier<int> _totalManuelsGeneralNotifier = ValueNotifier(0);
  final ValueNotifier<int> _totalEquipementsBonEtatNotifier = ValueNotifier(0);
  final ValueNotifier<int> _totalEquipementsMauvaisEtatNotifier =
      ValueNotifier(0);
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
  final List<String> _statutsEtablissement = [
    'Mécanisé et payé',
    'Mécanisé et non payé'
  ];
  final List<String> _qualificationsEnseignant = ['D4', 'D6', 'P6', 'Autres'];
  List<String> _classesDuNiveau = [];
  List<String> _manuelsDuNiveau = [];
  final List<String> _equipements = [
    'Tableaux',
    'Tables',
    'Chaises',
    'Ordinateurs (à des fins pédagogiques)',
    'Kits scientifiques'
  ];

  // ... (Toutes vos méthodes initState, dispose, _loadUserData, _initializeForm, _calculateTotals, _updateTeacherList, _submitForm restent identiques) ...
  @override
  void initState() {
    super.initState();
    _loadUserDataAndInitializeForm();
    _totalEnseignantsController.addListener(_updateTeacherList);
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _fullNameController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _villeVillageController.dispose();
    _refJuridiqueController.dispose();
    _idDinacopeController.dispose();
    _latrinesTotalController.dispose();
    _latrinesFillesController.dispose();
    _totalEnseignantsController.removeListener(_updateTeacherList);
    _totalEnseignantsController.dispose();
    for (var controller in _teacherControllers) {
      controller.dispose();
    }
    for (var controller in _classesOrganiseesControllers.values) {
      controller.dispose();
    }
    for (var controller in _effectifsGarconsControllers.values) {
      controller.dispose();
    }
    for (var controller in _effectifsFillesControllers.values) {
      controller.dispose();
    }
    for (var map in _manuelsControllers.values) {
      for (var controller in map.values) {
        controller.dispose();
      }
    }
    for (var controller in _equipementsBonEtatControllers.values) {
      controller.dispose();
    }
    for (var controller in _equipementsMauvaisEtatControllers.values) {
      controller.dispose();
    }
    _totalClassesOrganiseesNotifier.dispose();
    _totalElevesNotifier.dispose();
    for (var notifier in _totalManuelsParClasseNotifier.values) {
      notifier.dispose();
    }
    _totalManuelsGeneralNotifier.dispose();
    _totalEquipementsBonEtatNotifier.dispose();
    _totalEquipementsMauvaisEtatNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadUserDataAndInitializeForm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _schoolNameController.text = data['schoolName'] ?? 'N/A';
          _fullNameController.text = data['fullName'] ?? 'N/A';
          _niveauEcole = data['niveauEcole']?.toString().toLowerCase();
          if (_niveauEcole != null) {
            _initializeFormForLevel(_niveauEcole!);
          }
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _initializeFormForLevel(String level) {
    _classesDuNiveau.clear();
    _manuelsDuNiveau.clear();
    _classesOrganiseesControllers.values.forEach((c) => c.dispose());
    _classesOrganiseesControllers.clear();
    _effectifsGarconsControllers.values.forEach((c) => c.dispose());
    _effectifsGarconsControllers.clear();
    _effectifsFillesControllers.values.forEach((c) => c.dispose());
    _effectifsFillesControllers.clear();
    _manuelsControllers.values
        .forEach((map) => map.values.forEach((c) => c.dispose()));
    _manuelsControllers.clear();
    _equipementsBonEtatControllers.values.forEach((c) => c.dispose());
    _equipementsBonEtatControllers.clear();
    _equipementsMauvaisEtatControllers.values.forEach((c) => c.dispose());
    _equipementsMauvaisEtatControllers.clear();
    if (level == 'maternel') {
      _classesDuNiveau = ['1ère', '2ème', '3ème'];
      _manuelsDuNiveau = ['FRANÇAIS', 'HYGIENE', 'EVEIL', 'ECM', 'Autres'];
    } else if (level == 'primaire') {
      _classesDuNiveau = ['1ère', '2ème', '3ème', '4ème', '5ème', '6ème'];
      _manuelsDuNiveau = [
        'Français',
        'Mathématiques',
        'Eveil',
        'ECM',
        'Autres'
      ];
    } else if (level == 'secondaire') {
      _classesDuNiveau = ['7ème', '8ème', '1ère', '2ème', '3ème', '4ème'];
      _manuelsDuNiveau = [
        'Français',
        'Mathématiques',
        'Eveil',
        'ECM',
        'Autres'
      ];
    }
    for (var classe in _classesDuNiveau) {
      _classesOrganiseesControllers[classe] = TextEditingController()
        ..addListener(_calculateTotals);
      _effectifsGarconsControllers[classe] = TextEditingController()
        ..addListener(_calculateTotals);
      _effectifsFillesControllers[classe] = TextEditingController()
        ..addListener(_calculateTotals);
      _totalManuelsParClasseNotifier[classe] = ValueNotifier(0);
      _manuelsControllers[classe] = {};
      for (var manuel in _manuelsDuNiveau) {
        _manuelsControllers[classe]![manuel] = TextEditingController()
          ..addListener(_calculateTotals);
      }
    }
    for (var equipement in _equipements) {
      _equipementsBonEtatControllers[equipement] = TextEditingController()
        ..addListener(_calculateTotals);
      _equipementsMauvaisEtatControllers[equipement] = TextEditingController()
        ..addListener(_calculateTotals);
    }
  }

  void _calculateTotals() {
    int totalClasses = _classesOrganiseesControllers.values
        .fold<int>(0, (sum, c) => sum + (int.tryParse(c.text) ?? 0));
    _totalClassesOrganiseesNotifier.value = totalClasses;
    int totalGarcons = _effectifsGarconsControllers.values
        .fold<int>(0, (sum, c) => sum + (int.tryParse(c.text) ?? 0));
    int totalFilles = _effectifsFillesControllers.values
        .fold<int>(0, (sum, c) => sum + (int.tryParse(c.text) ?? 0));
    _totalElevesNotifier.value = totalGarcons + totalFilles;
    int totalManuelsGeneral = 0;
    _classesDuNiveau.forEach((classe) {
      int totalParClasse = _manuelsControllers[classe]
              ?.values
              .fold<int>(0, (sum, c) => sum + (int.tryParse(c.text) ?? 0)) ??
          0;
      if (_totalManuelsParClasseNotifier[classe] != null) {
        _totalManuelsParClasseNotifier[classe]!.value = totalParClasse;
      }
      totalManuelsGeneral += totalParClasse;
    });
    _totalManuelsGeneralNotifier.value = totalManuelsGeneral;
    int totalBonEtat = _equipementsBonEtatControllers.values
        .fold<int>(0, (sum, c) => sum + (int.tryParse(c.text) ?? 0));
    _totalEquipementsBonEtatNotifier.value = totalBonEtat;
    int totalMauvaisEtat = _equipementsMauvaisEtatControllers.values
        .fold<int>(0, (sum, c) => sum + (int.tryParse(c.text) ?? 0));
    _totalEquipementsMauvaisEtatNotifier.value = totalMauvaisEtat;
  }

  void _updateTeacherList() {
    if (!mounted) return;
    final count = int.tryParse(_totalEnseignantsController.text) ?? 0;
    if (count < 0) return;
    while (_teacherControllers.length < count) {
      _teacherControllers.add(_TeacherControllers());
    }
    while (_teacherControllers.length > count) {
      _teacherControllers.removeLast().dispose();
    }
    setState(() {});
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez corriger les erreurs avant de soumettre.'),
          backgroundColor: Colors.red));
      return;
    }
    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isSubmitting = false);
      return;
    }
    final st2Data = ST2Model(
        submittedBy: user.uid,
        schoolName: _schoolNameController.text,
        chefEtablissementName: _fullNameController.text,
        niveauEcole: _niveauEcole,
        adresse: _adresseController.text,
        telephoneChef: _telephoneController.text,
        periode: _selectedPeriode,
        province: _selectedProvince,
        provinceEducationnelle: _selectedProvinceEdu,
        villeVillage: _villeVillageController.text,
        sousDivision: _selectedSousDivision,
        regimeGestion: _selectedRegimeGestion,
        refJuridique: _refJuridiqueController.text,
        idDinacope: _idDinacopeController.text,
        statutEtablissement: _selectedStatutEtablissement,
        hasProgrammesOfficiels: _hasProgrammesOfficiels,
        hasLatrines: _hasLatrines,
        latrinesTotal: int.tryParse(_latrinesTotalController.text),
        latrinesFilles: int.tryParse(_latrinesFillesController.text),
        hasPrevisionsBudgetaires: _hasPrevisionsBudgetaires,
        classesOrganisees: _classesOrganiseesControllers
            .map((key, value) => MapEntry(key, int.tryParse(value.text) ?? 0)),
        totalEnseignants: int.tryParse(_totalEnseignantsController.text) ?? 0,
        enseignants: _teacherControllers
            .map((c) => TeacherData(
                nom: c.nom.text,
                matricule: c.matricule.text,
                anneeEngagement: int.tryParse(c.anneeEngagement.text),
                sexe: c.sexe,
                situationSalariale: c.situationSalariale,
                qualification: c.qualification))
            .toList(),
        effectifsEleves:
            _effectifsGarconsControllers.map((key, value) => MapEntry(key, {
                  'garcons': int.tryParse(value.text) ?? 0,
                  'filles': int.tryParse(
                          _effectifsFillesControllers[key]?.text ?? '0') ??
                      0
                })),
        manuelsDisponibles: _manuelsControllers.map(
            (classe, manuelMap) =>
                MapEntry(
                    classe,
                    manuelMap.map((manuel, controller) =>
                        MapEntry(manuel, int.tryParse(controller.text) ?? 0)))),
        equipements: _equipements
            .map((type) => EquipementData(
                type: type,
                enBonEtat:
                    int.tryParse(_equipementsBonEtatControllers[type]!.text) ??
                        0,
                enMauvaisEtat:
                    int.tryParse(_equipementsMauvaisEtatControllers[type]!.text) ??
                        0))
            .toList());
    final success =
        await _st2Controller.submitST2Form(formData: st2Data, context: context);
    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  // --- NOUVELLE STRUCTURE DU BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formulaire de Collecte ST2")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _niveauEcole == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Impossible de charger les données pour cet utilisateur.\nVeuillez vérifier la connexion ou contacter l'administrateur.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Stepper(
                    type: StepperType.vertical,
                    currentStep: _currentStep,
                    onStepTapped: (step) => setState(() => _currentStep = step),
                    onStepContinue: () {
                      if (_currentStep < _buildSteps().length - 1) {
                        setState(() => _currentStep += 1);
                      } else {
                        _submitForm();
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep -= 1);
                      }
                    },
                    steps: _buildSteps(),
                    // Personnalisation des boutons du Stepper
                    controlsBuilder: (context, details) {
                      final isLastStep =
                          _currentStep == _buildSteps().length - 1;
                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          children: [
                            if (_isSubmitting && isLastStep)
                              const CircularProgressIndicator()
                            else
                              ElevatedButton(
                                onPressed: details.onStepContinue,
                                child: Text(
                                    isLastStep ? 'SOUMETTRE' : 'CONTINUER'),
                              ),
                            const SizedBox(width: 12),
                            if (_currentStep > 0 && !_isSubmitting)
                              TextButton(
                                onPressed: details.onStepCancel,
                                child: const Text('PRÉCÉDENT'),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  // Méthode pour construire la liste des étapes
  List<Step> _buildSteps() {
    return [
      _buildStep(
          title: 'Identification',
          content: _buildIdentificationSection(),
          stepIndex: 0),
      _buildStep(
          title: 'Localisation',
          content: _buildLocalisationSection(),
          stepIndex: 1),
      _buildStep(
          title: 'Informations Générales',
          content: _buildInfosGeneralesSection(),
          stepIndex: 2),
      _buildStep(
          title: 'Données Pédagogiques',
          content: _buildPedagogieSection(),
          stepIndex: 3),
      _buildStep(
          title: 'Patrimoine Scolaire',
          content: _buildPatrimoineSection(),
          stepIndex: 4),
    ];
  }

  // Helper pour créer une Step
  Step _buildStep(
      {required String title,
      required Widget content,
      required int stepIndex}) {
    return Step(
      title: Text(title),
      content: FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: content,
      ),
      isActive: _currentStep >= stepIndex,
      state: _currentStep > stepIndex ? StepState.complete : StepState.indexed,
    );
  }

  // --- WIDGETS DE CONSTRUCTION POUR CHAQUE ÉTAPE ---

  Widget _buildTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      );

  Widget _buildYesNoQuestion({
    required String question,
    required bool? groupValue,
    required void Function(bool?) onChanged,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: Theme.of(context).textTheme.bodyMedium),
          Row(
            children: [
              Radio<bool>(
                  value: true, groupValue: groupValue, onChanged: onChanged),
              const Text('Oui'),
              const SizedBox(width: 20),
              Radio<bool>(
                  value: false, groupValue: groupValue, onChanged: onChanged),
              const Text('Non'),
            ],
          ),
        ],
      );

  Widget _buildIdentificationSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
              controller: _schoolNameController,
              enabled: false,
              decoration:
                  const InputDecoration(labelText: "Nom de l'établissement")),
          const SizedBox(height: 16),
          TextFormField(
              controller: _fullNameController,
              enabled: false,
              decoration: const InputDecoration(
                  labelText: "Nom du chef de l'établissement")),
          const SizedBox(height: 16),
          Text("Niveau école : ${_niveauEcole?.toUpperCase() ?? 'N/A'}",
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          TextFormField(
              controller: _adresseController,
              decoration: const InputDecoration(
                  labelText: "Adresse de l'établissement"),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Champ requis.' : null),
          const SizedBox(height: 16),
          TextFormField(
              controller: _telephoneController,
              decoration:
                  const InputDecoration(labelText: "Téléphone du chef Ets"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              maxLength: 10,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Champ requis.' : null),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedPeriode,
            decoration: const InputDecoration(labelText: 'Période'),
            items: ['SEMESTRE 1', 'SEMESTRE 2']
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (val) => setState(() => _selectedPeriode = val),
            validator: (v) => v == null ? 'Sélection requise.' : null,
          ),
        ],
      );

  Widget _buildLocalisationSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
              value: _selectedProvince,
              decoration: const InputDecoration(labelText: 'Province'),
              items: [
                const DropdownMenuItem(
                    value: 'HAUT-LOMAMI', child: Text('HAUT-LOMAMI'))
              ],
              onChanged: (val) {}),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
              value: _selectedProvinceEdu,
              decoration:
                  const InputDecoration(labelText: 'Province éducationnelle'),
              items: [
                const DropdownMenuItem(
                    value: 'HAUT-LOMAMI 1', child: Text('HAUT-LOMAMI 1'))
              ],
              onChanged: (val) {}),
          const SizedBox(height: 16),
          TextFormField(
              controller: _villeVillageController,
              decoration: const InputDecoration(labelText: 'Ville/Village'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Champ requis.' : null),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
              value: _selectedSousDivision,
              decoration: const InputDecoration(labelText: 'Sous-division'),
              items: _sousDivisions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedSousDivision = val),
              validator: (v) => v == null ? 'Sélection requise.' : null),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
              value: _selectedRegimeGestion,
              decoration: const InputDecoration(labelText: 'Régime de gestion'),
              items: _regimesGestion
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedRegimeGestion = val),
              validator: (v) => v == null ? 'Sélection requise.' : null),
          const SizedBox(height: 16),
          TextFormField(
              controller: _refJuridiqueController,
              decoration: const InputDecoration(
                  labelText: 'Réf. juridique (arrêté d’agrément)'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Champ requis.' : null),
          const SizedBox(height: 16),
          TextFormField(
              controller: _idDinacopeController,
              decoration: const InputDecoration(labelText: 'ID DINACOPE'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              maxLength: 15,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Champ requis.' : null),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
              value: _selectedStatutEtablissement,
              decoration:
                  const InputDecoration(labelText: 'L’établissement est'),
              items: _statutsEtablissement
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) =>
                  setState(() => _selectedStatutEtablissement = val),
              validator: (v) => v == null ? 'Sélection requise.' : null),
        ],
      );

  Widget _buildInfosGeneralesSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildYesNoQuestion(
              question:
                  'L’établissement dispose-t-il des programmes officiels de cours ?',
              groupValue: _hasProgrammesOfficiels,
              onChanged: (val) =>
                  setState(() => _hasProgrammesOfficiels = val)),
          const SizedBox(height: 16),
          _buildYesNoQuestion(
              question: 'L’existence des latrines (W.C) ?',
              groupValue: _hasLatrines,
              onChanged: (val) => setState(() => _hasLatrines = val)),
          if (_hasLatrines == true)
            FadeIn(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _latrinesTotalController,
                    decoration: const InputDecoration(
                        labelText: 'Préciser le nombre de compartiments'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _latrinesFillesController,
                    decoration: const InputDecoration(
                        labelText: 'Dont pour les filles'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          _buildYesNoQuestion(
              question:
                  'Votre Etablissement dispose-t-il des prévisions budgétaires et des documents comptables ?',
              groupValue: _hasPrevisionsBudgetaires,
              onChanged: (val) =>
                  setState(() => _hasPrevisionsBudgetaires = val)),
        ],
      );

  Widget _buildPedagogieSection() => Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle("Nombre de Classes Organisées"),
                  ..._classesDuNiveau.map((c) => TextFormField(
                        controller: _classesOrganiseesControllers[c]!,
                        decoration: InputDecoration(labelText: 'Classe de $c'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      )),
                  const Divider(height: 24),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ValueListenableBuilder<int>(
                            valueListenable: _totalClassesOrganiseesNotifier,
                            builder: (context, total, child) => Text("$total",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)))
                      ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle("Effectifs des Élèves Inscrits"),
                  ..._classesDuNiveau.map((classe) => Column(children: [
                        Text('Classe de $classe',
                            style: Theme.of(context).textTheme.titleSmall),
                        Row(children: [
                          Expanded(
                              child: TextFormField(
                            controller: _effectifsGarconsControllers[classe]!,
                            decoration: const InputDecoration(
                                labelText: 'Total Garçons'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          )),
                          const SizedBox(width: 16),
                          Expanded(
                              child: TextFormField(
                            controller: _effectifsFillesControllers[classe]!,
                            decoration: const InputDecoration(
                                labelText: 'Total Filles'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ))
                        ])
                      ])),
                  const Divider(height: 24),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Effectif",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ValueListenableBuilder<int>(
                            valueListenable: _totalElevesNotifier,
                            builder: (context, total, child) => Text("$total",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)))
                      ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle("Personnel Enseignant"),
                  TextFormField(
                    controller: _totalEnseignantsController,
                    decoration: const InputDecoration(
                        labelText: 'Nombre d’enseignants au total'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _teacherControllers.length,
                    itemBuilder: (context, index) {
                      final c = _teacherControllers[index];
                      return ExpansionTile(
                        title: Text('Enseignant ${index + 1}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                TextFormField(
                                    controller: c.nom,
                                    decoration: const InputDecoration(
                                        labelText: 'Nom de l’enseignant')),
                                DropdownButtonFormField<String>(
                                    value: c.sexe,
                                    decoration: const InputDecoration(
                                        labelText: 'Sexe'),
                                    items: ['Masculin', 'Féminin']
                                        .map((s) => DropdownMenuItem(
                                            value: s, child: Text(s)))
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => c.sexe = val)),
                                TextFormField(
                                  controller: c.matricule,
                                  decoration: const InputDecoration(
                                      labelText: 'Matricule DINACOPE'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                                DropdownButtonFormField<String>(
                                    value: c.situationSalariale,
                                    decoration: const InputDecoration(
                                        labelText: 'Situation salariale'),
                                    items: ['Payé', 'Non payé']
                                        .map((s) => DropdownMenuItem(
                                            value: s, child: Text(s)))
                                        .toList(),
                                    onChanged: (val) => setState(
                                        () => c.situationSalariale = val)),
                                TextFormField(
                                    controller: c.anneeEngagement,
                                    decoration: const InputDecoration(
                                        labelText: 'Année d’engagement'),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    maxLength: 4),
                                DropdownButtonFormField<String>(
                                    value: c.qualification,
                                    decoration: const InputDecoration(
                                        labelText: 'Qualification'),
                                    items: _qualificationsEnseignant
                                        .map((q) => DropdownMenuItem(
                                            value: q, child: Text(q)))
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => c.qualification = val)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildPatrimoineSection() => Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle("Manuels Disponibles Utilisables"),
                  // Remplacement de DataTable par une mise en page plus flexible
                  ..._manuelsDuNiveau.map((manuel) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(manuel,
                                style: Theme.of(context).textTheme.titleSmall)),
                        ..._classesDuNiveau.map((classe) => TextFormField(
                              controller: _manuelsControllers[classe]![manuel]!,
                              decoration: InputDecoration(
                                  labelText: 'Classe de $classe'),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            )),
                      ],
                    );
                  }),
                  const Divider(height: 24),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Général des Manuels",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ValueListenableBuilder<int>(
                            valueListenable: _totalManuelsGeneralNotifier,
                            builder: (context, total, child) => Text("$total",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)))
                      ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle("Équipements Existants"),
                  ..._equipements.map((equip) => Row(children: [
                        Expanded(child: Text(equip)),
                        Expanded(
                            child: TextFormField(
                          controller: _equipementsBonEtatControllers[equip]!,
                          decoration:
                              const InputDecoration(labelText: 'Bon État'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        )),
                        const SizedBox(width: 8),
                        Expanded(
                            child: TextFormField(
                          controller:
                              _equipementsMauvaisEtatControllers[equip]!,
                          decoration:
                              const InputDecoration(labelText: 'Mauvais État'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ))
                      ])),
                  const Divider(height: 24),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Bon État",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ValueListenableBuilder<int>(
                            valueListenable: _totalEquipementsBonEtatNotifier,
                            builder: (context, total, child) => Text("$total",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)))
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Mauvais État",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ValueListenableBuilder<int>(
                            valueListenable:
                                _totalEquipementsMauvaisEtatNotifier,
                            builder: (context, total, child) => Text("$total",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)))
                      ]),
                ],
              ),
            ),
          ),
        ],
      );
}
