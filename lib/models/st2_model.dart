import 'package:cloud_firestore/cloud_firestore.dart';

class ST2FormModel {
  // Page 1 - Identité
  final String uid;
  final String nomEts;
  final String adresseEts;
  final String nomChef;
  final String telChef;
  final String periode;
  final String province;
  final String ville;
  final String territoire;
  final String provinceEduc;
  final String sousDivision;
  final String regime;
  final String refJuridique;
  final String matriculeSecope;
  final String mecanisation;

  // Page 2 - Infrastructure
  final bool hasProgrammes;
  final bool hasCOPA;
  final bool copaOp;
  final int nbFemmesCOPA;
  final bool hasCOGES;
  final bool cogesOp;
  final int nbReunionCOGES;
  final int nbFemmesCOGES;
  final bool hasEau;
  final bool eauRobinet, eauForage, eauSource;
  final bool hasEnergie;
  final bool elec, solaire, groupe;
  final bool hasLatrines;
  final int nbLatrines;
  final int nbFillesLatrines;
  final bool hasBudget;
  final bool hasPlanAction;
  final int nbEnsFormes;
  final int nbEnsPositifs;
  final int nbEnsInspectes;

  // Page 3 - Pédagogie
  final String niveauEcole;
  final int nbEnseignants;
  final Map<String, int> classesAutorisees;
  final Map<String, int> classesOrganisees;
  final Map<String, int> effectifGarcons;
  final Map<String, int> effectifFilles;
  final List<Map<String, dynamic>> enseignants;

  // Page 4 - Ressources
  final Map<String, Map<String, int>> manuelsParAnnee;
  final Map<String, int> equipementsBons;
  final Map<String, int> equipementsMauvais;

  // Timestamp
  final DateTime? createdAt;

  ST2FormModel({
    required this.uid,
    required this.nomEts,
    required this.adresseEts,
    required this.nomChef,
    required this.telChef,
    required this.periode,
    required this.province,
    required this.ville,
    required this.territoire,
    required this.provinceEduc,
    required this.sousDivision,
    required this.regime,
    required this.refJuridique,
    required this.matriculeSecope,
    required this.mecanisation,
    this.hasProgrammes = false,
    this.hasCOPA = false,
    this.copaOp = false,
    this.nbFemmesCOPA = 0,
    this.hasCOGES = false,
    this.cogesOp = false,
    this.nbReunionCOGES = 0,
    this.nbFemmesCOGES = 0,
    this.hasEau = false,
    this.eauRobinet = false,
    this.eauForage = false,
    this.eauSource = false,
    this.hasEnergie = false,
    this.elec = false,
    this.solaire = false,
    this.groupe = false,
    this.hasLatrines = false,
    this.nbLatrines = 0,
    this.nbFillesLatrines = 0,
    this.hasBudget = false,
    this.hasPlanAction = false,
    this.nbEnsFormes = 0,
    this.nbEnsPositifs = 0,
    this.nbEnsInspectes = 0,
    required this.niveauEcole,
    required this.nbEnseignants,
    required this.classesAutorisees,
    required this.classesOrganisees,
    required this.effectifGarcons,
    required this.effectifFilles,
    required this.enseignants,
    required this.manuelsParAnnee,
    required this.equipementsBons,
    required this.equipementsMauvais,
    this.createdAt,
  }) {
    // Validation à la création
    final errors = validate();
    if (errors.isNotEmpty) {
      throw FormatException(errors.join('\n'));
    }
  }

  /// Valide le modèle et retourne les erreurs
  List<String> validate() {
    final errors = <String>[];

    // Validation des champs obligatoires
    if (nomEts.isEmpty) errors.add("Le nom de l'établissement est requis");
    if (nomChef.isEmpty) errors.add("Le nom du chef est requis");
    if (telChef.length != 12) errors.add("Le téléphone doit avoir 12 chiffres");
    if (niveauEcole.isEmpty) errors.add("Le niveau de l'école est requis");

    // Validation des nombres
    if (nbFemmesCOPA < 0) errors.add("Nombre de femmes COPA invalide");
    if (nbLatrines < 0) errors.add("Nombre de latrines invalide");

    return errors;
  }

