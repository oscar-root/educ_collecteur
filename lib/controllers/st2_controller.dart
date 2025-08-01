// lib/controllers/st2_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/st2_model.dart'; // Assurez-vous que ce chemin est correct

/// Gère la logique métier pour les formulaires ST2 (communication avec Firebase).
class ST2Controller {
  final FirebaseFirestore _firestore;

  /// Le constructeur permet d'injecter une instance de Firestore (utile pour les tests)
  /// ou utilise l'instance globale par défaut.
  ST2Controller({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Référence à la collection Firestore où les formulaires sont stockés.
  CollectionReference<Map<String, dynamic>> get _st2Collection =>
      _firestore.collection('st2_forms');

  /// Méthode principale pour soumettre le formulaire ST2.
  Future<bool> submitST2Form({
    required ST2Model formData,
    required BuildContext context, // Requis pour afficher les SnackBars
  }) async {
    try {
      await _st2Collection.add(formData.toMap());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Formulaire soumis avec succès !'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true;
    } on FirebaseException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur Firestore : ${e.message ?? "Une erreur est survenue."}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur inattendue est survenue : $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  /// Récupère une liste de formulaires ST2 soumis par un utilisateur spécifique.
  Future<List<ST2Model>> getFormsForUser(String userId) async {
    try {
      final querySnapshot = await _st2Collection
          .where('submittedBy', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => ST2Model.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("Erreur lors de la récupération des formulaires : $e");
      return [];
    }
  }

  // --- NOUVELLE MÉTHODE POUR VALIDER UN FORMULAIRE ---
  /// Met à jour le statut d'un formulaire à 'Validé' et ajoute une date de validation.
  Future<void> validateST2Form(String formId, BuildContext context) async {
    try {
      await _st2Collection.doc(formId).update({
        'status': 'Validé',
        'validatedAt': Timestamp.now(), // Bonne pratique pour le suivi
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Formulaire validé avec succès."),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la validation : $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // --- NOUVELLE MÉTHODE POUR SUPPRIMER UN FORMULAIRE ---
  /// Supprime définitivement un formulaire de la base de données.
  Future<void> deleteST2Form(String formId, BuildContext context) async {
    try {
      await _st2Collection.doc(formId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Formulaire supprimé avec succès."),
            backgroundColor:
                Colors.orange, // Couleur orange pour une suppression
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la suppression : $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
