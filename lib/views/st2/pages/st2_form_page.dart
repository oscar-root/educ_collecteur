// lib/st2/pages/st2_form_page.dart

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- IMPORTS ---
import 'package:educ_collecteur/controllers/st2_controller.dart';
import 'package:educ_collecteur/models/st2_model.dart';

// Helper class pour les contrôleurs de la section Enseignants
class _TeacherControllers {
  final TextEditingController nom = TextEditingController();
  final TextEditingController matricule = TextEditingController();
  final TextEditingController anneeEngagement = TextEditingController();
  String? sexe;
  String? situationSalariale;
  String? qualification;

  _TeacherControllers();

  void dispose() {
    nom.dispose();
    matricule.dispose();
    anneeEngagement.dispose();
  }
}

class ST2FormPage extends StatefulWidget {
  // Ce champ recevra le formulaire à modifier. Il est optionnel ('?').
  final ST2Model? formToEdit;

  // Le constructeur accepte maintenant le formulaire optionnel.
  const ST2FormPage({super.key, this.formToEdit});

  @override
  State<ST2FormPage> createState() => _ST2FormPageState();
}

class _ST2FormPageState extends State<ST2FormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ST2Controller _st2Controller = ST2Controller();

  late bool _isEditing;

  // Variables d'état
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _niveauEcole;

  // DÉCLARATION DE TOUS LES CONTRÔLEURS
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

  // NOTIFIERS POUR LES CALCULS EN TEMPS RÉEL
  final ValueNotifier<int> _totalClassesOrganiseesNotifier = ValueNotifier(0);
  final ValueNotifier<int> _totalElevesNotifier = ValueNotifier(0);
  final Map<String, ValueNotifier<int>> _totalManuelsParClasseNotifier = {};
  final ValueNotifier<int> _totalManuelsGeneralNotifier = ValueNotifier(0);
  final ValueNotifier<int> _totalEquipementsBonEtatNotifier = ValueNotifier(0);
  final ValueNotifier<int> _totalEquipementsMauvaisEtatNotifier = ValueNotifier(
    0,
  );

  // Listes pour les Dropdowns
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
  final List<String> _statutsEtablissement = [
    'Mécanisé et payé',
    'Mécanisé et non payé',
  ];
  final List<String> _qualificationsEnseignant = ['D4', 'D6', 'P6', 'Autres'];

  List<String> _classesDuNiveau = [];
  List<String> _manuelsDuNiveau = [];
  final List<String> _equipements = [
    'Tableaux',
    'Tables',
    'Chaises',
    'Ordinateurs (à des fins pédagogiques)',
    'Kits scientifiques',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.formToEdit != null;

    if (_isEditing) {
      _prefillForm();
      _isLoading = false;
    } else {
      _loadUserDataAndInitializeForm();
    }
    _totalEnseignantsController.addListener(_updateTeacherList);
  }

  void _prefillForm() {
    final form = widget.formToEdit!;

    _schoolNameController.text = form.schoolName;
    _fullNameController.text = form.chefEtablissementName;
    _adresseController.text = form.adresse;
    _telephoneController.text = form.telephoneChef;
    _villeVillageController.text = form.villeVillage;
    _refJuridiqueController.text = form.refJuridique;
    _idDinacopeController.text = form.idDinacope;
    _latrinesTotalController.text = form.latrinesTotal?.toString() ?? '';
    _latrinesFillesController.text = form.latrinesFilles?.toString() ?? '';

    _niveauEcole = form.niveauEcole;
    if (_niveauEcole != null) {
      _initializeFormForLevel(_niveauEcole!);
    }
    _selectedPeriode = form.periode;
    _selectedSousDivision = form.sousDivision;
    _selectedRegimeGestion = form.regimeGestion;
    _selectedStatutEtablissement = form.statutEtablissement;
    _hasProgrammesOfficiels = form.hasProgrammesOfficiels;
    _hasLatrines = form.hasLatrines;
    _hasPrevisionsBudgetaires = form.hasPrevisionsBudgetaires;

    form.classesOrganisees.forEach((classe, nombre) {
      if (_classesOrganiseesControllers.containsKey(classe)) {
        _classesOrganiseesControllers[classe]!.text = nombre.toString();
      }
    });

    form.effectifsEleves.forEach((classe, effectifs) {
      if (_effectifsGarconsControllers.containsKey(classe)) {
        _effectifsGarconsControllers[classe]!.text =
            effectifs.garcons.toString();
        _effectifsFillesControllers[classe]!.text = effectifs.filles.toString();
      }
    });

    form.manuelsDisponibles.forEach((classe, manuels) {
      if (_manuelsControllers.containsKey(classe)) {
        manuels.forEach((manuel, nombre) {
          if (_manuelsControllers[classe]!.containsKey(manuel)) {
            _manuelsControllers[classe]![manuel]!.text = nombre.toString();
          }
        });
      }
    });

    form.equipements.forEach((equipement) {
      if (_equipementsBonEtatControllers.containsKey(equipement.type)) {
        _equipementsBonEtatControllers[equipement.type]!.text =
            equipement.enBonEtat.toString();
        _equipementsMauvaisEtatControllers[equipement.type]!.text =
            equipement.enMauvaisEtat.toString();
      }
    });

    _totalEnseignantsController.text = form.totalEnseignants.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < form.enseignants.length; i++) {
        if (i < _teacherControllers.length) {
          final teacherData = form.enseignants[i];
          final teacherController = _teacherControllers[i];
          teacherController.nom.text = teacherData.nom;
          teacherController.matricule.text = teacherData.matricule;
          teacherController.anneeEngagement.text =
              teacherData.anneeEngagement?.toString() ?? '';
          setState(() {
            teacherController.sexe = teacherData.sexe;
            teacherController.situationSalariale =
                teacherData.situationSalariale;
            teacherController.qualification = teacherData.qualification;
          });
        }
      }
      _calculateTotals(); // Mettre à jour les totaux après le pré-remplissage
    });
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
    _classesOrganiseesControllers.values.forEach((c) => c.dispose());
    _effectifsGarconsControllers.values.forEach((c) => c.dispose());
    _effectifsFillesControllers.values.forEach((c) => c.dispose());
    _manuelsControllers.values.forEach(
      (map) => map.values.forEach((c) => c.dispose()),
    );
    _equipementsBonEtatControllers.values.forEach((c) => c.dispose());
    _equipementsMauvaisEtatControllers.values.forEach((c) => c.dispose());

    _totalClassesOrganiseesNotifier.dispose();
    _totalElevesNotifier.dispose();
    _totalManuelsParClasseNotifier.values.forEach((n) => n.dispose());
    _totalManuelsGeneralNotifier.dispose();
    _totalEquipementsBonEtatNotifier.dispose();
    _totalEquipementsMauvaisEtatNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadUserDataAndInitializeForm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
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
        } else if (mounted) {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des données: $e")),
        );
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
    _manuelsControllers.values.forEach(
      (map) => map.values.forEach((c) => c.dispose()),
    );
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
        'Autres',
      ];
    } else if (level == 'secondaire') {
      _classesDuNiveau = ['7ème', '8ème', '1ère', '2ème', '3ème', '4ème'];
      _manuelsDuNiveau = [
        'Français',
        'Mathématiques',
        'Physique',
        'Chimie',
        'Biologie',
        'Autres',
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
    if (mounted) setState(() {});
  }

  void _calculateTotals() {
    int totalClasses = _classesOrganiseesControllers.values.fold<int>(
      0,
      (sum, c) => sum + (int.tryParse(c.text) ?? 0),
    );
    _totalClassesOrganiseesNotifier.value = totalClasses;

    int totalGarcons = _effectifsGarconsControllers.values.fold<int>(
      0,
      (sum, c) => sum + (int.tryParse(c.text) ?? 0),
    );
    int totalFilles = _effectifsFillesControllers.values.fold<int>(
      0,
      (sum, c) => sum + (int.tryParse(c.text) ?? 0),
    );
    _totalElevesNotifier.value = totalGarcons + totalFilles;

    int totalManuelsGeneral = 0;
    for (var classe in _classesDuNiveau) {
      int totalParClasse = _manuelsControllers[classe]?.values.fold<int>(
                0,
                (sum, c) => sum + (int.tryParse(c.text) ?? 0),
              ) ??
          0;
      if (_totalManuelsParClasseNotifier[classe] != null) {
        _totalManuelsParClasseNotifier[classe]!.value = totalParClasse;
      }
      totalManuelsGeneral += totalParClasse;
    }
    _totalManuelsGeneralNotifier.value = totalManuelsGeneral;

    int totalBonEtat = _equipementsBonEtatControllers.values.fold<int>(
      0,
      (sum, c) => sum + (int.tryParse(c.text) ?? 0),
    );
    _totalEquipementsBonEtatNotifier.value = totalBonEtat;

    int totalMauvaisEtat = _equipementsMauvaisEtatControllers.values.fold<int>(
      0,
      (sum, c) => sum + (int.tryParse(c.text) ?? 0),
    );
    _totalEquipementsMauvaisEtatNotifier.value = totalMauvaisEtat;
  }

  void _updateTeacherList() {
    if (!mounted) return;
    final count = int.tryParse(_totalEnseignantsController.text) ?? 0;
    if (count < 0) return;
    final previousLength = _teacherControllers.length;

    while (_teacherControllers.length < count) {
      _teacherControllers.add(_TeacherControllers());
    }
    while (_teacherControllers.length > count) {
      _teacherControllers.removeLast().dispose();
    }

    if (previousLength != _teacherControllers.length) {
      setState(() {});
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs avant de soumettre.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isSubmitting = false);
      return;
    }

    final st2Data = ST2Model(
      id: _isEditing ? widget.formToEdit!.id : null,
      submittedBy: _isEditing ? widget.formToEdit!.submittedBy : user.uid,
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
      classesOrganisees: _classesOrganiseesControllers.map(
        (key, value) => MapEntry(key, int.tryParse(value.text) ?? 0),
      ),
      totalEnseignants: int.tryParse(_totalEnseignantsController.text) ?? 0,
      enseignants: _teacherControllers
          .map(
            (c) => TeacherData(
              nom: c.nom.text,
              matricule: c.matricule.text,
              anneeEngagement: int.tryParse(c.anneeEngagement.text),
              sexe: c.sexe,
              situationSalariale: c.situationSalariale,
              qualification: c.qualification,
            ),
          )
          .toList(),
      effectifsEleves: _effectifsGarconsControllers.map(
        (key, value) => MapEntry(
          key,
          EffectifsData(
            garcons: int.tryParse(value.text) ?? 0,
            filles:
                int.tryParse(_effectifsFillesControllers[key]?.text ?? '0') ??
                    0,
          ),
        ),
      ),
      manuelsDisponibles: _manuelsControllers.map(
        (classe, manuelMap) => MapEntry(
          classe,
          manuelMap.map(
            (manuel, controller) =>
                MapEntry(manuel, int.tryParse(controller.text) ?? 0),
          ),
        ),
      ),
      equipements: _equipements
          .map(
            (type) => EquipementData(
              type: type,
              enBonEtat: int.tryParse(
                    _equipementsBonEtatControllers[type]!.text,
                  ) ??
                  0,
              enMauvaisEtat: int.tryParse(
                    _equipementsMauvaisEtatControllers[type]!.text,
                  ) ??
                  0,
            ),
          )
          .toList(),
    );

    final bool success;
    if (_isEditing) {
      success = await _st2Controller.updateFullForm(
        docId: widget.formToEdit!.id!,
        formData: st2Data,
        context: context,
      );
    } else {
      success = await _st2Controller.submitST2Form(
        formData: st2Data,
        context: context,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
    bool enabled = true,
    int? maxLength,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(fontSize: 13),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters:
            isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          counterText: "",
          contentPadding: const EdgeInsets.only(top: 12, bottom: 8),
        ),
        validator: validator ??
            (value) => (value == null || value.isEmpty)
                ? 'Ce champ est requis.'
                : null,
      );

  Widget _buildPhoneTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 13, letterSpacing: 1.5),
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 10,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          letterSpacing: 0,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(top: 12, left: 12, right: 8),
          child: Text(
            '+243',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
        hintText: "081 234 5678",
        hintStyle: TextStyle(color: Colors.grey.shade400, letterSpacing: 1.5),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        counterText: "",
        contentPadding: const EdgeInsets.only(top: 12, bottom: 8),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ce champ est requis.';
        final phoneRegExp = RegExp(r'^(0(81|82|83|84|85|89|97|99))\d{7}$');
        if (!phoneRegExp.hasMatch(value))
          return 'Numéro RDC invalide (10 chiffres).';
        return null;
      },
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) =>
      DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.only(top: 12, bottom: 4),
        ),
        validator: (value) =>
            value == null ? 'Veuillez sélectionner une option.' : null,
      );

  Widget _buildYesNoQuestion({
    required String question,
    required bool? groupValue,
    required void Function(bool?) onChanged,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 13)),
          Row(
            children: [
              Text('Oui', style: const TextStyle(fontSize: 13)),
              Radio<bool>(
                value: true,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 20),
              Text('Non', style: const TextStyle(fontSize: 13)),
              Radio<bool>(
                value: false,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ],
      );

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) =>
      FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildSectionTitle(title), ...children],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? "Modifier le Formulaire" : "Nouveau Formulaire ST2",
        ),
        backgroundColor: Colors.indigo,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _niveauEcole == null && !_isEditing
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    child: Column(
                      children: [
                        _buildIdentificationSection(),
                        _buildLocalisationSection(),
                        _buildInfosGeneralesSection(),
                        _buildConditionalForm(),
                        const SizedBox(height: 32),
                        if (_isSubmitting)
                          const Center(child: CircularProgressIndicator())
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                _isEditing
                                    ? Icons.save_as_outlined
                                    : Icons.cloud_upload_outlined,
                              ),
                              label: Text(
                                _isEditing
                                    ? "ENREGISTRER LES MODIFICATIONS"
                                    : "SOUMETTRE LE FORMULAIRE",
                              ),
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isEditing
                                    ? Colors.amber.shade800
                                    : Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  // --- Widgets de construction pour chaque section ---

  Widget _buildIdentificationSection() => _buildSectionCard(
        title: "Identification",
        children: [
          _buildTextField(
            controller: _schoolNameController,
            label: "Nom de l'établissement",
            enabled: false,
          ),
          _buildTextField(
            controller: _fullNameController,
            label: "Nom du chef de l'établissement",
            enabled: false,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              "Niveau école : ${_niveauEcole?.toUpperCase() ?? 'N/A'}",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          _buildTextField(
            controller: _adresseController,
            label: "Adresse de l'établissement",
          ),
          _buildPhoneTextField(
            controller: _telephoneController,
            label: "Téléphone du chef Ets",
          ),
          _buildDropdown<String>(
            label: 'Période',
            value: _selectedPeriode,
            items: ['SEMESTRE 1', 'SEMESTRE 2']
                .map(
                  (p) => DropdownMenuItem(
                    value: p,
                    child: Text(p, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => _selectedPeriode = val),
          ),
        ],
      );

  Widget _buildLocalisationSection() => _buildSectionCard(
        title: "Localisation Administrative",
        children: [
          _buildDropdown<String>(
            label: 'Province',
            value: _selectedProvince,
            items: [
              const DropdownMenuItem(
                value: 'HAUT-LOMAMI',
                child: Text('HAUT-LOMAMI', style: TextStyle(fontSize: 13)),
              ),
            ],
            onChanged: (val) {},
          ),
          _buildDropdown<String>(
            label: 'Province éducationnelle',
            value: _selectedProvinceEdu,
            items: [
              const DropdownMenuItem(
                value: 'HAUT-LOMAMI 1',
                child: Text('HAUT-LOMAMI 1', style: TextStyle(fontSize: 13)),
              ),
            ],
            onChanged: (val) {},
          ),
          _buildTextField(
            controller: _villeVillageController,
            label: 'Ville/Village',
          ),
          _buildDropdown<String>(
            label: 'Sous-division',
            value: _selectedSousDivision,
            items: _sousDivisions
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => _selectedSousDivision = val),
          ),
          _buildDropdown<String>(
            label: 'Régime de gestion',
            value: _selectedRegimeGestion,
            items: _regimesGestion
                .map(
                  (r) => DropdownMenuItem(
                    value: r,
                    child: Text(r, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => _selectedRegimeGestion = val),
          ),
          _buildTextField(
            controller: _refJuridiqueController,
            label: 'Réf. juridique (arrêté d’agrément)',
          ),
          _buildTextField(
            controller: _idDinacopeController,
            label: 'ID DINACOPE',
            isNumber: true,
            maxLength: 15,
          ),
          _buildDropdown<String>(
            label: 'L’établissement est',
            value: _selectedStatutEtablissement,
            items: _statutsEtablissement
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (val) =>
                setState(() => _selectedStatutEtablissement = val),
          ),
        ],
      );

  Widget _buildInfosGeneralesSection() => _buildSectionCard(
        title: "Informations Générales",
        children: [
          _buildYesNoQuestion(
            question:
                'L’établissement dispose-t-il des programmes officiels de cours ?',
            groupValue: _hasProgrammesOfficiels,
            onChanged: (val) => setState(() => _hasProgrammesOfficiels = val),
          ),
          const SizedBox(height: 16),
          _buildYesNoQuestion(
            question: 'L’existence des latrines (W.C) ?',
            groupValue: _hasLatrines,
            onChanged: (val) => setState(() => _hasLatrines = val),
          ),
          if (_hasLatrines == true)
            FadeIn(
              child: Column(
                children: [
                  _buildTextField(
                    controller: _latrinesTotalController,
                    label: 'Préciser le nombre de compartiments',
                    isNumber: true,
                    validator: (v) => null,
                  ),
                  _buildTextField(
                    controller: _latrinesFillesController,
                    label: 'Dont pour les filles',
                    isNumber: true,
                    validator: (v) => null,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          _buildYesNoQuestion(
            question:
                'Votre Etablissement dispose-t-il des prévisions budgétaires et des documents comptables ?',
            groupValue: _hasPrevisionsBudgetaires,
            onChanged: (val) => setState(() => _hasPrevisionsBudgetaires = val),
          ),
        ],
      );

  Widget _buildConditionalForm() => Column(
        children: [
          if (_niveauEcole != null) ...[
            _buildSectionCard(
              title: "Données sur les Différents Paramètres Scolaires",
              children: [
                _buildClassesOrganiseesSection(),
                const SizedBox(height: 24),
                _buildPersonnelEnseignantSection(),
              ],
            ),
            _buildSectionCard(
              title: "Effectifs des Élèves Inscrits par Sexe et Année d’Études",
              children: [_buildEffectifsElevesSection()],
            ),
            _buildSectionCard(
              title: "Patrimoines Scolaires",
              children: [
                _buildPatrimoinesManuelsSection(),
                const SizedBox(height: 24),
                _buildPatrimoinesEquipementsSection(),
              ],
            ),
          ],
        ],
      );

  Widget _buildClassesOrganiseesSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Nombre de Classes Organisées"),
          ..._classesDuNiveau.map(
            (c) => _buildTextField(
              controller: _classesOrganiseesControllers[c]!,
              label: 'Classe de $c',
              isNumber: true,
              validator: (v) => null,
            ),
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              ValueListenableBuilder<int>(
                valueListenable: _totalClassesOrganiseesNotifier,
                builder: (context, total, child) => Text(
                  "$total",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildPersonnelEnseignantSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Informations Relatives au Personnel Enseignant"),
          _buildTextField(
            controller: _totalEnseignantsController,
            label: 'Nombre d’enseignants au total',
            isNumber: true,
            validator: (v) => null,
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _teacherControllers.length,
            itemBuilder: (context, index) {
              final c = _teacherControllers[index];
              return Card(
                elevation: 1.5,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enseignant ${index + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const Divider(),
                      _buildTextField(
                        controller: c.nom,
                        label: 'Nom de l’enseignant',
                      ),
                      _buildDropdown<String>(
                        label: 'Sexe',
                        value: c.sexe,
                        items: ['Masculin', 'Féminin']
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => c.sexe = val),
                      ),
                      _buildTextField(
                        controller: c.matricule,
                        label: 'Matricule DINACOPE',
                        isNumber: true,
                      ),
                      _buildDropdown<String>(
                        label: 'Situation salariale',
                        value: c.situationSalariale,
                        items: ['Payé', 'Non payé']
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => c.situationSalariale = val),
                      ),
                      _buildTextField(
                        controller: c.anneeEngagement,
                        label: 'Année d’engagement',
                        isNumber: true,
                        maxLength: 4,
                      ),
                      _buildDropdown<String>(
                        label: 'Qualification',
                        value: c.qualification,
                        items: _qualificationsEnseignant
                            .map(
                              (q) => DropdownMenuItem(
                                value: q,
                                child: Text(
                                  q,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => c.qualification = val),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );

  Widget _buildEffectifsElevesSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._classesDuNiveau.map(
            (classe) => Column(
              children: [
                Text(
                  'Classe de $classe',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _effectifsGarconsControllers[classe]!,
                        label: 'Total Garçons',
                        isNumber: true,
                        validator: (v) => null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _effectifsFillesControllers[classe]!,
                        label: 'Total Filles',
                        isNumber: true,
                        validator: (v) => null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Effectif",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              ValueListenableBuilder<int>(
                valueListenable: _totalElevesNotifier,
                builder: (context, total, child) => Text(
                  "$total",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildPatrimoinesManuelsSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Nombre de Manuels Disponibles Utilisables"),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              columns: [
                const DataColumn(
                  label: Text(
                    'Manuels',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._classesDuNiveau.map(
                  (c) => DataColumn(
                    label: Text(
                      c,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    numeric: true,
                  ),
                ),
              ],
              rows: [
                ..._manuelsDuNiveau.map(
                  (manuel) => DataRow(
                    cells: [
                      DataCell(
                          Text(manuel, style: const TextStyle(fontSize: 13))),
                      ..._classesDuNiveau.map(
                        (classe) => DataCell(
                          SizedBox(
                            width: 60,
                            child: _buildTextField(
                              controller: _manuelsControllers[classe]![manuel]!,
                              label: '',
                              isNumber: true,
                              validator: (v) => null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DataRow(
                  cells: [
                    const DataCell(
                      Text(
                        'Total',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ..._classesDuNiveau.map(
                      (classe) => DataCell(
                        _totalManuelsParClasseNotifier[classe] == null
                            ? const Text('N/A')
                            : ValueListenableBuilder<int>(
                                valueListenable:
                                    _totalManuelsParClasseNotifier[classe]!,
                                builder: (context, total, child) => Text(
                                  '$total',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Général des Manuels",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              ValueListenableBuilder<int>(
                valueListenable: _totalManuelsGeneralNotifier,
                builder: (context, total, child) => Text(
                  "$total",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildPatrimoinesEquipementsSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Nombre d’Equipements Existants"),
          DataTable(
            columnSpacing: 16,
            headingRowHeight: 40,
            columns: const [
              DataColumn(
                label: Text(
                  'Type',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Bon État',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Mauvais État',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                numeric: true,
              ),
            ],
            rows: [
              ..._equipements.map(
                (equip) => DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 100,
                        child:
                            Text(equip, style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                    DataCell(
                      _buildTextField(
                        controller: _equipementsBonEtatControllers[equip]!,
                        label: '',
                        isNumber: true,
                        validator: (v) => null,
                      ),
                    ),
                    DataCell(
                      _buildTextField(
                        controller: _equipementsMauvaisEtatControllers[equip]!,
                        label: '',
                        isNumber: true,
                        validator: (v) => null,
                      ),
                    ),
                  ],
                ),
              ),
              DataRow(
                cells: [
                  const DataCell(
                    Text(
                      'Total',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    ValueListenableBuilder<int>(
                      valueListenable: _totalEquipementsBonEtatNotifier,
                      builder: (context, total, child) => Text(
                        '$total',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    ValueListenableBuilder<int>(
                      valueListenable: _totalEquipementsMauvaisEtatNotifier,
                      builder: (context, total, child) => Text(
                        '$total',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
}
