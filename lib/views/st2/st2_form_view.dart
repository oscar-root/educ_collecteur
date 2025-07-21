import 'package:flutter/material.dart';

class ST2FormView extends StatefulWidget {
  const ST2FormView({super.key});

  @override
  State<ST2FormView> createState() => _ST2FormViewState();
}

class _ST2FormViewState extends State<ST2FormView> {
  final _formKey = GlobalKey<FormState>();

  // Exemple de champs ST2
  final _schoolNameController = TextEditingController();
  final _schoolYearController = TextEditingController();
  final _studentsCountController = TextEditingController();
  final _teachersCountController = TextEditingController();

  @override
  void dispose() {
    _schoolNameController.dispose();
    _schoolYearController.dispose();
    _studentsCountController.dispose();
    _teachersCountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'schoolName': _schoolNameController.text.trim(),
        'schoolYear': _schoolYearController.text.trim(),
        'studentsCount': int.parse(_studentsCountController.text.trim()),
        'teachersCount': int.parse(_teachersCountController.text.trim()),
      };

      // TODO: Enregistrer dans Firestore
      debugPrint('Formulaire ST2 soumis: $data');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formulaire ST2 soumis avec succès')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulaire ST2')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _schoolNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'établissement',
                  icon: Icon(Icons.school),
                ),
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Veuillez entrer le nom de l\'école'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _schoolYearController,
                decoration: const InputDecoration(
                  labelText: 'Année scolaire',
                  icon: Icon(Icons.date_range),
                ),
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Veuillez entrer l\'année scolaire'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentsCountController,
                decoration: const InputDecoration(
                  labelText: 'Nombre d\'élèves',
                  icon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Veuillez entrer le nombre d\'élèves'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teachersCountController,
                decoration: const InputDecoration(
                  labelText: 'Nombre d\'enseignants',
                  icon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Veuillez entrer le nombre d\'enseignants'
                            : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Soumettre'),
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
