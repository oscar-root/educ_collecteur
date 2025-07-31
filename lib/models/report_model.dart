// lib/models/report_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String? id;
  final String title;
  final DateTime? generatedAt;
  final String generatedByUid;
  final String filterType; // ex: 'regimeGestion'
  final String filterValue; // ex: 'Catholique'
  final Map<String, dynamic>
  summary; // ex: {'totalEtablissements': 10, 'totalClasses': 50, 'totalEleves': 1200}
  final List<String> formIds; // Liste des IDs des formulaires ST2 inclus

  ReportModel({
    this.id,
    required this.title,
    this.generatedAt,
    required this.generatedByUid,
    required this.filterType,
    required this.filterValue,
    required this.summary,
    required this.formIds,
  });

  // Convertit l'objet Dart en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'generatedAt': FieldValue.serverTimestamp(), // Firestore gère la date
      'generatedByUid': generatedByUid,
      'filterType': filterType,
      'filterValue': filterValue,
      'summary': summary,
      'formIds': formIds,
    };
  }

  // Crée un objet ReportModel à partir d'un document Firestore
  factory ReportModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ReportModel(
      id: doc.id,
      title: data['title'] ?? '',
      generatedAt: (data['generatedAt'] as Timestamp?)?.toDate(),
      generatedByUid: data['generatedByUid'] ?? '',
      filterType: data['filterType'] ?? '',
      filterValue: data['filterValue'] ?? '',
      summary: Map<String, dynamic>.from(data['summary'] ?? {}),
      formIds: List<String>.from(data['formIds'] ?? []),
    );
  }
}
