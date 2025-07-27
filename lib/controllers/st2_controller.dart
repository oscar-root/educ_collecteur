import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educ_collecteur/views/models/st2_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/st2_model.dart'; // ✅ AJOUT OBLIGATOIRE

class ST2Controller {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitST2Form(ST2FormModel form) async {
    try {
      await _firestore.collection('formulaires_st2').add(form.toMap());
      print("Formulaire ST2 soumis avec succès.");
    } catch (e) {
      print("Erreur lors de la soumission du formulaire : $e");
      rethrow;
    }
  }

  Future<List<ST2FormModel>> getFormsForCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot =
        await _firestore
            .collection('formulaires_st2')
            .where('uid', isEqualTo: user.uid)
            .get();

    return snapshot.docs
        .map((doc) => ST2FormModel.fromMap(doc.data()))
        .toList();
  }
}