  /// Convertit vers Firestore avec typage correct
  Map<String, dynamic> toFirestore() {
    return {
      // Page 1
      'uid': uid,
      'nomEts': nomEts,
      'adresseEts': adresseEts,
      'nomChef': nomChef,
      'telChef': telChef,
      'periode': periode,
      'province': province,
      'ville': ville,
      'territoire': territoire,
      'provinceEduc': provinceEduc,
      'sousDivision': sousDivision,
      'regime': regime,
      'refJuridique': refJuridique,
      'matriculeSecope': matriculeSecope,
      'mecanisation': mecanisation,

      // Page 2
      'hasProgrammes': hasProgrammes,
      'hasCOPA': hasCOPA,
      'copaOp': copaOp,
      'nbFemmesCOPA': nbFemmesCOPA,
      'hasCOGES': hasCOGES,
      'cogesOp': cogesOp,
      'nbReunionCOGES': nbReunionCOGES,
      'nbFemmesCOGES': nbFemmesCOGES,
      'hasEau': hasEau,
      'eauRobinet': eauRobinet,
      'eauForage': eauForage,
      'eauSource': eauSource,
      'hasEnergie': hasEnergie,
      'elec': elec,
      'solaire': solaire,
      'groupe': groupe,
      'hasLatrines': hasLatrines,
      'nbLatrines': nbLatrines,
      'nbFillesLatrines': nbFillesLatrines,
      'hasBudget': hasBudget,
      'hasPlanAction': hasPlanAction,
      'nbEnsFormes': nbEnsFormes,
      'nbEnsPositifs': nbEnsPositifs,
      'nbEnsInspectes': nbEnsInspectes,

      // Page 3
      'niveauEcole': niveauEcole,
      'nbEnseignants': nbEnseignants,
      'classesAutorisees': classesAutorisees,
      'classesOrganisees': classesOrganisees,
      'effectifGarcons': effectifGarcons,
      'effectifFilles': effectifFilles,
      'enseignants': enseignants,

      // Page 4
      'manuelsParAnnee': manuelsParAnnee,
      'equipementsBons': equipementsBons,
      'equipementsMauvais': equipementsMauvais,
    };
  }

  /// Factory pour créer un modèle depuis Firestore
  factory ST2FormModel.fromFirestore(Map<String, dynamic> data) {
    return ST2FormModel(
      uid: data['uid'] as String? ?? '',
      nomEts: data['nomEts'] as String? ?? '',
      adresseEts: data['adresseEts'] as String? ?? '',
      nomChef: data['nomChef'] as String? ?? '',
      telChef: data['telChef'] as String? ?? '',
      periode: data['periode'] as String? ?? '',
      province: data['province'] as String? ?? '',
      ville: data['ville'] as String? ?? '',
      territoire: data['territoire'] as String? ?? '',
      provinceEduc: data['provinceEduc'] as String? ?? '',
      sousDivision: data['sousDivision'] as String? ?? '',
      regime: data['regime'] as String? ?? '',
      refJuridique: data['refJuridique'] as String? ?? '',
      matriculeSecope: data['matriculeSecope'] as String? ?? '',
      mecanisation: data['mecanisation'] as String? ?? '',
      hasProgrammes: data['hasProgrammes'] as bool? ?? false,
      hasCOPA: data['hasCOPA'] as bool? ?? false,
      copaOp: data['copaOp'] as bool? ?? false,
      nbFemmesCOPA: (data['nbFemmesCOPA'] as num?)?.toInt() ?? 0,
      hasCOGES: data['hasCOGES'] as bool? ?? false,
      cogesOp: data['cogesOp'] as bool? ?? false,
      nbReunionCOGES: (data['nbReunionCOGES'] as num?)?.toInt() ?? 0,
      nbFemmesCOGES: (data['nbFemmesCOGES'] as num?)?.toInt() ?? 0,
      hasEau: data['hasEau'] as bool? ?? false,
      eauRobinet: data['eauRobinet'] as bool? ?? false,
      eauForage: data['eauForage'] as bool? ?? false,
      eauSource: data['eauSource'] as bool? ?? false,
      hasEnergie: data['hasEnergie'] as bool? ?? false,
      elec: data['elec'] as bool? ?? false,
      solaire: data['solaire'] as bool? ?? false,
      groupe: data['groupe'] as bool? ?? false,
      hasLatrines: data['hasLatrines'] as bool? ?? false,
      nbLatrines: (data['nbLatrines'] as num?)?.toInt() ?? 0,
      nbFillesLatrines: (data['nbFillesLatrines'] as num?)?.toInt() ?? 0,
      hasBudget: data['hasBudget'] as bool? ?? false,
      hasPlanAction: data['hasPlanAction'] as bool? ?? false,
      nbEnsFormes: (data['nbEnsFormes'] as num?)?.toInt() ?? 0,
      nbEnsPositifs: (data['nbEnsPositifs'] as num?)?.toInt() ?? 0,
      nbEnsInspectes: (data['nbEnsInspectes'] as num?)?.toInt() ?? 0,
      niveauEcole: data['niveauEcole'] as String? ?? '',
      nbEnseignants: (data['nbEnseignants'] as num?)?.toInt() ?? 0,
      classesAutorisees: Map<String, int>.from(
        (data['classesAutorisees'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
      ),
      classesOrganisees: Map<String, int>.from(
        (data['classesOrganisees'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
      ),
      effectifGarcons: Map<String, int>.from(
        (data['effectifGarcons'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
      ),
      effectifFilles: Map<String, int>.from(
        (data['effectifFilles'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
      ),
      enseignants: List<Map<String, dynamic>>.from(
        data['enseignants'] as List? ?? [],
      ),
      manuelsParAnnee: Map<String, Map<String, int>>.from(
        (data['manuelsParAnnee'] as Map? ?? {}).map(
          (k, v) => MapEntry(
            k.toString(),
            Map<String, int>.from(
              (v as Map).map(
                (k2, v2) => MapEntry(k2.toString(), (v2 as num).toInt()),
              ),
            ),
          ),
        ),
      ),
      equipementsBons: Map<String, int>.from(
        (data['equipementsBons'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
      ),
      equipementsMauvais: Map<String, int>.from(
        (data['equipementsMauvais'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
