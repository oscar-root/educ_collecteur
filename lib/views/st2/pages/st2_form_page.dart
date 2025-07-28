import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Modèle pour structurer les données des enseignants, facilitant la gestion
class TeacherData {
  String nom;
  String? sexe;
  String matricule;
  String? situationSalariale;
  int? anneeEngagement;
  String? qualification;

  TeacherData({
    this.nom = '',
    this.sexe,
    this.matricule = '',
    this.situationSalariale,
    this.anneeEngagement,
    this.qualification,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'sexe': sexe,
      'matricule': matricule,
      'situationSalariale': situationSalariale,
      'anneeEngagement': anneeEngagement,
      'qualification': qualification,
    };
  }
}

class ST2FormPage extends StatefulWidget {
  const ST2FormPage({super.key});

  @override
  State<ST2FormPage> createState() => _ST2FormPageState();
}

class _ST2FormPageState extends State<ST2FormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSubmitting = false;

  //=========== Contrôleurs pour tous les champs du formulaire ===========
  // Utiliser des contrôleurs permet de lire/modifier les valeurs facilement

  // Section: Identification
  final _schoolNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _adresseController = TextEditingController();
  final _telephoneController = TextEditingController();
  String? _selectedPeriode;
  String? _niveauEcole;

  // Section: Localisation
  String? _selectedProvince = 'HAUT-LOMAMI';
  String? _selectedProvinceEdu = 'HAUT-LOMAMI 1';
  final _villeVillageController = TextEditingController();
  String? _selectedSousDivision;
  String? _selectedRegimeGestion;
  final _refJuridiqueController = TextEditingController();
  final _idDinacopeController = TextEditingController();
  String? _selectedStatutEtablissement;

  // Section: Informations Générales
  bool? _hasProgrammesOfficiels;
  bool? _hasLatrines;
  final _latrinesTotalController = TextEditingController();
  final _latrinesFillesController = TextEditingController();
  bool? _hasPrevisionsBudgetaires;

  // Section: Données scolaires (communes à tous les niveaux)
  final _totalEnseignantsController = TextEditingController();
  List<TeacherData> _teachers = [];

  // ... (D'autres contrôleurs spécifiques aux niveaux seront initialisés plus tard)

  @override
  void initState() {
    super.initState();
    _loadUserDataAndInitializeForm();

    // Listener pour mettre à jour la liste des enseignants dynamiquement
    _totalEnseignantsController.addListener(_updateTeacherList);
  }

  @override
  void dispose() {
    // Il est crucial de disposer les contrôleurs pour libérer la mémoire
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
    // ... disposez tous les autres contrôleurs ici
    super.dispose();
  }

  Future<void> _loadUserDataAndInitializeForm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data();
      if (data != null && mounted) {
        setState(() {
          _schoolNameController.text = data['schoolName'] ?? 'N/A';
          _fullNameController.text = data['fullName'] ?? 'N/A';
          _niveauEcole = data['niveauEcole'] ?? 'secondaire';
          _isLoading = false;
        });
      }
    } else {
      // Gérer le cas où l'utilisateur n'est pas connecté
      setState(() => _isLoading = false);
    }
  }

  void _updateTeacherList() {
    final count = int.tryParse(_totalEnseignantsController.text) ?? 0;
    if (count < 0) return;

    setState(() {
      while (_teachers.length < count) {
        _teachers.add(TeacherData());
      }
      while (_teachers.length > count) {
        _teachers.removeLast();
      }
    });
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

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Utilisateur non connecté.");

      // Création d'une Map pour stocker toutes les données
      Map<String, dynamic> formData = {
        'submittedAt': FieldValue.serverTimestamp(),
        'submittedBy': user.uid,
        'status': 'Soumis',

        // Identification
        'schoolName': _schoolNameController.text,
        'chefEtablissementName': _fullNameController.text,
        'niveauEcole': _niveauEcole,
        'adresse': _adresseController.text,
        'telephoneChef': _telephoneController.text,
        'periode': _selectedPeriode,

        // Localisation
        'province': _selectedProvince,
        'provinceEducationnelle': _selectedProvinceEdu,
        'villeVillage': _villeVillageController.text,
        'sousDivision': _selectedSousDivision,
        'regimeGestion': _selectedRegimeGestion,
        'refJuridique': _refJuridiqueController.text,
        'idDinacope': _idDinacopeController.text,
        'statutEtablissement': _selectedStatutEtablissement,

        // Infos Générales
        'hasProgrammesOfficiels': _hasProgrammesOfficiels,
        'hasLatrines': _hasLatrines,
        'latrinesTotal':
            _hasLatrines == true
                ? int.tryParse(_latrinesTotalController.text)
                : null,
        'latrinesFilles':
            _hasLatrines == true
                ? int.tryParse(_latrinesFillesController.text)
                : null,
        'hasPrevisionsBudgetaires': _hasPrevisionsBudgetaires,

        // Données sur les paramètres scolaires
        'totalEnseignants': int.tryParse(_totalEnseignantsController.text),
        // Conversion de la liste d'objets TeacherData en une liste de Maps
        'enseignants': _teachers.map((teacher) => teacher.toMap()).toList(),

        // TODO: Ajouter les autres données spécifiques au niveau (élèves, manuels, etc.)
        // Cette partie devra être complétée avec les contrôleurs des sections dynamiques
      };

      // Ajout des données à la collection 'st2_forms'
      await FirebaseFirestore.instance.collection('st2_forms').add(formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Formulaire soumis avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la soumission : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  //=========== Widgets réutilisables pour un code propre ===========

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
    bool enabled = true,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(fontSize: 13),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.indigo, width: 2),
        ),
        counterText: "", // Cache le compteur de longueur
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est requis.';
            }
            return null;
          },
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13, color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
      validator:
          validator ??
          (value) {
            if (value == null) {
              return 'Veuillez sélectionner une option.';
            }
            return null;
          },
    );
  }

  Widget _buildYesNoQuestion({
    required String question,
    required bool? groupValue,
    required void Function(bool?) onChanged,
  }) {
    return Column(
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
            ),
            const SizedBox(width: 20),
            Text('Non', style: const TextStyle(fontSize: 13)),
            Radio<bool>(
              value: false,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
          ],
        ),
      ],
    );
  }

  //=========== Sections dynamiques du formulaire ===========

  Widget _buildTeacherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Informations sur le Personnel Enseignant"),
        _buildTextField(
          controller: _totalEnseignantsController,
          label: 'Nombre d’enseignants au total',
          isNumber: true,
        ),
        const SizedBox(height: 16),
        // Génère dynamiquement les lignes pour chaque enseignant
        if (_teachers.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _teachers.length,
            itemBuilder: (context, index) {
              return FadeIn(
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enseignant ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const Divider(),
                        TextFormField(
                          initialValue: _teachers[index].nom,
                          onChanged: (val) => _teachers[index].nom = val,
                          decoration: const InputDecoration(
                            labelText: 'Nom de l’enseignant',
                            border: UnderlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                        _buildDropdown<String>(
                          label: 'Sexe',
                          value: _teachers[index].sexe,
                          onChanged:
                              (val) =>
                                  setState(() => _teachers[index].sexe = val),
                          items:
                              ['Masculin', 'Féminin']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                        ),
                        // ... Ajoutez les autres champs pour l'enseignant ici (matricule, etc.)
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildMaternelSection() {
    // TODO: Construire la section spécifique pour le maternel
    return Column(
      children: [
        _buildSectionTitle("Données pour le niveau Maternel"),
        // Mettre ici les champs : NOMBRE DE CLASSES, EFFECTIFS, PATRIMOINES...
        _buildTeacherSection(),
      ],
    );
  }

  Widget _buildPrimaireSection() {
    // TODO: Construire la section spécifique pour le primaire
    return Column(
      children: [
        _buildSectionTitle("Données pour le niveau Primaire"),
        // Mettre ici les champs : NOMBRE DE CLASSES, EFFECTIFS, PATRIMOINES...
        _buildTeacherSection(),
      ],
    );
  }

  Widget _buildSecondaireSection() {
    // TODO: Construire la section spécifique pour le secondaire
    return Column(
      children: [
        _buildSectionTitle("Données pour le niveau Secondaire"),
        // Mettre ici les champs : NOMBRE DE CLASSES, EFFECTIFS, PATRIMOINES...
        _buildTeacherSection(),
      ],
    );
  }

  Widget _buildConditionalSections() {
    switch (_niveauEcole) {
      case 'maternel':
        return _buildMaternelSection();
      case 'primaire':
        return _buildPrimaireSection();
      case 'secondaire':
        return _buildSecondaireSection();
      default:
        return const Center(
          child: Text(
            'Niveau scolaire non défini, impossible d\'afficher le formulaire.',
          ),
        );
    }
  }

  //=========== Méthode de construction principale (build) ===========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulaire ST2"),
        backgroundColor: Colors.indigo,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Chaque section est animée pour un effet moderne ---
                      FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(
                                  "Identification de l'établissement",
                                ),
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
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "Niveau école : ${_niveauEcole ?? 'N/A'}",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                _buildTextField(
                                  controller: _adresseController,
                                  label: "Adresse de l'établissement",
                                ),
                                _buildTextField(
                                  controller: _telephoneController,
                                  label: "Téléphone du chef Ets",
                                  isNumber: true,
                                  maxLength: 10,
                                ),
                                _buildDropdown<String>(
                                  label: 'Période',
                                  value: _selectedPeriode,
                                  items:
                                      ['SEMESTRE 1', 'SEMESTRE 2']
                                          .map(
                                            (p) => DropdownMenuItem(
                                              value: p,
                                              child: Text(p),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (val) => setState(
                                        () => _selectedPeriode = val,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(top: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(
                                  "Localisation Administrative",
                                ),
                                // ... (Ajoutez tous les autres champs ici)
                                _buildTextField(
                                  controller: _refJuridiqueController,
                                  label: "Réf. juridique (arrêté d’agrément)",
                                ),
                                _buildTextField(
                                  controller: _idDinacopeController,
                                  label: "ID DINACOPE",
                                  isNumber: true,
                                  maxLength: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(top: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("Informations Générales"),
                                _buildYesNoQuestion(
                                  question:
                                      'L’établissement dispose-t-il des programmes officiels de cours ?',
                                  groupValue: _hasProgrammesOfficiels,
                                  onChanged:
                                      (val) => setState(
                                        () => _hasProgrammesOfficiels = val,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                _buildYesNoQuestion(
                                  question: 'L’existence des latrines (W.C) ?',
                                  groupValue: _hasLatrines,
                                  onChanged:
                                      (val) =>
                                          setState(() => _hasLatrines = val),
                                ),
                                // Affiche les champs de nombre si la réponse est "Oui"
                                if (_hasLatrines == true)
                                  FadeIn(
                                    child: Column(
                                      children: [
                                        _buildTextField(
                                          controller: _latrinesTotalController,
                                          label:
                                              'Nombre total de compartiments',
                                          isNumber: true,
                                        ),
                                        _buildTextField(
                                          controller: _latrinesFillesController,
                                          label: 'Dont pour les filles',
                                          isNumber: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                _buildYesNoQuestion(
                                  question:
                                      'Votre Etablissement dispose-t-il des prévisions budgétaires et des documents comptables ?',
                                  groupValue: _hasPrevisionsBudgetaires,
                                  onChanged:
                                      (val) => setState(
                                        () => _hasPrevisionsBudgetaires = val,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Affiche la section correcte en fonction du niveau de l'école
                      FadeInUp(
                        duration: const Duration(milliseconds: 700),
                        child: _buildConditionalSections(),
                      ),

                      const SizedBox(height: 40),

                      // --- Bouton de soumission ---
                      if (_isSubmitting)
                        const Center(child: CircularProgressIndicator())
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: const Text("SOUMETTRE LE FORMULAIRE"),
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
}
