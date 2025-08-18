// lib/controllers/st2_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/st2_model.dart'; // Importation du modèle exact

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

  // --- CREATE ---

  /// Méthode principale pour soumettre un NOUVEAU formulaire ST2.
  Future<bool> submitST2Form({
    required ST2Model formData,
    required BuildContext context,
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
              'Erreur Firestore : ${e.message ?? "Une erreur est survenue."}',
            ),
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

  // --- READ ---

  /// Méthode flexible pour récupérer une liste de formulaires ST2.
  /// Peut filtrer par divers critères combinables.
  Future<List<ST2Model>> getForms({
    required BuildContext context,
    String? userId,
    String? status,
    String? sousDivision,
    String? regimeGestion, // CORRECTION: Le paramètre manquant est ajouté ici.
  }) async {
    try {
      Query<Map<String, dynamic>> query = _st2Collection;

      // Application dynamique des filtres
      if (userId != null) query = query.where('submittedBy', isEqualTo: userId);
      if (status != null) query = query.where('status', isEqualTo: status);
      if (sousDivision != null)
        query = query.where('sousDivision', isEqualTo: sousDivision);
      if (regimeGestion != null)
        query = query.where(
          'regimeGestion',
          isEqualTo: regimeGestion,
        ); // CORRECTION: La logique de filtrage est ajoutée ici.

      final querySnapshot =
          await query.orderBy('submittedAt', descending: true).get();

      if (querySnapshot.docs.isEmpty) return [];

      return querySnapshot.docs
          .map((doc) => ST2Model.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la récupération des formulaires: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return [];
    }
  }

  // --- UPDATE ---

  /// Met à jour un formulaire existant avec de nouvelles données.
  Future<bool> updateFullForm({
    required String docId,
    required ST2Model formData,
    required BuildContext context,
  }) async {
    try {
      await _st2Collection.doc(docId).update(formData.toMap());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Formulaire modifié avec succès !'),
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
            content: Text("Erreur de mise à jour: ${e.message}"),
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
            content: Text("Une erreur inattendue est survenue: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  /// Met à jour uniquement le statut d'un formulaire spécifique.
  Future<bool> updateFormStatus({
    required String docId,
    required String newStatus,
    required BuildContext context,
  }) async {
    try {
      await _st2Collection.doc(docId).update({'status': newStatus});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statut du formulaire mis à jour avec succès.'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la mise à jour du statut: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  // --- DELETE ---

  /// Supprime un formulaire ST2 de la base de données.
  Future<bool> deleteForm({
    required String docId,
    required BuildContext context,
  }) async {
    try {
      await _st2Collection.doc(docId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Formulaire supprimé avec succès.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la suppression du formulaire: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }
}
