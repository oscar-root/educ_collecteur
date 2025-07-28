import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle pour les données d'un enseignant.
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

  // Convertit l'objet TeacherData en Map pour Firestore
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

  // Crée un objet TeacherData à partir d'une Map (venant de Firestore)
  factory TeacherData.fromMap(Map<String, dynamic> map) {
    return TeacherData(
      nom: map['nom'],
      sexe: map['sexe'],
      matricule: map['matricule'],
      situationSalariale: map['situationSalariale'],
      anneeEngagement: map['anneeEngagement'],
      qualification: map['qualification'],
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
    };
  }

  factory EquipementData.fromMap(Map<String, dynamic> map) {
    return EquipementData(
      type: map['type'],
      enBonEtat: map['enBonEtat'],
      enMauvaisEtat: map['enMauvaisEtat'],
    );
  }
}

/// Modèle principal pour le formulaire ST2.
/// Contient toutes les données collectées.
class ST2Model {
  final String? id; // L'ID du document Firestore
  final String submittedBy; // UID de l'utilisateur
  final DateTime? submittedAt; // Horodatage de la soumission
  final String status;

  // Section: Identification
  final String schoolName;
  final String chefEtablissementName;
  final String? niveauEcole;
  final String adresse;
  final String telephoneChef;
  final String? periode;

  // Section: Localisation
  final String? province;
  final String? provinceEducationnelle;
  final String villeVillage;
  final String? sousDivision;
  final String? regimeGestion;
  final String refJuridique;
  final String idDinacope;
  final String? statutEtablissement;

  // Section: Informations Générales
  final bool? hasProgrammesOfficiels;
  final bool? hasLatrines;
  final int? latrinesTotal;
  final int? latrinesFilles;
  final bool? hasPrevisionsBudgetaires;

  // Section: Données scolaires (spécifiques au niveau)
  final Map<String, int> classesOrganisees;
  final int totalEnseignants;
  final List<TeacherData> enseignants;
  final Map<String, Map<String, int>>
  effectifsEleves; // Ex: {'1ère': {'garcons': 10, 'filles': 12}}
  final Map<String, Map<String, int>>
  manuelsDisponibles; // Ex: {'Français': {'1ère': 20, '2ème': 15}}
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

  /// Convertit l'objet ST2Model en une Map pour Firestore.
  Map<String, dynamic> toMap() {
    return {
      'submittedBy': submittedBy,
      'submittedAt': FieldValue.serverTimestamp(), // Firestore gère la date
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
      'enseignants': enseignants.map((teacher) => teacher.toMap()).toList(),
      'effectifsEleves': effectifsEleves,
      'manuelsDisponibles': manuelsDisponibles,
      'equipements': equipements.map((equip) => equip.toMap()).toList(),
    };
  }

  /// Crée un objet ST2Model à partir d'un DocumentSnapshot de Firestore.
  factory ST2Model.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ST2Model(
      id: doc.id,
      submittedBy: data['submittedBy'],
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
      status: data['status'],
      schoolName: data['schoolName'],
      chefEtablissementName: data['chefEtablissementName'],
      niveauEcole: data['niveauEcole'],
      adresse: data['adresse'],
      telephoneChef: data['telephoneChef'],
      periode: data['periode'],
      province: data['province'],
      provinceEducationnelle: data['provinceEducationnelle'],
      villeVillage: data['villeVillage'],
      sousDivision: data['sousDivision'],
      regimeGestion: data['regimeGestion'],
      refJuridique: data['refJuridique'],
      idDinacope: data['idDinacope'],
      statutEtablissement: data['statutEtablissement'],
      hasProgrammesOfficiels: data['hasProgrammesOfficiels'],
      hasLatrines: data['hasLatrines'],
      latrinesTotal: data['latrinesTotal'],
      latrinesFilles: data['latrinesFilles'],
      hasPrevisionsBudgetaires: data['hasPrevisionsBudgetaires'],
      classesOrganisees: Map<String, int>.from(data['classesOrganisees']),
      totalEnseignants: data['totalEnseignants'],
      enseignants:
          (data['enseignants'] as List<dynamic>?)
              ?.map((e) => TeacherData.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      effectifsEleves: Map<String, Map<String, int>>.from(
        data['effectifsEleves'],
      ),
      manuelsDisponibles: Map<String, Map<String, int>>.from(
        data['manuelsDisponibles'],
      ),
      equipements:
          (data['equipements'] as List<dynamic>?)
              ?.map((e) => EquipementData.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
