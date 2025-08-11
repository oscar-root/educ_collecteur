// lib/views/dashboard/report_generation_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:educ_collecteur/models/st2_model.dart';
import 'package:educ_collecteur/models/report_model.dart';

class ReportGenerationPage extends StatefulWidget {
  const ReportGenerationPage({super.key});

  @override
  State<ReportGenerationPage> createState() => _ReportGenerationPageState();
}

class _ReportGenerationPageState extends State<ReportGenerationPage> {
  String? _selectedFilterType;
  String? _selectedFilterValue;

  List<String> _valueOptions = [];
  bool _isLoadingOptions = false;
  bool _isLoadingReport = false;

  // Le DataSource pour notre PaginatedDataTable
  _ReportDataSource? _reportDataSource;

  final Map<String, String> _filterOptions = {
    'regimeGestion': 'Régime de Gestion',
    'sousDivision': 'Sous-division',
    'schoolName': 'Établissement',
  };

  // ... (Les méthodes _loadFilterOptions, _saveReportToFirebase, _printReport restent inchangées) ...
  Future<void> _loadFilterOptions(String filterType) async {
    setState(() {
      _isLoadingOptions = true;
      _valueOptions = [];
      _selectedFilterValue = null;
      _reportDataSource = null;
    });
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('st2_forms').get();
      final forms = snapshot.docs
          .map((doc) => ST2Model.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      final Set<String> options = {};
      for (var form in forms) {
        String? value;
        switch (filterType) {
          case 'regimeGestion':
            value = form.regimeGestion;
            break;
          case 'sousDivision':
            value = form.sousDivision;
            break;
          case 'schoolName':
            value = form.schoolName;
            break;
        }
        if (value != null && value.isNotEmpty) {
          options.add(value);
        }
      }
      setState(() {
        _valueOptions = options.toList()..sort();
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Erreur de chargement des options: $e"),
            backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoadingOptions = false);
    }
  }

  Future<void> _saveReportToFirebase() async {
    if (_reportDataSource == null ||
        _selectedFilterType == null ||
        _selectedFilterValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Aucune donnée de rapport à enregistrer."),
          backgroundColor: Colors.orange));
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Utilisateur non connecté."),
          backgroundColor: Colors.red));
      return;
    }
    final totalClasses = _reportDataSource!._data.fold(
        0,
        (sum, form) =>
            sum + form.classesOrganisees.values.fold(0, (s, i) => s + i));
    final totalEleves = _reportDataSource!._data.fold(
        0,
        (sum, form) =>
            sum +
            form.effectifsEleves.values.fold(0,
                (s, map) => s + (map['garcons'] ?? 0) + (map['filles'] ?? 0)));
    final formIds = _reportDataSource!._data.map((form) => form.id!).toList();
    final report = ReportModel(
        title:
            "Rapport: ${_filterOptions[_selectedFilterType!]} - $_selectedFilterValue",
        generatedByUid: user.uid,
        filterType: _selectedFilterType!,
        filterValue: _selectedFilterValue!,
        summary: {
          'totalEtablissements': _reportDataSource!._data.length,
          'totalClasses': totalClasses,
          'totalEleves': totalEleves
        },
        formIds: formIds);
    try {
      await FirebaseFirestore.instance
          .collection('generated_reports')
          .add(report.toMap());
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Rapport enregistré avec succès !"),
            backgroundColor: Colors.green));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Erreur lors de l'enregistrement : $e"),
            backgroundColor: Colors.red));
    }
  }

  Future<void> _printReport() async {
    if (_reportDataSource == null) return;
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
      'ÉLÈVES'
    ];
    int totalClasses = 0;
    int totalEleves = 0;
    final data = _reportDataSource!._data.map((form) {
      final classes =
          form.classesOrganisees.values.fold(0, (sum, item) => sum + item);
      final eleves = form.effectifsEleves.values.fold(0,
          (sum, item) => sum + (item['garcons'] ?? 0) + (item['filles'] ?? 0));
      totalClasses += classes;
      totalEleves += eleves;
      return [
        (_reportDataSource!._data.indexOf(form) + 1).toString(),
        form.schoolName,
        form.idDinacope,
        form.sousDivision ?? 'N/A',
        form.regimeGestion ?? 'N/A',
        classes.toString(),
        eleves.toString()
      ];
    }).toList();
    doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
              pw.Header(
                  level: 0,
                  child: pw.Text(
                      "RAPPORT ANALYTIQUE PAR : ${_filterOptions[_selectedFilterType!]!.toUpperCase()} (${_selectedFilterValue!})",
                      style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 18,
                          decoration: pw.TextDecoration.underline))),
              pw.Table.fromTextArray(
                  headers: headers,
                  data: data,
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(
                      font: boldFont, fontWeight: pw.FontWeight.bold),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey300),
                  cellStyle: pw.TextStyle(font: font),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellAlignments: {
                    0: pw.Alignment.center,
                    5: pw.Alignment.centerRight,
                    6: pw.Alignment.centerRight
                  }),
              pw.Divider(height: 20),
              pw.Table.fromTextArray(
                  headers: [
                    '',
                    '',
                    '',
                    '',
                    'TOTAL',
                    totalClasses.toString(),
                    totalEleves.toString()
                  ],
                  data: [],
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(
                      font: boldFont, fontWeight: pw.FontWeight.bold),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey200),
                  cellAlignments: {
                    5: pw.Alignment.centerRight,
                    6: pw.Alignment.centerRight
                  })
            ]));
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  Future<void> _generateReportData() async {
    if (_selectedFilterType == null || _selectedFilterValue == null) return;

    setState(() {
      _isLoadingReport = true;
      _reportDataSource = null;
    });

    try {
      final query = FirebaseFirestore.instance
          .collection('st2_forms')
          .where(_selectedFilterType!, isEqualTo: _selectedFilterValue);
      final snapshot = await query.get();
      final forms = snapshot.docs
          .map((doc) => ST2Model.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      setState(() {
        _reportDataSource = _ReportDataSource(forms);
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Erreur de génération du rapport: $e"),
            backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoadingReport = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Génération de Rapport")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilterSelection(),
            const SizedBox(height: 24),
            _buildReportDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Configuration du Rapport",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedFilterType,
              hint: const Text("1. Choisir un critère"),
              items: _filterOptions.entries
                  .map((entry) => DropdownMenuItem(
                      value: entry.key, child: Text(entry.value)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _loadFilterOptions(value);
                  setState(() => _selectedFilterType = value);
                }
              },
              decoration:
                  const InputDecoration(prefixIcon: Icon(Icons.filter_list)),
            ),
            const SizedBox(height: 16),
            if (_isLoadingOptions)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator())),
            if (_selectedFilterType != null && !_isLoadingOptions)
              DropdownButtonFormField<String>(
                value: _selectedFilterValue,
                hint: const Text("2. Choisir une valeur"),
                items: _valueOptions
                    .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedFilterValue = value),
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.arrow_drop_down_circle_outlined)),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.analytics_outlined),
              label: const Text("AFFICHER LE RAPPORT"),
              onPressed:
                  (_selectedFilterValue != null) ? _generateReportData : null,
            ),
          ],
        ),
      ),
    );
  }

  // --- NOUVELLE SECTION D'AFFICHAGE UTILISANT PAGINATEDDATATABLE ---
  Widget _buildReportDisplay() {
    if (_isLoadingReport) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_reportDataSource == null) {
      return Card(
        elevation: 0,
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
              child: Text("Veuillez sélectionner un critère pour commencer.")),
        ),
      );
    }
    if (_reportDataSource!.rowCount == 0) {
      return const Card(
        elevation: 2,
        child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
                child: Text("Aucun formulaire trouvé pour ce critère."))),
      );
    }

    // Le PaginatedDataTable doit être dans un widget qui occupe toute la largeur
    return SizedBox(
      width: double.infinity,
      child: PaginatedDataTable(
        header: Text("Rapport pour : $_selectedFilterValue"),
        actions: [
          IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: _saveReportToFirebase,
              tooltip: "Enregistrer"),
          IconButton(
              icon: const Icon(Icons.print_outlined),
              onPressed: _printReport,
              tooltip: "Imprimer (PDF)"),
        ],
        columns: const [
          DataColumn(label: Text('ÉTABLISSEMENT')),
          DataColumn(label: Text('ID DINACOPE')),
          DataColumn(label: Text('SOUS-DIVISION')),
          DataColumn(label: Text('RÉGIME')),
          DataColumn(label: Text('CLASSES'), numeric: true),
          DataColumn(label: Text('ÉLÈVES'), numeric: true),
        ],
        source: _reportDataSource!,
        rowsPerPage: 10,
        showCheckboxColumn: false,
        columnSpacing: 20, // Ajustez l'espacement
      ),
    );
  }
}

// --- NOUVELLE CLASSE DATASOURCE POUR PAGINATEDDATATABLE ---
class _ReportDataSource extends DataTableSource {
  final List<ST2Model> _data;
  _ReportDataSource(this._data);

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
        DataCell(Text(form.sousDivision ?? '')),
        DataCell(Text(form.regimeGestion ?? '')),
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
