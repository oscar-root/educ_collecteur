// lib/views/dashboard/saved_reports_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:educ_collecteur/models/report_model.dart';
import 'report_detail_page.dart'; // <-- Importez la nouvelle page de détails

class SavedReportsPage extends StatelessWidget {
  const SavedReportsPage({super.key});

  /// Logique pour supprimer un rapport avec confirmation
  Future<void> _deleteReport(BuildContext context, ReportModel report) async {
    final bool? confirm = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text(
              "Voulez-vous vraiment supprimer le rapport '${report.title}' ? Cette action est irréversible.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true && report.id != null) {
      await FirebaseFirestore.instance
          .collection('generated_reports')
          .doc(report.id)
          .delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rapport supprimé.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rapports Enregistrés"),
        automaticallyImplyLeading:
            false, // On retire la flèche de retour si c'est un onglet
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream:
            FirebaseFirestore.instance
                .collection('generated_reports')
                .orderBy('generatedAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Erreur : ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Aucun rapport n'a été enregistré.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final reports =
              snapshot.data!.docs
                  .map((doc) => ReportModel.fromFirestore(doc))
                  .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final date =
                  report.generatedAt != null
                      ? DateFormat(
                        'dd/MM/yyyy à HH:mm',
                        'fr_FR',
                      ).format(report.generatedAt!)
                      : 'Date inconnue';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Icon(
                    Icons.assessment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    report.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Critère: ${report.filterValue}\n${report.summary['totalEtablissements'] ?? 0} établissements - Généré le: $date",
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') _deleteReport(context, report);
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                  ),
                  onTap: () {
                    // --- NAVIGATION VERS LA PAGE DE DÉTAILS ---
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportDetailPage(report: report),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
