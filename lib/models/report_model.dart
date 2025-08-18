// lib/models/report_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educ_collecteur/models/st2_model.dart';

class ReportModel {
  /// L'ID du document du rapport dans Firestore.
  final String? id;

  /// Le titre du rapport (ex: "Rapport Global - Kamina 1").
  final String title;

  /// Une description textuelle des critères utilisés pour générer le rapport.
  final String criteria;

  /// La date à laquelle le rapport a été généré et sauvegardé.
  final DateTime createdAt;

  /// La liste complète des données des formulaires ST2 inclus dans ce rapport.
  /// C'est la donnée principale, stockée directement dans le document.
  final List<ST2Model> formsData;

  ReportModel({
    this.id,
    required this.title,
    required this.criteria,
    required this.createdAt,
    required this.formsData,
  });

  /// Crée un objet ReportModel à partir d'un DocumentSnapshot de Firestore.
  factory ReportModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    // On prend la liste de Maps depuis Firestore...
    final formsDataAsMaps = data['formsData'] as List<dynamic>? ?? [];

    // ...et on la convertit en une liste d'objets ST2Model grâce à notre nouvelle méthode `fromMap`.
    final formsDataAsModels = formsDataAsMaps
        .map((formDataMap) =>
            ST2Model.fromMap(formDataMap as Map<String, dynamic>))
        .toList();

    return ReportModel(
      id: doc.id,
      title: data['title'] ?? 'Rapport sans titre',
      criteria: data['criteria'] ?? 'Aucun critère',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      formsData: formsDataAsModels,
    );
  }

  /// Convertit l'objet ReportModel en une Map pour le stockage dans Firestore.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'criteria': criteria,
      'createdAt': Timestamp.fromDate(createdAt),
      // On convertit notre liste d'objets ST2Model en une liste de Maps simples.
      'formsData': formsData.map((form) => form.toMapForReport()).toList(),
    };
  }
}
