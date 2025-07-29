// lib/st2/pages/st2_detail_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:educ_collecteur/models/st2_model.dart';

/// Un écran qui affiche les détails complets d'un formulaire ST2.
class ST2DetailView extends StatelessWidget {
  final ST2Model form;

  const ST2DetailView({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du Formulaire"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section Identification ---
            _buildSectionCard(
              title: "Identification",
              children: [
                _buildDetailRow("Nom de l'établissement", form.schoolName),
                _buildDetailRow(
                  "Chef d'établissement",
                  form.chefEtablissementName,
                ),
                _buildDetailRow(
                  "Niveau d'école",
                  form.niveauEcole?.toUpperCase(),
                ),
                _buildDetailRow("Adresse", form.adresse),
                _buildDetailRow("Téléphone du chef Ets", form.telephoneChef),
                _buildDetailRow("Période", form.periode),
                _buildDetailRow(
                  "Statut du formulaire",
                  form.status,
                  isHighlighted: true,
                ),
                _buildDetailRow(
                  "Date de soumission",
                  form.submittedAt != null
                      ? DateFormat(
                        'dd/MM/yyyy à HH:mm',
                        'fr_FR',
                      ).format(form.submittedAt!)
                      : 'N/A',
                ),
              ],
            ),

            // --- Section Localisation ---
            _buildSectionCard(
              title: "Localisation Administrative",
              children: [
                _buildDetailRow("Province", form.province),
                _buildDetailRow(
                  "Province Éducationnelle",
                  form.provinceEducationnelle,
                ),
                _buildDetailRow("Ville/Village", form.villeVillage),
                _buildDetailRow("Sous-division", form.sousDivision),
                _buildDetailRow("Régime de gestion", form.regimeGestion),
                _buildDetailRow("Réf. juridique", form.refJuridique),
                _buildDetailRow("ID DINACOPE", form.idDinacope),
                _buildDetailRow(
                  "Statut de l'établissement",
                  form.statutEtablissement,
                ),
              ],
            ),

            // --- Section Informations Générales ---
            _buildSectionCard(
              title: "Informations Générales",
              children: [
                _buildDetailRow(
                  "Dispose des programmes officiels ?",
                  form.hasProgrammesOfficiels == true ? 'Oui' : 'Non',
                ),
                _buildDetailRow(
                  "Existence de latrines ?",
                  form.hasLatrines == true ? 'Oui' : 'Non',
                ),
                if (form.hasLatrines == true) ...[
                  _buildDetailRow(
                    "  - Nombre total de latrines",
                    form.latrinesTotal?.toString(),
                  ),
                  _buildDetailRow(
                    "  - Dont pour les filles",
                    form.latrinesFilles?.toString(),
                  ),
                ],
                _buildDetailRow(
                  "Dispose des prévisions budgétaires ?",
                  form.hasPrevisionsBudgetaires == true ? 'Oui' : 'Non',
                ),
              ],
            ),

            // --- Section Personnel Enseignant ---
            _buildSectionCard(
              title: "Personnel Enseignant (${form.totalEnseignants})",
              children:
                  form.enseignants.isEmpty
                      ? [const Text("Aucun enseignant renseigné.")]
                      : form.enseignants.map((teacher) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                teacher.nom,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              const Divider(),
                              _buildDetailRow("Sexe", teacher.sexe),
                              _buildDetailRow("Matricule", teacher.matricule),
                              _buildDetailRow(
                                "Situation salariale",
                                teacher.situationSalariale,
                              ),
                              _buildDetailRow(
                                "Année d'engagement",
                                teacher.anneeEngagement?.toString(),
                              ),
                              _buildDetailRow(
                                "Qualification",
                                teacher.qualification,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
            ),

            // --- Section Effectifs des élèves ---
            _buildSectionCard(
              title: "Effectifs des Élèves",
              children: [
                DataTable(
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Classe',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Garçons',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Filles',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      numeric: true,
                    ),
                  ],
                  rows:
                      form.effectifsEleves.entries.map((entry) {
                        return DataRow(
                          cells: [
                            DataCell(Text(entry.key)),
                            DataCell(
                              Text(entry.value['garcons']?.toString() ?? '0'),
                            ),
                            DataCell(
                              Text(entry.value['filles']?.toString() ?? '0'),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ],
            ),

            // --- Section Equipements ---
            _buildSectionCard(
              title: "Patrimoine : Équipements",
              children: [
                DataTable(
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Bon État',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Mauvais État',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      numeric: true,
                    ),
                  ],
                  rows:
                      form.equipements.map((equip) {
                        return DataRow(
                          cells: [
                            DataCell(Text(equip.type)),
                            DataCell(Text(equip.enBonEtat.toString())),
                            DataCell(Text(equip.enMauvaisEtat.toString())),
                          ],
                        );
                      }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget helper pour créer une carte de section avec un titre.
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Widget helper pour afficher une ligne de détail (libellé et valeur).
  Widget _buildDetailRow(
    String label,
    String? value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label :',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'Non spécifié',
              style: TextStyle(
                color: isHighlighted ? Colors.green.shade700 : Colors.black87,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
