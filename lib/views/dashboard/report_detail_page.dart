// lib/views/dashboard/report_detail_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:educ_collecteur/models/report_model.dart';
import 'package:educ_collecteur/models/st2_model.dart';

class ReportDetailPage extends StatefulWidget {
  final ReportModel report;

  const ReportDetailPage({super.key, required this.report});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  late Future<List<ST2Model>> _formsFuture;

  @override
  void initState() {
    super.initState();
    // Lance la récupération des formulaires ST2 basés sur les IDs stockés dans le rapport
    _formsFuture = _fetchFormsData();
  }

  /// Récupère les détails de chaque formulaire ST2 inclus dans le rapport.
  Future<List<ST2Model>> _fetchFormsData() async {
    if (widget.report.formIds.isEmpty) {
      return [];
    }
    // Crée une requête pour récupérer plusieurs documents par leur ID
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('st2_forms')
            .where(FieldPath.documentId, whereIn: widget.report.formIds)
            .get();

    return querySnapshot.docs
        .map(
          (doc) => ST2Model.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          ),
        )
        .toList();
  }

  /// Génère le document PDF à partir de la liste des formulaires.
  Future<void> _printReport(List<ST2Model> forms) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.latoRegular();
    final boldFont = await PdfGoogleFonts.latoBold();

    final headers = [
      'N°',
      'ÉTABLISSEMENT',
      'ID DINACOPE',
      'SOUS-DIVISION',
      'RÉGIME',
      'CLASSES',
      'ÉLÈVES',
    ];
    final data =
        forms.asMap().entries.map((entry) {
          final form = entry.value;
          final classes = form.classesOrganisees.values.fold(
            0,
            (sum, item) => sum + item,
          );
          final eleves = form.effectifsEleves.values.fold(
            0,
            (sum, item) => sum + (item['garcons'] ?? 0) + (item['filles'] ?? 0),
          );
          return [
            (entry.key + 1).toString(),
            form.schoolName,
            form.idDinacope,
            form.sousDivision ?? 'N/A',
            form.regimeGestion ?? 'N/A',
            classes.toString(),
            eleves.toString(),
          ];
        }).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  widget.report.title,
                  style: pw.TextStyle(font: boldFont, fontSize: 18),
                ),
              ),
              pw.Table.fromTextArray(
                headers: headers,
                data: data,
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(
                  font: boldFont,
                  fontWeight: pw.FontWeight.bold,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellStyle: pw.TextStyle(font: font),
                cellAlignments: {
                  0: pw.Alignment.center,
                  5: pw.Alignment.centerRight,
                  6: pw.Alignment.centerRight,
                },
              ),
              pw.Divider(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  '',
                  '',
                  '',
                  '',
                  'TOTAL',
                  widget.report.summary['totalClasses'].toString(),
                  widget.report.summary['totalEleves'].toString(),
                ],
                data: [],
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(
                  font: boldFont,
                  fontWeight: pw.FontWeight.bold,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                cellAlignments: {
                  5: pw.Alignment.centerRight,
                  6: pw.Alignment.centerRight,
                },
              ),
            ],
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report.title),
        actions: [
          // Bouton d'impression dans l'AppBar, activé seulement si les données sont chargées
          FutureBuilder<List<ST2Model>>(
            future: _formsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.print_outlined),
                  onPressed: () => _printReport(snapshot.data!),
                  tooltip: 'Imprimer le rapport',
                );
              }
              return const SizedBox.shrink(); // N'affiche rien sinon
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ST2Model>>(
        future: _formsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erreur de chargement des formulaires : ${snapshot.error}",
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Les formulaires associés à ce rapport n'ont pas été trouvés.",
              ),
            );
          }

          final forms = snapshot.data!;
          // On réutilise la même structure de DataTable que dans la page de génération
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                border: TableBorder.all(color: Theme.of(context).dividerColor),
                headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Theme.of(context).splashColor,
                ),
                columns: const [
                  DataColumn(label: Text('N°')),
                  DataColumn(label: Text('ÉTABLISSEMENT')),
                  DataColumn(label: Text('ID DINACOPE')),
                  DataColumn(label: Text('SOUS-DIVISION')),
                  DataColumn(label: Text('RÉGIME')),
                  DataColumn(label: Text('CLASSES')),
                  DataColumn(label: Text('ÉLÈVES')),
                ],
                rows: [
                  ...forms.asMap().entries.map((entry) {
                    final form = entry.value;
                    final classes = form.classesOrganisees.values.fold(
                      0,
                      (sum, i) => sum + i,
                    );
                    final eleves = form.effectifsEleves.values.fold(
                      0,
                      (s, map) =>
                          s + (map['garcons'] ?? 0) + (map['filles'] ?? 0),
                    );
                    return DataRow(
                      cells: [
                        DataCell(Text((entry.key + 1).toString())),
                        DataCell(Text(form.schoolName)),
                        DataCell(Text(form.idDinacope)),
                        DataCell(Text(form.sousDivision ?? '')),
                        DataCell(Text(form.regimeGestion ?? '')),
                        DataCell(
                          Text(classes.toString(), textAlign: TextAlign.right),
                        ),
                        DataCell(
                          Text(eleves.toString(), textAlign: TextAlign.right),
                        ),
                      ],
                    );
                  }).toList(),
                  DataRow(
                    color: MaterialStateColor.resolveWith(
                      (states) => Theme.of(context).hoverColor,
                    ),
                    cells: [
                      const DataCell(
                        Text(
                          'TOTAL',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      DataCell(
                        Text(
                          widget.report.summary['totalClasses'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      DataCell(
                        Text(
                          widget.report.summary['totalEleves'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
