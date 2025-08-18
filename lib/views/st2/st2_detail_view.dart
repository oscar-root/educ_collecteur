// lib/st2/pages/st2_detail_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- IMPORTS DE VOTRE PROJET ---
import 'package:educ_collecteur/models/st2_model.dart';
import 'package:educ_collecteur/controllers/st2_controller.dart';
import 'package:educ_collecteur/views/st2/pages/st2_form_page.dart';

class ST2DetailView extends StatelessWidget {
  final ST2Model form;
  final String? userRole;

  const ST2DetailView({super.key, required this.form, this.userRole});

  @override
  Widget build(BuildContext context) {
    final bool isChefService = userRole == 'chef_service';
    final bool canChefServiceTakeAction =
        isChefService && form.status == 'Soumis';
    final bool canChefEtablissementEdit =
        !isChefService && form.status == 'Soumis';

    return Scaffold(
      appBar: AppBar(
        title: Text(form.periode ?? "Détails du Formulaire"),
        backgroundColor: Colors.indigo,
        actions: [
          if (canChefEtablissementEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Modifier',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ST2FormPage(formToEdit: form),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: "Identification",
              children: [
                _buildDetailRow(
                  "Statut du formulaire",
                  null,
                  statusChip: _buildStatusChip(form.status),
                ),
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
            _buildSectionCard(
              title: "Personnel Enseignant (${form.totalEnseignants})",
              children:
                  form.enseignants.isEmpty
                      ? [const Text("Aucun enseignant renseigné.")]
                      : form.enseignants
                          .map(
                            (teacher) => Container(
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
                                  _buildDetailRow(
                                    "Matricule",
                                    teacher.matricule,
                                  ),
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
                            ),
                          )
                          .toList(),
            ),
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
                    DataColumn(
                      label: Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      numeric: true,
                    ),
                  ],
                  rows:
                      form.effectifsEleves.entries
                          .map(
                            (entry) => DataRow(
                              cells: [
                                DataCell(Text(entry.key)),
                                DataCell(Text(entry.value.garcons.toString())),
                                DataCell(Text(entry.value.filles.toString())),
                                DataCell(
                                  Text(
                                    entry.value.total.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
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
                      form.equipements
                          .map(
                            (equip) => DataRow(
                              cells: [
                                DataCell(Text(equip.type)),
                                DataCell(Text(equip.enBonEtat.toString())),
                                DataCell(Text(equip.enMauvaisEtat.toString())),
                              ],
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          canChefServiceTakeAction ? _buildActionButtons(context) : null,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final ST2Controller st2Controller = ST2Controller();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close_rounded),
              label: const Text("Rejeter"),
              onPressed: () async {
                if (form.id == null) return;
                final success = await st2Controller.updateFormStatus(
                  docId: form.id!,
                  newStatus: 'Rejeté',
                  context: context,
                );
                if (success && context.mounted) Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade700),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              icon: const Icon(Icons.check_rounded),
              label: const Text("Valider"),
              onPressed: () async {
                if (form.id == null) return;
                final success = await st2Controller.updateFormStatus(
                  docId: form.id!,
                  newStatus: 'Validé',
                  context: context,
                );
                if (success && context.mounted) Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) => Card(
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
  Widget _buildDetailRow(String label, String? value, {Widget? statusChip}) =>
      Padding(
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
              child:
                  statusChip ??
                  Text(
                    value ?? 'Non spécifié',
                    style: const TextStyle(color: Colors.black87),
                  ),
            ),
          ],
        ),
      );
  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color foregroundColor;
    switch (status) {
      case 'Validé':
        backgroundColor = Colors.green.shade100;
        foregroundColor = Colors.green.shade800;
        break;
      case 'Rejeté':
        backgroundColor = Colors.red.shade100;
        foregroundColor = Colors.red.shade800;
        break;
      default:
        backgroundColor = Colors.blue.shade100;
        foregroundColor = Colors.blue.shade800;
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(
          status,
          style: TextStyle(fontWeight: FontWeight.bold, color: foregroundColor),
        ),
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        side: BorderSide(color: foregroundColor.withOpacity(0.3)),
      ),
    );
  }
}
