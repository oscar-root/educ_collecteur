import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ST2FormPage4 extends StatefulWidget {
  final String niveauEcole;
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;
  final void Function(Map<String, dynamic>) onSave;

  const ST2FormPage4({
    super.key,
    required this.niveauEcole,
    required this.onPrevious,
    required this.onSubmit,
    required this.onSave,
  });

  @override
  State<ST2FormPage4> createState() => _ST2FormPage4State();
}

class _ST2FormPage4State extends State<ST2FormPage4> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, Map<String, TextEditingController>> manuels = {};
  final Map<String, TextEditingController> bonsEtats = {};
  final Map<String, TextEditingController> mauvaisEtats = {};

  final List<String> matieres = [
    'Français',
    'Mathématiques',
    'Eveil',
    'ECM',
    'Autres',
  ];
  final List<String> equipements = [
    'Tableaux',
    'Tables',
    'Chaises',
    'Ordinateurs',
    'Kits scientifiques',
  ];

  late List<String> annees;

  @override
  void initState() {
    super.initState();

    if (widget.niveauEcole.toLowerCase() == 'maternel') {
      annees = ['1ère', '2ème', '3ème'];
    } else {
      annees = ['1ère', '2ème', '3ème', '4ème', '5ème', '6ème'];
    }

    for (var matiere in matieres) {
      manuels[matiere] = {
        for (var annee in annees) annee: TextEditingController(),
      };
    }

    for (var equip in equipements) {
      bonsEtats[equip] = TextEditingController();
      mauvaisEtats[equip] = TextEditingController();
    }
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontSize: 14),
    border: const UnderlineInputBorder(),
  );

  Widget _buildNumberField(TextEditingController controller, {String? hint}) {
    return SizedBox(
      width: 70,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(hintText: hint ?? '0', counterText: ""),
        validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
      ),
    );
  }

  Map<String, Map<String, String>> getManuelsMap() {
    return {
      for (var matiere in manuels.keys)
        matiere: {
          for (var annee in manuels[matiere]!.keys)
            annee: manuels[matiere]![annee]!.text,
        },
    };
  }

  @override
  void dispose() {
    for (var mat in manuels.values) {
      for (var ctrl in mat.values) {
        ctrl.dispose();
      }
    }
    for (var c in bonsEtats.values) {
      c.dispose();
    }
    for (var c in mauvaisEtats.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page 4 – Patrimoine scolaire"),
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
              "Manuels disponibles par année",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: {
                0: const FlexColumnWidth(2),
                for (int i = 1; i <= annees.length; i++)
                  i: const FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Colors.indigoAccent),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Manuel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    for (var annee in annees)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          annee,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
                for (var matiere in matieres)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(matiere),
                      ),
                      for (var annee in annees)
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: _buildNumberField(manuels[matiere]![annee]!),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Équipements de l’établissement",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (var equip in equipements)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(equip)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNumberField(
                        bonsEtats[equip]!,
                        hint: 'Bon état',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNumberField(
                        mauvaisEtats[equip]!,
                        hint: 'Mauvais',
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 28),
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
                      final page4Data = {
                        'manuelsParAnnee': getManuelsMap(),
                        'equipements': {
                          'bons': {
                            for (var e in bonsEtats.entries)
                              e.key: e.value.text,
                          },
                          'mauvais': {
                            for (var e in mauvaisEtats.entries)
                              e.key: e.value.text,
                          },
                        },
                      };
                      widget.onSave(page4Data);
                      widget.onSubmit();
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Soumettre"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
