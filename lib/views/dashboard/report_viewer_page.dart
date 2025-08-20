// lib/views/dashboard/report_viewer_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:educ_collecteur/models/report_model.dart';
import 'package:educ_collecteur/services/pdf_service.dart';

class ReportViewerPage extends StatelessWidget {
  final ReportModel report;
  const ReportViewerPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final PdfService pdfService = PdfService();

    // Calcul des totaux pour l'affichage du résumé
    int totalEcoles = report.formsData.length;
    int totalEleves = 0;
    int totalLivres = 0;
    for (var form in report.formsData) {
      totalEleves +=
          form.effectifsEleves.values.fold(0, (sum, item) => sum + item.total);
      totalLivres += form.manuelsDisponibles.values.fold(
          0, (sum, manuels) => sum + manuels.values.fold(0, (s, i) => s + i));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(report.title, style: GoogleFonts.poppins()),
        backgroundColor: Colors.indigo,
        actions: [
          // Bouton pour l'impression
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: "Imprimer le Rapport",
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );
              try {
                await pdfService.generateAndPrintPdf(
                  title: report.title,
                  forms: report.formsData,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Erreur d'impression: $e"),
                        backgroundColor: Colors.red),
                  );
                }
              } finally {
                // La boîte de dialogue d'impression est modale, on ferme le chargement après
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),

          // Bouton pour l'exportation/téléchargement
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: "Exporter en PDF",
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );
              try {
                await pdfService.generateAndExportPdf(
                  title: report.title,
                  forms: report.formsData,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Erreur d'exportation: $e"),
                        backgroundColor: Colors.red),
                  );
                }
              } finally {
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(report.title,
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                  "Généré le: ${DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(report.createdAt)}",
                  style: GoogleFonts.poppins(color: Colors.grey.shade600)),
              Text("Critères: ${report.criteria}",
                  style: GoogleFonts.poppins(color: Colors.grey.shade600)),
              const SizedBox(height: 16),
              _buildSummaryCards(totalEcoles, totalEleves, totalLivres),
              const SizedBox(height: 24),
              Text("Données Détaillées ",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowColor:
                      MaterialStateProperty.all(Colors.indigo.shade50),
                  columns: const [
                    DataColumn(label: Text('Établissement')),
                    DataColumn(label: Text('Élèves'), numeric: true),
                    DataColumn(label: Text('Livres'), numeric: true),
                  ],
                  rows: report.formsData.map((form) {
                    final formTotalEleves = form.effectifsEleves.values
                        .fold(0, (sum, item) => sum + item.total);
                    final formTotalLivres = form.manuelsDisponibles.values.fold(
                        0,
                        (sum, manuels) =>
                            sum + manuels.values.fold(0, (s, i) => s + i));
                    return DataRow(cells: [
                      DataCell(
                          Text(form.schoolName, style: GoogleFonts.poppins())),
                      DataCell(Text(formTotalEleves.toString(),
                          style: GoogleFonts.poppins())),
                      DataCell(Text(formTotalLivres.toString(),
                          style: GoogleFonts.poppins())),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit les cartes de résumé en haut de la page.
  Widget _buildSummaryCards(int totalEcoles, int totalEleves, int totalLivres) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: "Écoles",
            value: totalEcoles.toString(),
            icon: Icons.school_outlined,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: "Élèves",
            value: totalEleves.toString(),
            icon: Icons.groups_outlined,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: "Livres",
            value: totalLivres.toString(),
            icon: Icons.book_outlined,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}

/// Un widget interne pour une carte de résumé.
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title,
                style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
