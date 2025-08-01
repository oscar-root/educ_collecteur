// lib/views/dashboard/report_detail_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
    _formsFuture = _fetchFormsData();
  }

  Future<List<ST2Model>> _fetchFormsData() async {
    if (widget.report.formIds.isEmpty) return [];
    final querySnapshot = await FirebaseFirestore.instance
        .collection('st2_forms')
        .where(FieldPath.documentId, whereIn: widget.report.formIds)
        .get();
    return querySnapshot.docs
        .map((doc) => ST2Model.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  // La méthode _printReport reste inchangée, elle est déjà correcte.
  Future<void> _printReport(List<ST2Model> forms) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.latoRegular();
    final boldFont = await PdfGoogleFonts.latoBold();
    final italicFont = await PdfGoogleFonts.latoItalic();

    final headers = [
      'N°',
      'ÉTABLISSEMENT',
      'ID DINACOPE',
      'SOUS-DIVISION',
      'RÉGIME',
      'CLASSES',
      'ÉLÈVES'
    ];
    final data = forms.asMap().entries.map((entry) {
      final form = entry.value;
      final classes =
          form.classesOrganisees.values.fold(0, (sum, item) => sum + item);
      final eleves = form.effectifsEleves.values.fold(0,
          (sum, item) => sum + (item['garcons'] ?? 0) + (item['filles'] ?? 0));
      return [
        (entry.key + 1).toString(),
        form.schoolName,
        form.idDinacope,
        form.sousDivision ?? 'N/A',
        form.regimeGestion ?? 'N/A',
        classes.toString(),
        eleves.toString()
      ];
    }).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        footer: (pw.Context context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
                'Édité le : ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(
                    font: italicFont, fontSize: 8, color: PdfColors.grey)),
            pw.Text('Page ${context.pageNumber} sur ${context.pagesCount}',
                style: pw.TextStyle(
                    font: font, fontSize: 8, color: PdfColors.grey)),
          ],
        ),
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text("REPUBLIQUE DEMOCRATIQUE DU CONGO",
                  style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 2),
              pw.Text("MINEDUC.NC/H-L1", style: pw.TextStyle(font: boldFont)),
              pw.SizedBox(height: 24),
              pw.Text(widget.report.title,
                  style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 16,
                      decoration: pw.TextDecoration.underline),
                  textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 24),
            ],
          ),
          pw.Table.fromTextArray(
            headers: headers,
            data: data,
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            headerStyle: pw.TextStyle(
                font: boldFont, fontSize: 10, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
            cellStyle: pw.TextStyle(font: font, fontSize: 9),
            columnWidths: const {
              0: pw.FlexColumnWidth(0.5),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(1.5),
              3: pw.FlexColumnWidth(1.5),
              4: pw.FlexColumnWidth(1.2),
              5: pw.FlexColumnWidth(0.8),
              6: pw.FlexColumnWidth(0.8)
            },
            cellAlignments: {
              0: pw.Alignment.center,
              5: pw.Alignment.centerRight,
              6: pw.Alignment.centerRight
            },
            rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom:
                        pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
            oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 300,
              child: pw.Table.fromTextArray(
                headerCount: 0,
                data: [
                  [
                    'TOTAL CLASSES',
                    widget.report.summary['totalClasses'].toString()
                  ],
                  [
                    'TOTAL ÉLÈVES',
                    widget.report.summary['totalEleves'].toString()
                  ],
                ],
                cellStyle: pw.TextStyle(font: font, fontSize: 10),
                cellAlignments: {1: pw.Alignment.centerRight},
                columnWidths: const {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(1)
                },
                border:
                    pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                headerStyle: pw.TextStyle(
                    font: boldFont, fontWeight: pw.FontWeight.bold),
                rowDecoration:
                    const pw.BoxDecoration(color: PdfColors.blueGrey100),
              ),
            ),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report.title, overflow: TextOverflow.ellipsis),
        actions: [
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
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      // --- CORRECTION FINALE DE L'OVERFLOW ---
      // Le body est maintenant directement le FutureBuilder.
      // Le PaginatedDataTable sera le widget racine à l'intérieur une fois les données chargées,
      // lui permettant d'utiliser tout l'espace vertical du Scaffold.
      body: FutureBuilder<List<ST2Model>>(
        future: _formsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("Erreur de chargement : ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("Les formulaires associés n'ont pas été trouvés."));
          }

          final forms = snapshot.data!;
          // Le PaginatedDataTable est maintenant le widget principal, il ne peut plus déborder.
          return SingleChildScrollView(
            child: PaginatedDataTable(
              header: Text("Détails du Rapport (${forms.length} entrées)"),
              columns: const [
                DataColumn(label: Text('ÉTABLISSEMENT')),
                DataColumn(label: Text('ID DINACOPE')),
                DataColumn(label: Text('CLASSES'), numeric: true),
                DataColumn(label: Text('ÉLÈVES'), numeric: true),
              ],
              source: _ReportDetailDataSource(forms),
              rowsPerPage: 15,
              showCheckboxColumn: false,
              columnSpacing: 20,
            ),
          );
        },
      ),
    );
  }
}

// DataSource pour le PaginatedDataTable (inchangé)
class _ReportDetailDataSource extends DataTableSource {
  final List<ST2Model> _data;
  _ReportDetailDataSource(this._data);

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final form = _data[index];
    final classes =
        form.classesOrganisees.values.fold(0, (sum, item) => sum + item);
    final eleves = form.effectifsEleves.values.fold(
        0, (sum, item) => sum + (item['garcons'] ?? 0) + (item['filles'] ?? 0));

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(form.schoolName)),
        DataCell(Text(form.idDinacope)),
        DataCell(Text(classes.toString())),
        DataCell(Text(eleves.toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;
}
