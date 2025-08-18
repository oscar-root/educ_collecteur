// lib/views/dashboard/saved_reports_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:educ_collecteur/models/report_model.dart';
import 'report_viewer_page.dart'; // NOUVEAU: Import de la page de visualisation

class SavedReportsPage extends StatefulWidget {
  const SavedReportsPage({super.key});
  @override
  State<SavedReportsPage> createState() => _SavedReportsPageState();
}

class _SavedReportsPageState extends State<SavedReportsPage> {
  /// Navigue vers la page de visualisation pour le rapport sélectionné.
  void _viewReport(ReportModel report) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportViewerPage(report: report)),
    );
  }

  /// Affiche une boîte de dialogue de confirmation avant de supprimer le rapport de Firestore.
  Future<void> _deleteReport(ReportModel report) async {
    if (report.id == null) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Voulez-vous vraiment supprimer le rapport "${report.title}" ? Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('generated_reports')
            .doc(report.id)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("${report.title} supprimé."),
              backgroundColor: Colors.orange),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Erreur lors de la suppression: $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      // Le Stream écoute maintenant la collection `generated_reports`
      stream: FirebaseFirestore.instance
          .collection('generated_reports')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child:
                  Text("Erreur de chargement des rapports: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                "Aucun rapport n'a été généré et sauvegardé pour le moment.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.grey.shade600),
              ),
            ),
          );
        }

        // Conversion des documents Firestore en objets ReportModel
        final reports = snapshot.data!.docs
            .map((doc) => ReportModel.fromFirestore(doc))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                leading: const Icon(Icons.article_outlined,
                    color: Colors.indigo, size: 36),
                title: Text(report.title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  "Créé le: ${DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(report.createdAt)}\nCritères: ${report.criteria}",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () => _viewReport(report),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'view') _viewReport(report);
                    if (value == 'delete') _deleteReport(report);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'view', child: Text('Consulter')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Supprimer',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
