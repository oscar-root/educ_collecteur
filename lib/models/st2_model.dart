// lib/st2/models/st2_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle pour les données d'un enseignant, correspondant aux champs du formulaire.
class TeacherData {
  final String nom;
  final String? sexe;
  final String matricule;
  final String? situationSalariale;
  final int? anneeEngagement;
  final String? qualification;

  TeacherData({
    required this.nom,
    this.sexe,
    required this.matricule,
    this.situationSalariale,
    this.anneeEngagement,
    this.qualification,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'sexe': sexe,
      'matricule': matricule,
      'situationSalariale': situationSalariale,
      'anneeEngagement': anneeEngagement,
      'qualification': qualification,
    };
  }

  factory TeacherData.fromMap(Map<String, dynamic> map) {
    return TeacherData(
      nom: map['nom'] as String,
      sexe: map['sexe'] as String?,
      matricule: map['matricule'] as String,
      situationSalariale: map['situationSalariale'] as String?,
      anneeEngagement: map['anneeEngagement'] as int?,
      qualification: map['qualification'] as String?,
    );
  }
}

/// Modèle pour les données d'un équipement.
class EquipementData {
  final String type;
  final int enBonEtat;
  final int enMauvaisEtat;

  EquipementData({
    required this.type,
    required this.enBonEtat,
    required this.enMauvaisEtat,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'enBonEtat': enBonEtat,
      'enMauvaisEtat': enMauvaisEtat,
      'total':
          enBonEtat +
          enMauvaisEtat, // Le total est calculé pour un stockage direct
    };
  }

  factory EquipementData.fromMap(Map<String, dynamic> map) {
    return EquipementData(
      type: map['type'] as String,
      enBonEtat: map['enBonEtat'] as int,
      enMauvaisEtat: map['enMauvaisEtat'] as int,
    );
  }
}

/// Modèle principal pour le formulaire ST2.
class ST2Model {
  final String? id;
  final String submittedBy;
  final DateTime? submittedAt;
  final String status;

  // --- Champs du formulaire ---
  final String schoolName;
  final String chefEtablissementName;
  final String? niveauEcole;
  final String adresse;
  final String telephoneChef;
  final String? periode;
  final String? province;
  final String? provinceEducationnelle;
  final String villeVillage;
  final String? sousDivision;
  final String? regimeGestion;
  final String refJuridique;
  final String idDinacope;
  final String? statutEtablissement;
  final bool? hasProgrammesOfficiels;
  final bool? hasLatrines;
  final int? latrinesTotal;
  final int? latrinesFilles;
  final bool? hasPrevisionsBudgetaires;
  final Map<String, int> classesOrganisees;
  final int totalEnseignants;
  final List<TeacherData> enseignants;
  final Map<String, Map<String, int>> effectifsEleves;
  final Map<String, Map<String, int>> manuelsDisponibles;
  final List<EquipementData> equipements;

  ST2Model({
    this.id,
    required this.submittedBy,
    this.submittedAt,
    this.status = 'Soumis',
    required this.schoolName,
    required this.chefEtablissementName,
    this.niveauEcole,
    required this.adresse,
    required this.telephoneChef,
    this.periode,
    this.province,
    this.provinceEducationnelle,
    required this.villeVillage,
    this.sousDivision,
    this.regimeGestion,
    required this.refJuridique,
    required this.idDinacope,
    this.statutEtablissement,
    this.hasProgrammesOfficiels,
    this.hasLatrines,
    this.latrinesTotal,
    this.latrinesFilles,
    this.hasPrevisionsBudgetaires,
    required this.classesOrganisees,
    required this.totalEnseignants,
    required this.enseignants,
    required this.effectifsEleves,
    required this.manuelsDisponibles,
    required this.equipements,
  });

  Map<String, dynamic> toMap() {
    return {
      'submittedBy': submittedBy,
      'submittedAt': FieldValue.serverTimestamp(),
      'status': status,
      'schoolName': schoolName,
      'chefEtablissementName': chefEtablissementName,
      'niveauEcole': niveauEcole,
      'adresse': adresse,
      'telephoneChef': telephoneChef,
      'periode': periode,
      'province': province,
      'provinceEducationnelle': provinceEducationnelle,
      'villeVillage': villeVillage,
      'sousDivision': sousDivision,
      'regimeGestion': regimeGestion,
      'refJuridique': refJuridique,
      'idDinacope': idDinacope,
      'statutEtablissement': statutEtablissement,
      'hasProgrammesOfficiels': hasProgrammesOfficiels,
      'hasLatrines': hasLatrines,
      'latrinesTotal': latrinesTotal,
      'latrinesFilles': latrinesFilles,
      'hasPrevisionsBudgetaires': hasPrevisionsBudgetaires,
      'classesOrganisees': classesOrganisees,
      'totalEnseignants': totalEnseignants,
      'enseignants': enseignants.map((t) => t.toMap()).toList(),
      'effectifsEleves': effectifsEleves,
      'manuelsDisponibles': manuelsDisponibles,
      'equipements': equipements.map((e) => e.toMap()).toList(),
    };
  }

  factory ST2Model.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null)
      throw StateError('Document Firestore vide pour l\'ID: ${doc.id}');

    return ST2Model(
      id: doc.id,
      submittedBy: data['submittedBy'] ?? '',
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'Inconnu',
      schoolName: data['schoolName'] ?? '',
      chefEtablissementName: data['chefEtablissementName'] ?? '',
      niveauEcole: data['niveauEcole'],
      adresse: data['adresse'] ?? '',
      telephoneChef: data['telephoneChef'] ?? '',
      periode: data['periode'],
      province: data['province'],
      provinceEducationnelle: data['provinceEducationnelle'],
      villeVillage: data['villeVillage'] ?? '',
      sousDivision: data['sousDivision'],
      regimeGestion: data['regimeGestion'],
      refJuridique: data['refJuridique'] ?? '',
      idDinacope: data['idDinacope'] ?? '',
      statutEtablissement: data['statutEtablissement'],
      hasProgrammesOfficiels: data['hasProgrammesOfficiels'],
      hasLatrines: data['hasLatrines'],
      latrinesTotal: data['latrinesTotal'],
      latrinesFilles: data['latrinesFilles'],
      hasPrevisionsBudgetaires: data['hasPrevisionsBudgetaires'],
      totalEnseignants: data['totalEnseignants'] ?? 0,
      classesOrganisees: Map<String, int>.from(data['classesOrganisees'] ?? {}),
      enseignants:
          (data['enseignants'] as List<dynamic>?)
              ?.map((e) => TeacherData.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      equipements:
          (data['equipements'] as List<dynamic>?)
              ?.map((e) => EquipementData.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      effectifsEleves:
          (data['effectifsEleves'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Map<String, int>.from(value as Map)),
          ) ??
          {},
      manuelsDisponibles:
          (data['manuelsDisponibles'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Map<String, int>.from(value as Map)),
          ) ??
          {},
    );
  }
}
