import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ST2FormPage3 extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final void Function(Map<String, dynamic>) onSave;
  final String niveauEcole;

  const ST2FormPage3({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.onSave,
    required this.niveauEcole,
  });

  @override
  State<ST2FormPage3> createState() => _ST2FormPage3State();
}

class _ST2FormPage3State extends State<ST2FormPage3> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nbEnseignantsController =
      TextEditingController();
  List<Map<String, TextEditingController>> enseignants = [];
  Map<String, TextEditingController> classesAutorisees = {};
  Map<String, TextEditingController> classesOrganisees = {};
  Map<String, TextEditingController> effectifGarcons = {};
  Map<String, TextEditingController> effectifFilles = {};

  @override
  void initState() {
    super.initState();

    _nbEnseignantsController.addListener(() {
      final count = int.tryParse(_nbEnseignantsController.text) ?? 0;
      if (enseignants.length != count) {
        enseignants = List.generate(
          count,
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
        setState(() {});
      }
    });

    if (widget.niveauEcole.toLowerCase() == 'secondaire') {
      for (final niveau in ['7ème', '8ème', '1ère', '2ème', '3ème', '4ème']) {
        classesAutorisees[niveau] = TextEditingController();
        classesOrganisees[niveau] = TextEditingController();
      }
    }

    for (final annee in ['1ère', '2ème', '3ème', '4ème', '5ème', '6ème']) {
      effectifGarcons[annee] = TextEditingController();
      effectifFilles[annee] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nbEnseignantsController.dispose();
    for (final c in classesAutorisees.values) {
      c.dispose();
    }
    for (final c in classesOrganisees.values) {
      c.dispose();
    }
    for (final c in effectifGarcons.values) {
      c.dispose();
    }
    for (final c in effectifFilles.values) {
      c.dispose();
    }
    for (final e in enseignants) {
      for (final c in e.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters:
            inputType == TextInputType.number
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          border: const UnderlineInputBorder(),
        ),
        style: const TextStyle(fontSize: 13),
        validator:
            (value) => value == null || value.isEmpty ? 'Champ requis' : null,
      ),
    );
  }

  Widget _buildEnseignantCard(int index) {
    final data = enseignants[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInput("Nom de l'enseignant", data['nom']!),
            DropdownButtonFormField<String>(
              value: data['sexe']!.text.isEmpty ? null : data['sexe']!.text,
              items: const [
                DropdownMenuItem(value: 'Masculin', child: Text('Masculin')),
                DropdownMenuItem(value: 'Féminin', child: Text('Féminin')),
              ],
              onChanged:
                  (val) => setState(() => data['sexe']!.text = val ?? ''),
              decoration: const InputDecoration(labelText: "Sexe"),
            ),
            _buildInput("Âge", data['age']!, inputType: TextInputType.number),
            _buildInput(
              "Matricule DINACOPE",
              data['matricule']!,
              inputType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value:
                  data['salaire']!.text.isEmpty ? null : data['salaire']!.text,
              items: const [
                DropdownMenuItem(value: 'Payé', child: Text('Payé')),
                DropdownMenuItem(value: 'Non payé', child: Text('Non payé')),
              ],
              onChanged:
                  (val) => setState(() => data['salaire']!.text = val ?? ''),
              decoration: const InputDecoration(
                labelText: "Situation salariale",
              ),
            ),
            _buildInput(
              "Année d'engagement",
              data['annee']!,
              inputType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value:
                  data['qualification']!.text.isEmpty
                      ? null
                      : data['qualification']!.text,
              items: const [
                DropdownMenuItem(value: 'D4', child: Text('D4')),
                DropdownMenuItem(value: 'D6', child: Text('D6')),
                DropdownMenuItem(value: 'P6', child: Text('P6')),
                DropdownMenuItem(value: 'Autres', child: Text('Autres')),
              ],
              onChanged:
                  (val) =>
                      setState(() => data['qualification']!.text = val ?? ''),
              decoration: const InputDecoration(labelText: "Qualification"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page 3 – Paramètres scolaires"),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onPrevious,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (widget.niveauEcole.toLowerCase() == 'secondaire') ...[
                const Text("Nombre de classes autorisées et organisées"),
                for (final niveau in classesAutorisees.keys) ...[
                  _buildInput(
                    "Classes autorisées – $niveau",
                    classesAutorisees[niveau]!,
                    inputType: TextInputType.number,
                  ),
                  _buildInput(
                    "Classes organisées – $niveau",
                    classesOrganisees[niveau]!,
                    inputType: TextInputType.number,
                  ),
                ],
              ],
              _buildInput(
                "Nombre total d’enseignants",
                _nbEnseignantsController,
                inputType: TextInputType.number,
              ),
              for (int i = 0; i < enseignants.length; i++)
                _buildEnseignantCard(i),

              const SizedBox(height: 16),
              const Text("Effectifs des élèves inscrits"),
              for (final annee in effectifGarcons.keys) ...[
                _buildInput(
                  "Garçons – $annee",
                  effectifGarcons[annee]!,
                  inputType: TextInputType.number,
                ),
                _buildInput(
                  "Filles – $annee",
                  effectifFilles[annee]!,
                  inputType: TextInputType.number,
                ),
              ],

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: widget.onPrevious,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Précédent"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave({
                          'classesAutorisees': classesAutorisees.map(
                            (k, v) => MapEntry(k, v.text),
                          ),
                          'classesOrganisees': classesOrganisees.map(
                            (k, v) => MapEntry(k, v.text),
                          ),
                          'nbEnseignants': _nbEnseignantsController.text,
                          'enseignants':
                              enseignants
                                  .map(
                                    (e) => e.map((k, v) => MapEntry(k, v.text)),
                                  )
                                  .toList(),
                          'effectifGarcons': effectifGarcons.map(
                            (k, v) => MapEntry(k, v.text),
                          ),
                          'effectifFilles': effectifFilles.map(
                            (k, v) => MapEntry(k, v.text),
                          ),
                        });
                        widget.onNext();
                      }
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Suivant"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
