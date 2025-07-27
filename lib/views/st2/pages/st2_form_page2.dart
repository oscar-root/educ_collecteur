import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ST2FormPage2 extends StatefulWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final void Function(Map<String, dynamic>) onSave;

  const ST2FormPage2({
    super.key,
    required this.onPrevious,
    required this.onNext,
    required this.onSave,
  });

  @override
  State<ST2FormPage2> createState() => _ST2FormPage2State();
}

class _ST2FormPage2State extends State<ST2FormPage2> {
  final _formKey = GlobalKey<FormState>();

  bool hasProgrammes = false;
  bool hasCOPA = false;
  bool copaOp = false;
  String nbReunionCOPA = '';
  String nbFemmesCOPA = '';

  bool hasCOGES = false;
  bool cogesOp = false;
  String nbReunionCOGES = '';
  String nbFemmesCOGES = '';

  bool hasLatrines = false;
  String nbLatrines = '';
  String nbFillesLatrines = '';

  String nbEnsFormes = '';
  String nbEnsPositifs = '';
  String nbEnsInspectes = '';

  bool hasGovEleves = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page 2 – Informations générales"),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onPrevious,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "INFORMATIONS GÉNÉRALES SUR L'ÉTABLISSEMENT",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 16),

            CheckboxListTile(
              title: const Text(
                'Dispose de programmes officiels de cours ?',
                style: TextStyle(fontSize: 13),
              ),
              value: hasProgrammes,
              onChanged: (val) => setState(() => hasProgrammes = val!),
            ),

            CheckboxListTile(
              title: const Text(
                'Dispose d’un COPA ?',
                style: TextStyle(fontSize: 13),
              ),
              value: hasCOPA,
              onChanged: (val) => setState(() => hasCOPA = val!),
            ),

            if (hasCOPA) ...[
              CheckboxListTile(
                title: const Text(
                  'Le COPA est-il opérationnel ?',
                  style: TextStyle(fontSize: 13),
                ),
                value: copaOp,
                onChanged: (val) => setState(() => copaOp = val!),
              ),
              _buildNumberField(
                label: 'Nombre de réunions COPA (l\'année passée)',
                value: nbReunionCOPA,
                maxLength: 2,
                onChanged: (val) => nbReunionCOPA = val,
              ),
              _buildNumberField(
                label: 'Nombre de femmes dans le COPA',
                value: nbFemmesCOPA,
                maxLength: 2,
                validator: (val) {
                  if (val != null && int.tryParse(val)! >= 5) {
                    return 'Doit être inférieur à 5';
                  }
                  return null;
                },
                onChanged: (val) => nbFemmesCOPA = val,
              ),
            ],

            CheckboxListTile(
              title: const Text(
                'Dispose d’un COGES ?',
                style: TextStyle(fontSize: 13),
              ),
              value: hasCOGES,
              onChanged: (val) => setState(() => hasCOGES = val!),
            ),

            if (hasCOGES) ...[
              CheckboxListTile(
                title: const Text(
                  'Le COGES est-il opérationnel ?',
                  style: TextStyle(fontSize: 13),
                ),
                value: cogesOp,
                onChanged: (val) => setState(() => cogesOp = val!),
              ),
              _buildNumberField(
                label: 'Nombre de réunions COGES (année passée)',
                value: nbReunionCOGES,
                maxLength: 2,
                validator: (val) {
                  if (val != null && int.tryParse(val)! >= 6) {
                    return 'Doit être inférieur à 6';
                  }
                  return null;
                },
                onChanged: (val) => nbReunionCOGES = val,
              ),
              _buildNumberField(
                label: 'Nombre de femmes dans le COGES',
                value: nbFemmesCOGES,
                maxLength: 2,
                validator: (val) {
                  if (val != null && int.tryParse(val)! >= 5) {
                    return 'Doit être inférieur à 5';
                  }
                  return null;
                },
                onChanged: (val) => nbFemmesCOGES = val,
              ),
            ],

            CheckboxListTile(
              title: const Text(
                'Dispose de latrines (W.C)',
                style: TextStyle(fontSize: 13),
              ),
              value: hasLatrines,
              onChanged: (val) => setState(() => hasLatrines = val!),
            ),

            if (hasLatrines) ...[
              _buildNumberField(
                label: 'Nombre de compartiments',
                value: nbLatrines,
                maxLength: 2,
                onChanged: (val) => nbLatrines = val,
              ),
              _buildNumberField(
                label: 'Dont pour les filles',
                value: nbFillesLatrines,
                maxLength: 2,
                onChanged: (val) => nbFillesLatrines = val,
              ),
            ],

            _buildNumberField(
              label: 'Nbre enseignants formés (12 derniers mois)',
              value: nbEnsFormes,
              maxLength: 3,
              onChanged: (val) => setState(() => nbEnsFormes = val),
            ),

            if (int.tryParse(nbEnsFormes) != null && int.parse(nbEnsFormes) > 0)
              _buildNumberField(
                label: 'Nbre enseignants cotés positivement',
                value: nbEnsPositifs,
                maxLength: 3,
                onChanged: (val) => nbEnsPositifs = val,
              ),

            _buildNumberField(
              label: 'Nbre enseignants inspectés (C3)',
              value: nbEnsInspectes,
              maxLength: 3,
              onChanged: (val) => nbEnsInspectes = val,
            ),

            CheckboxListTile(
              title: const Text(
                'Gouvernement d’élèves opérationnel ?',
                style: TextStyle(fontSize: 13),
              ),
              value: hasGovEleves,
              onChanged: (val) => setState(() => hasGovEleves = val!),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Précédent'),
                  onPressed: widget.onPrevious,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Suivant'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSave({
                        'hasProgrammes': hasProgrammes,
                        'hasCOPA': hasCOPA,
                        'copaOp': copaOp,
                        'nbReunionCOPA': nbReunionCOPA,
                        'nbFemmesCOPA': nbFemmesCOPA,
                        'hasCOGES': hasCOGES,
                        'cogesOp': cogesOp,
                        'nbReunionCOGES': nbReunionCOGES,
                        'nbFemmesCOGES': nbFemmesCOGES,
                        'hasLatrines': hasLatrines,
                        'nbLatrines': nbLatrines,
                        'nbFillesLatrines': nbFillesLatrines,
                        'nbEnsFormes': nbEnsFormes,
                        'nbEnsPositifs': nbEnsPositifs,
                        'nbEnsInspectes': nbEnsInspectes,
                        'hasGovEleves': hasGovEleves,
                      });
                      widget.onNext();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required String value,
    required Function(String) onChanged,
    int maxLength = 3,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        keyboardType: TextInputType.number,
        maxLength: maxLength,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator:
            validator ??
            (val) => val == null || val.isEmpty ? 'Champ requis' : null,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          counterText: "",
          border: const UnderlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
