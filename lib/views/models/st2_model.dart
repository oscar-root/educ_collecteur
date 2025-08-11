// TODO Implement this library.
class ST2FormModel {
  final String uid;
  final String nomEts;
  final String adresseEts;
  final String nomChef;
  final String telChef;
  final String periode;
  final String province;
  final String ville;
  final String territoire;
  final String village;
  final String provinceEduc;
  final String sousDivision;
  final String regime;
  final String refJuridique;
  final String matriculeSecope;
  final String mecanisation;

  // Page 2
  final bool hasProgrammes;
  final bool hasCOPA;
  final bool copaOp;
  final String nbReunionCOPA;
  final String nbFemmesCOPA;
  final bool hasCOGES;
  final bool cogesOp;
  final String nbReunionCOGES;
  final String nbFemmesCOGES;
  final bool hasLatrines;
  final String nbLatrines;
  final String nbFillesLatrines;
  final String nbEnsFormes;
  final String nbEnsPositifs;
  final String nbEnsInspectes;
  final bool hasGovEleves;

  // Page 3
  final String niveauEcole;
  final Map<String, String> classesAutorisees;
  final Map<String, String> classesOrganisees;
  final String nbEnseignants;
  final List<Map<String, dynamic>> enseignants;
  final Map<String, String> effectifGarcons;
  final Map<String, String> effectifFilles;

  // Page 4
  final Map<String, Map<String, String>> manuelsParAnnee;
  final Map<String, String> bonsEtats;
  final Map<String, String> mauvaisEtats;

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
    required this.village,
    required this.provinceEduc,
    required this.sousDivision,
    required this.regime,
    required this.refJuridique,
    required this.matriculeSecope,
    required this.mecanisation,
    required this.hasProgrammes,
    required this.hasCOPA,
    required this.copaOp,
    required this.nbReunionCOPA,
    required this.nbFemmesCOPA,
    required this.hasCOGES,
    required this.cogesOp,
    required this.nbReunionCOGES,
    required this.nbFemmesCOGES,
    required this.hasLatrines,
    required this.nbLatrines,
    required this.nbFillesLatrines,
    required this.nbEnsFormes,
    required this.nbEnsPositifs,
    required this.nbEnsInspectes,
    required this.hasGovEleves,
    required this.niveauEcole,
    required this.classesAutorisees,
    required this.classesOrganisees,
    required this.nbEnseignants,
    required this.enseignants,
    required this.effectifGarcons,
    required this.effectifFilles,
    required this.manuelsParAnnee,
    required this.bonsEtats,
    required this.mauvaisEtats,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nomEts': nomEts,
      'adresseEts': adresseEts,
      'nomChef': nomChef,
      'telChef': telChef,
      'periode': periode,
      'province': province,
      'ville': ville,
      'territoire': territoire,
      'village': village,
      'provinceEduc': provinceEduc,
      'sousDivision': sousDivision,
      'regime': regime,
      'refJuridique': refJuridique,
      'matriculeSecope': matriculeSecope,
      'mecanisation': mecanisation,
      'hasProgrammes': hasProgrammes,
      'hasCOPA': hasCOPA,
      'copaOp': copaOp,
      'nbReunionCOPA': nbReunionCOPA,
      'nbFemmesCOPA': nbFemmesCOPA,
      'hasCOGES': hasCOGES,
      'cogesOp': cogesOp,
      'nbReunionCOGES': nbReunionCOGES,
      'nbFemmesCOGES': nbFemmesCOGES,
      'hasLatrines': hasLatrines,
      'nbLatrines': nbLatrines,
      'nbFillesLatrines': nbFillesLatrines,
      'nbEnsFormes': nbEnsFormes,
      'nbEnsPositifs': nbEnsPositifs,
      'nbEnsInspectes': nbEnsInspectes,
      'hasGovEleves': hasGovEleves,
      'niveauEcole': niveauEcole,
      'classesAutorisees': classesAutorisees,
      'classesOrganisees': classesOrganisees,
      'nbEnseignants': nbEnseignants,
      'enseignants': enseignants,
      'effectifGarcons': effectifGarcons,
      'effectifFilles': effectifFilles,
      'manuelsParAnnee': manuelsParAnnee,
      'bonsEtats': bonsEtats,
      'mauvaisEtats': mauvaisEtats,
    };
  }

  factory ST2FormModel.fromMap(Map<String, dynamic> data) {
    return ST2FormModel(
      uid: data['uid'] ?? '',
      nomEts: data['nomEts'] ?? '',
      adresseEts: data['adresseEts'] ?? '',
      nomChef: data['nomChef'] ?? '',
      telChef: data['telChef'] ?? '',
      periode: data['periode'] ?? '',
      province: data['province'] ?? '',
      ville: data['ville'] ?? '',
      territoire: data['territoire'] ?? '',
      village: data['village'] ?? '',
      provinceEduc: data['provinceEduc'] ?? '',
      sousDivision: data['sousDivision'] ?? '',
      regime: data['regime'] ?? '',
      refJuridique: data['refJuridique'] ?? '',
      matriculeSecope: data['matriculeSecope'] ?? '',
      mecanisation: data['mecanisation'] ?? '',
      hasProgrammes: data['hasProgrammes'] ?? false,
      hasCOPA: data['hasCOPA'] ?? false,
      copaOp: data['copaOp'] ?? false,
      nbReunionCOPA: data['nbReunionCOPA'] ?? '',
      nbFemmesCOPA: data['nbFemmesCOPA'] ?? '',
      hasCOGES: data['hasCOGES'] ?? false,
      cogesOp: data['cogesOp'] ?? false,
      nbReunionCOGES: data['nbReunionCOGES'] ?? '',
      nbFemmesCOGES: data['nbFemmesCOGES'] ?? '',
      hasLatrines: data['hasLatrines'] ?? false,
      nbLatrines: data['nbLatrines'] ?? '',
      nbFillesLatrines: data['nbFillesLatrines'] ?? '',
      nbEnsFormes: data['nbEnsFormes'] ?? '',
      nbEnsPositifs: data['nbEnsPositifs'] ?? '',
      nbEnsInspectes: data['nbEnsInspectes'] ?? '',
      hasGovEleves: data['hasGovEleves'] ?? false,
      niveauEcole: data['niveauEcole'] ?? '',
      classesAutorisees: Map<String, String>.from(
        data['classesAutorisees'] ?? {},
      ),
      classesOrganisees: Map<String, String>.from(
        data['classesOrganisees'] ?? {},
      ),
      nbEnseignants: data['nbEnseignants'] ?? '',
      enseignants: List<Map<String, dynamic>>.from(data['enseignants'] ?? []),
      effectifGarcons: Map<String, String>.from(data['effectifGarcons'] ?? {}),
      effectifFilles: Map<String, String>.from(data['effectifFilles'] ?? {}),
      manuelsParAnnee: Map<String, Map<String, String>>.from(
        (data['manuelsParAnnee'] ?? {}).map(
          (key, value) => MapEntry(key, Map<String, String>.from(value)),
        ),
      ),
      bonsEtats: Map<String, String>.from(data['bonsEtats'] ?? {}),
      mauvaisEtats: Map<String, String>.from(data['mauvaisEtats'] ?? {}),
    );
  }
}
