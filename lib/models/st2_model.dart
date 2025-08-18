// lib/models/st2_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// --- Les modèles TeacherData, EquipementData, et EffectifsData restent inchangés ---
class TeacherData {
  final String nom;
  final String? sexe;
  final String matricule;
  final String? situationSalariale;
  final int? anneeEngagement;
  final String? qualification;

  TeacherData(
      {required this.nom,
      this.sexe,
      required this.matricule,
      this.situationSalariale,
      this.anneeEngagement,
      this.qualification});

  Map<String, dynamic> toMap() => {
        'nom': nom,
        'sexe': sexe,
        'matricule': matricule,
        'situationSalariale': situationSalariale,
        'anneeEngagement': anneeEngagement,
        'qualification': qualification
      };

  factory TeacherData.fromMap(Map<String, dynamic> map) => TeacherData(
      nom: map['nom'],
      sexe: map['sexe'],
      matricule: map['matricule'],
      situationSalariale: map['situationSalariale'],
      anneeEngagement: (map['anneeEngagement'] as num?)?.toInt(),
      qualification: map['qualification']);
}

class EquipementData {
  final String type;
  final int enBonEtat;
  final int enMauvaisEtat;

  EquipementData(
      {required this.type,
      required this.enBonEtat,
      required this.enMauvaisEtat});

  Map<String, dynamic> toMap() => {
        'type': type,
        'enBonEtat': enBonEtat,
        'enMauvaisEtat': enMauvaisEtat,
        'total': enBonEtat + enMauvaisEtat
      };

  factory EquipementData.fromMap(Map<String, dynamic> map) => EquipementData(
      type: map['type'],
      enBonEtat: (map['enBonEtat'] as num).toInt(),
      enMauvaisEtat: (map['enMauvaisEtat'] as num).toInt());
}

class EffectifsData {
  final int garcons;
  final int filles;

  EffectifsData({required this.garcons, required this.filles});
  int get total => garcons + filles;

  Map<String, dynamic> toMap() =>
      {'garcons': garcons, 'filles': filles, 'total': total};
  factory EffectifsData.fromMap(Map<String, dynamic> map) => EffectifsData(
      garcons: (map['garcons'] as num).toInt(),
      filles: (map['filles'] as num).toInt());
}

// --- Le modèle principal ST2Model est mis à jour ---
class ST2Model {
  final String? id;
  final String submittedBy;
  final DateTime? submittedAt;
  final String status;
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
  final Map<String, EffectifsData> effectifsEleves;
  final Map<String, Map<String, int>> manuelsDisponibles;
  final List<EquipementData> equipements;

  ST2Model(
      {this.id,
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
      required this.equipements});

  /// Convertit le modèle en Map pour une **nouvelle création** dans Firestore.
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
      'effectifsEleves':
          effectifsEleves.map((key, value) => MapEntry(key, value.toMap())),
      'manuelsDisponibles': manuelsDisponibles,
      'equipements': equipements.map((e) => e.toMap()).toList(),
    };
  }

  // AJOUTÉ: Convertit le modèle en Map pour être stocké à l'intérieur d'un autre document (rapport).
  Map<String, dynamic> toMapForReport() {
    final map = toMap();
    map.remove('submittedAt'); // On enlève le FieldValue
    map['submittedAt_iso_string'] =
        submittedAt?.toIso8601String(); // On stocke la date en format texte
    return map;
  }

  /// Crée un modèle à partir d'un DocumentSnapshot de Firestore.
  factory ST2Model.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ST2Model.fromMap(data,
        id: doc.id); // On délègue à la nouvelle méthode fromMap
  }

  // AJOUTÉ: Crée un modèle à partir d'une Map simple (et non d'un DocumentSnapshot).
  // C'est la méthode cruciale pour lire les données du rapport.
  factory ST2Model.fromMap(Map<String, dynamic> data, {String? id}) {
    // Tente de parser la date depuis le format ISO string ou depuis un Timestamp
    DateTime? parseSubmittedAt() {
      if (data['submittedAt'] is Timestamp)
        return (data['submittedAt'] as Timestamp).toDate();
      if (data['submittedAt_iso_string'] is String)
        return DateTime.tryParse(data['submittedAt_iso_string']);
      return null;
    }

    return ST2Model(
      id: id,
      submittedBy: data['submittedBy'] ?? '',
      submittedAt: parseSubmittedAt(),
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
      latrinesTotal: (data['latrinesTotal'] as num?)?.toInt(),
      latrinesFilles: (data['latrinesFilles'] as num?)?.toInt(),
      hasPrevisionsBudgetaires: data['hasPrevisionsBudgetaires'],
      totalEnseignants: (data['totalEnseignants'] as num?)?.toInt() ?? 0,
      classesOrganisees: Map<String, int>.from(
          (data['classesOrganisees'] as Map? ?? {})
              .map((k, v) => MapEntry(k.toString(), (v as num).toInt()))),
      enseignants: (data['enseignants'] as List<dynamic>? ?? [])
          .map((e) => TeacherData.fromMap(e as Map<String, dynamic>))
          .toList(),
      equipements: (data['equipements'] as List<dynamic>? ?? [])
          .map((e) => EquipementData.fromMap(e as Map<String, dynamic>))
          .toList(),
      effectifsEleves: (data['effectifsEleves'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(
              key, EffectifsData.fromMap(value as Map<String, dynamic>))),
      manuelsDisponibles:
          (data['manuelsDisponibles'] as Map<String, dynamic>? ?? {}).map(
              (key, value) => MapEntry(
                  key,
                  Map<String, int>.from((value as Map).map(
                      (k, v) => MapEntry(k.toString(), (v as num).toInt()))))),
    );
  }
}
