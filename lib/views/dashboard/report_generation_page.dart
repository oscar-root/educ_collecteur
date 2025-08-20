// lib/views/dashboard/report_generation_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educ_collecteur/controllers/st2_controller.dart';
import 'package:educ_collecteur/models/st2_model.dart';
import 'package:educ_collecteur/models/report_model.dart';

class ReportGenerationPage extends StatefulWidget {
  const ReportGenerationPage({super.key});
  @override
  State<ReportGenerationPage> createState() => _ReportGenerationPageState();
}

class _ReportGenerationPageState extends State<ReportGenerationPage> {
  final _formKey = GlobalKey<FormState>();
  final ST2Controller _st2Controller = ST2Controller();

  // Variables d'état
  bool _isLoadingSchools = true;
  bool _isSaving = false;

  List<ST2Model> _availableSchools = [];

  // Variables pour les filtres
  String _reportType = 'global';
  ST2Model? _selectedSchool;
  String? _selectedSousDivision;
  String? _selectedRegimeGestion;

  final List<String> _sousDivisions = [
    'Toutes',
    'Kamina 1',
    'Kamina 2',
    'Kamina 3',
    'Kabongo 1',
    'Kabongo 2',
    'Kabongo 3',
    'Kabongo 4',
    'Kaniama 1',
    'Kaniama 2',
    'Kayamba 1',
    'Kayamba 2',
    'Kiondo-Kiambidi'
  ];
  final List<String> _regimesGestion = [
    'Tous',
    'ENC',
    'Catholique',
    'Protestant',
    'ECK',
    'ECI',
    'Privée (EPR)'
  ];

  @override
  void initState() {
    super.initState();
    _fetchSchools();
  }

  Future<void> _fetchSchools() async {
    if (!mounted) return;
    setState(() => _isLoadingSchools = true);
    final schools =
        await _st2Controller.getForms(context: context, status: 'Validé');
    if (mounted) {
      setState(() {
        _availableSchools = schools;
        _isLoadingSchools = false;
      });
    }
  }

  /// Génère un rapport en sauvegardant les données brutes dans Firestore.
  Future<void> _generateAndSaveReport() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      List<ST2Model> formsToReport;
      String reportTitle;
      String criteriaDescription;

      if (_reportType == 'individual') {
        if (_selectedSchool == null) {
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Veuillez sélectionner une école.")));
          setState(() => _isSaving = false);
          return;
        }
        formsToReport = [_selectedSchool!];
        reportTitle = "Rapport Individuel - ${_selectedSchool!.schoolName}";
        criteriaDescription = "École: ${_selectedSchool!.schoolName}";
      } else {
        formsToReport = await _st2Controller.getForms(
            context: context,
            status: 'Validé',
            sousDivision: _selectedSousDivision == 'Toutes'
                ? null
                : _selectedSousDivision,
            regimeGestion: _selectedRegimeGestion == 'Tous'
                ? null
                : _selectedRegimeGestion);
        reportTitle = "Rapport Global (${_selectedSousDivision ?? 'Toutes'})";
        criteriaDescription =
            "Sous-division: ${_selectedSousDivision ?? 'Toutes'}, Régime: ${_selectedRegimeGestion ?? 'Tous'}";
      }

      if (formsToReport.isEmpty) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Aucune donnée trouvée pour ces critères.")));
        setState(() => _isSaving = false);
        return;
      }

      // CRÉATION DE L'OBJET RAPPORT AVEC LES DONNÉES BRUTES
      final report = ReportModel(
        title: reportTitle,
        criteria: criteriaDescription,
        createdAt: DateTime.now(),
        formsData: formsToReport, // On stocke la liste complète des données
      );

      // SAUVEGARDE DU NOUVEAU DOCUMENT DANS LA COLLECTION 'generated_reports'
      await FirebaseFirestore.instance
          .collection('generated_reports')
          .add(report.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Rapport généré et sauvegardé avec succès!"),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Erreur de sauvegarde: $e"),
            backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Type de Rapport",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'global',
                    label: Text('Global'),
                    icon: Icon(Icons.apps)),
                ButtonSegment(
                    value: 'individual',
                    label: Text('Individuel'),
                    icon: Icon(Icons.school)),
              ],
              selected: {_reportType},
              onSelectionChanged: (newSelection) =>
                  setState(() => _reportType = newSelection.first),
            ),
            const SizedBox(height: 24),
            if (_reportType == 'global') ...[
              Text("Critères du Rapport Global",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildDropdown(
                  _sousDivisions,
                  'Toutes les Sous-divisions',
                  _selectedSousDivision,
                  (val) => setState(() => _selectedSousDivision = val)),
              const SizedBox(height: 16),
              _buildDropdown(
                  _regimesGestion,
                  'Tous les Régimes de Gestion',
                  _selectedRegimeGestion,
                  (val) => setState(() => _selectedRegimeGestion = val)),
            ] else ...[
              Text("Sélectionner un Établissement",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _isLoadingSchools
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<ST2Model>(
                      value: _selectedSchool,
                      hint: const Text("Choisir une école"),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      items: _availableSchools
                          .map((school) => DropdownMenuItem(
                              value: school,
                              child: Text(school.schoolName,
                                  overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedSchool = val),
                      validator: (val) =>
                          _reportType == 'individual' && val == null
                              ? 'Veuillez choisir une école.'
                              : null,
                    ),
            ],
            const SizedBox(height: 32),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.save_alt_outlined),
                    label: const Text("Générer et Enregistrer"),
                    onPressed: _generateAndSaveReport,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      textStyle: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String hint, String? selectedValue,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: Text(hint, style: GoogleFonts.poppins()),
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      isExpanded: true,
      items: items
          .map((item) => DropdownMenuItem(
              value: item,
              child: Text(item,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins())))
          .toList(),
      onChanged: onChanged,
    );
  }
}
