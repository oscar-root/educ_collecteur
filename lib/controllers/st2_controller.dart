import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/st2_model.dart'; // Importez le modèle que nous venons de créer

class ST2Controller {
  final FirebaseFirestore _firestore;

  // Le constructeur permet d'injecter une instance de Firestore (utile pour les tests)
  // ou utilise l'instance par défaut.
  ST2Controller({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Référence à la collection où les formulaires seront stockés.
  CollectionReference<Map<String, dynamic>> get _st2Collection =>
      _firestore.collection('st2_forms');

  /// Méthode principale pour soumettre le formulaire ST2.
  /// Prend un objet ST2Model, le convertit en Map et l'envoie à Firestore.
  /// Gère les erreurs et retourne un booléen pour indiquer le succès ou l'échec.
  Future<bool> submitST2Form({
    required ST2Model formData,
    required BuildContext context, // Pour afficher les messages
  }) async {
    try {
      // Utilise la méthode .add() pour créer un nouveau document avec un ID auto-généré.
      // La méthode .toMap() de notre modèle fait tout le travail de conversion.
      await _st2Collection.add(formData.toMap());

      // Si tout se passe bien, affiche un message de succès.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Formulaire soumis avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true; // Succès
    } on FirebaseException catch (e) {
      // Gère les erreurs spécifiques à Firebase (ex: permissions refusées)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur Firestore : ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false; // Échec
    } catch (e) {
      // Gère toutes les autres erreurs potentielles.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur inattendue est survenue : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false; // Échec
    }
  }

  /// Récupère une liste de formulaires ST2 pour un utilisateur donné.
  /// C'est un exemple de méthode de lecture que vous pourriez utiliser
  /// dans la vue "Consulter ST2".
  Future<List<ST2Model>> getFormsForUser(String userId) async {
    try {
      final querySnapshot =
          await _st2Collection
              .where('submittedBy', isEqualTo: userId)
              .orderBy('submittedAt', descending: true)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      // Convertit chaque document en objet ST2Model
      return querySnapshot.docs
          .map((doc) => ST2Model.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Dans une vraie application, vous devriez gérer cette erreur,
      // par exemple en l'affichant à l'utilisateur.
      debugPrint("Erreur lors de la récupération des formulaires: $e");
      return [];
    }
  }
}
