// lib/views/st2/pages/st2_form_page1.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ST2FormPage1 extends StatefulWidget {
  final VoidCallback onNext;
  final Function(Map<String, dynamic>) onSave;

  const ST2FormPage1({super.key, required this.onNext, required this.onSave});

  @override
  State<ST2FormPage1> createState() => _ST2FormPage1State();
}

class _ST2FormPage1State extends State<ST2FormPage1> {
  final _formKey = GlobalKey<FormState>();

  final _adresseEtsController = TextEditingController();
  final _telChefController = TextEditingController();
  final _villeController = TextEditingController();
  final _territoireController = TextEditingController();
  final _villageController = TextEditingController();
  final _refJuridiqueController = TextEditingController();
  final _matriculeSecopeController = TextEditingController();

  String? _periode;
  String? _province;
  String? _provinceEduc;
  String? _sousDivision;
  String? _regime;
  String? _mecanisation;

  String nomChef = '';
  String nomEts = '';

  final List<String> _periodes = ['SEMESTRE 1', 'SEMESTRE 2'];
  final List<String> _provinces = ['HAUT-LOMAMI'];
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
  final List<String> _regimes = [
    'ENC',
    'Catholique',
    'Protestant',
    'ECK',
    'ECI',
    'Salutiste (ECS)',
    'Fraternité (ECF)',
    'Privée (EPR)',
  ];
  final List<String> _provinceEducs = ['HAUT-LOMAMI 1'];
  final List<String> _mecanisations = [
    'Mécanisé et payé',
    'Mécanisé et non payé',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data();
      setState(() {
        nomChef = data?['fullName'] ?? '';
        nomEts = data?['schoolName'] ?? '';
      });
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14),
      border: const UnderlineInputBorder(),
    );
  }

  Widget _buildNumberField(
    TextEditingController controller,
    String label, {
    int maxLength = 12,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxLength),
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: _decoration(label),
      style: const TextStyle(fontSize: 13),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Champ requis';
        if (value.length != maxLength)
          return 'Doit contenir $maxLength chiffres';
        return null;
      },
    );
  }

  void _submitPage1() {
    if (_formKey.currentState!.validate()) {
      final data = {
        "nomEts": nomEts,
        "adresseEts": _adresseEtsController.text,
        "nomChef": nomChef,
        "telChef": _telChefController.text,
        "periode": _periode,
        "province": _province,
        "ville": _villeController.text,
        "territoire": _territoireController.text,
        "village": _villageController.text,
        "provinceEduc": _provinceEduc,
        "sousDivision": _sousDivision,
        "regime": _regime,
        "refJuridique": _refJuridiqueController.text,
        "matriculeSecope": _matriculeSecopeController.text,
        "mecanisation": _mecanisation,
      };

      widget.onSave(data);
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page 1 – Identification"),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: nomEts,
                decoration: _decoration("Nom de l'établissement"),
                enabled: false,
                style: const TextStyle(fontSize: 13),
              ),
              TextFormField(
                controller: _adresseEtsController,
                decoration: _decoration("Adresse de l'établissement"),
                style: const TextStyle(fontSize: 13),
              ),
              TextFormField(
                initialValue: nomChef,
                decoration: _decoration("Nom du chef de l'établissement"),
                enabled: false,
                style: const TextStyle(fontSize: 13),
              ),
              _buildNumberField(_telChefController, "Téléphone (12 chiffres)"),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _periode,
                decoration: _decoration("Période"),
                items:
                    _periodes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => _periode = val),
                validator: (val) => val == null ? 'Champ requis' : null,
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _province,
                decoration: _decoration("Province"),
                items:
                    _provinces
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => _province = val),
              ),

              TextFormField(
                controller: _villeController,
                decoration: _decoration("Ville"),
                style: const TextStyle(fontSize: 13),
              ),
              TextFormField(
                controller: _territoireController,
                decoration: _decoration("Territoire ou commune"),
                style: const TextStyle(fontSize: 13),
              ),
              TextFormField(
                controller: _villageController,
                decoration: _decoration("Village"),
                style: const TextStyle(fontSize: 13),
              ),

              DropdownButtonFormField<String>(
                value: _provinceEduc,
                decoration: _decoration("Province éducationnelle"),
                items:
                    _provinceEducs
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => _provinceEduc = val),
              ),
              DropdownButtonFormField<String>(
                value: _sousDivision,
                decoration: _decoration("Sous-division"),
                items:
                    _sousDivisions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => _sousDivision = val),
              ),
              DropdownButtonFormField<String>(
                value: _regime,
                decoration: _decoration("Régime de gestion"),
                items:
                    _regimes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => _regime = val),
              ),
              TextFormField(
                controller: _refJuridiqueController,
                decoration: _decoration("Référence juridique"),
                style: const TextStyle(fontSize: 13),
              ),
              _buildNumberField(
                _matriculeSecopeController,
                "N° Matricule SECOPE",
                maxLength: 12,
              ),

              DropdownButtonFormField<String>(
                value: _mecanisation,
                decoration: _decoration("Statut de mécanisation"),
                items:
                    _mecanisations
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => _mecanisation = val),
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Suivant"),
                onPressed: _submitPage1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
