// lib/services/pdf_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import 'package:printing/printing.dart';
import 'package:educ_collecteur/models/st2_model.dart';

class PdfService {
  /// Tâche 1: Génère un rapport PDF et le présente pour une EXPORTATION/TÉLÉCHARGEMENT direct.
  Future<void> generateAndExportPdf({
    required String title,
    required List<ST2Model> forms,
  }) async {
    try {
      final Uint8List pdfBytes =
          await _generatePdfData(title: title, forms: forms);
      final fileName =
          '${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await _exportPdf(pdfBytes, fileName);
    } catch (e) {
      print("Erreur lors de l'exportation du PDF: $e");
      throw Exception("Erreur d'exportation PDF: $e");
    }
  }

  /// Tâche 2: Génère un rapport PDF et ouvre la boîte de dialogue d'IMPRESSION.
  Future<void> generateAndPrintPdf({
    required String title,
    required List<ST2Model> forms,
  }) async {
    try {
      final Uint8List pdfBytes =
          await _generatePdfData(title: title, forms: forms);
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes, name: title);
    } catch (e) {
      print("Erreur lors de l'impression du PDF: $e");
      throw Exception("Erreur d'impression PDF: $e");
    }
  }

  /// Méthode privée et centralisée pour générer les données du PDF.
  Future<Uint8List> _generatePdfData({
    required String title,
    required List<ST2Model> forms,
  }) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
    final fontBoldData = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");
    final ttf = pw.Font.ttf(fontData);
    final ttfBold = pw.Font.ttf(fontBoldData);
    final logoImage = pw.MemoryImage(
        (await rootBundle.load('assets/images/logoeduc.png'))
            .buffer
            .asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.symmetric(vertical: 40, horizontal: 32),
        header: (context) => _buildHeader(logoImage, ttf),
        footer: (context) => _buildFooter(ttf, context),
        build: (context) => [
          pw.Header(
              level: 0,
              child: pw.Center(
                  child: pw.Text(title.toUpperCase(),
                      style: pw.TextStyle(font: ttfBold, fontSize: 16)))),
          pw.SizedBox(height: 20),
          // CORRECTION: L'appel à la méthode qui manquait est maintenant valide.
          _buildPdfTable(forms, ttf, ttfBold),
        ],
      ),
    );

    return await pdf.save();
  }

  /// Déclenche le téléchargement sur le web ou ouvre le fichier sur les autres plateformes.
  Future<void> _exportPdf(Uint8List pdfBytes, String fileName) async {
    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/$fileName");
      await file.writeAsBytes(pdfBytes);
      await OpenFile.open(file.path);
    }
  }

  // =========================================================================
  // MÉTHODE QUI MANQUAIT, MAINTENANT RÉINTÉGRÉE
  // =========================================================================
  /// Construit le tableau de données stylisé pour le PDF.
  pw.Widget _buildPdfTable(
      List<ST2Model> forms, pw.Font font, pw.Font fontBold) {
    final headers = [
      'NOM ETABLISSEMENT',
      'REGIME DE GESTION',
      'ID DINACOPE',
      'EFFECTIF ELEVES',
      'EFFECTIFS LIVRES'
    ];
    final data = forms.map((form) {
      final totalEleves =
          form.effectifsEleves.values.fold(0, (sum, item) => sum + item.total);
      final totalLivres = form.manuelsDisponibles.values.fold(
          0, (sum, manuels) => sum + manuels.values.fold(0, (s, i) => s + i));
      return [
        form.schoolName,
        form.regimeGestion ?? 'N/A',
        form.idDinacope,
        totalEleves.toString(),
        totalLivres.toString()
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey700),
      headerStyle:
          pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellStyle: pw.TextStyle(font: font, fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight
      },
      cellPadding: const pw.EdgeInsets.all(5),
    );
  }

  /// Construit l'en-tête de chaque page.
  pw.Widget _buildHeader(pw.MemoryImage logo, pw.Font font) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
          border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey, width: 0.5))),
      padding: const pw.EdgeInsets.only(bottom: 10),
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text("REPUBLIQUE DEMOCRATIQUE DU CONGO",
                style: pw.TextStyle(font: font, fontSize: 10)),
            pw.Text("MINISTERE DE L'EPST",
                style: pw.TextStyle(font: font, fontSize: 10)),
            pw.Text("PROVINCE EDUCATIONNELLE HAUT-LOMAMI 1",
                style: pw.TextStyle(font: font, fontSize: 10)),
          ]),
          pw.SizedBox(height: 50, width: 50, child: pw.Image(logo)),
        ],
      ),
    );
  }

  /// Construit le pied de page de chaque page.
  pw.Widget _buildFooter(pw.Font font, pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
          border:
              pw.Border(top: pw.BorderSide(color: PdfColors.grey, width: 0.5))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
              "Fait à Kamina, le ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
              style: pw.TextStyle(font: font, fontSize: 9)),
          pw.Text("Page ${context.pageNumber} sur ${context.pagesCount}",
              style: pw.TextStyle(font: font, fontSize: 9)),
        ],
      ),
    );
  }
}
