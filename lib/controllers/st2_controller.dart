// lib/st2/controllers/st2_controller.dart

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
  /// L'utilisation d'un getter privé rend le code plus propre.
  CollectionReference<Map<String, dynamic>> get _st2Collection =>
      _firestore.collection('st2_forms');

  /// Méthode principale pour soumettre le formulaire ST2.
  ///
  /// Prend un objet [ST2Model] entièrement peuplé, le convertit en Map via la méthode `.toMap()`
  /// et l'envoie à Firestore. Gère les erreurs et retourne un booléen pour indiquer
  /// le succès ou l'échec de l'opération.
  Future<bool> submitST2Form({
    required ST2Model formData,
    required BuildContext context, // Requis pour afficher les SnackBars
  }) async {
    try {
      // La méthode .add() crée un nouveau document avec un ID unique auto-généré.
      // La méthode .toMap() de notre modèle fait tout le travail de conversion des données.
      await _st2Collection.add(formData.toMap());

      // Si l'opération réussit, on affiche un message de succès à l'utilisateur.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Formulaire soumis avec succès !'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true; // L'opération a réussi
    } on FirebaseException catch (e) {
      // Gère les erreurs spécifiques à Firebase (ex: permissions refusées, hors ligne, etc.)
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
      return false; // L'opération a échoué
    } catch (e) {
      // Gère toutes les autres erreurs potentielles (ex: erreur de programmation).
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur inattendue est survenue : $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false; // L'opération a échoué
    }
  }

  /// Récupère une liste de formulaires ST2 soumis par un utilisateur spécifique.
  /// C'est un exemple de méthode de lecture que vous pourriez utiliser
  /// dans votre vue "Consulter ST2" (`ST2ListView`).
  Future<List<ST2Model>> getFormsForUser(String userId) async {
    try {
      final querySnapshot =
          await _st2Collection
              .where('submittedBy', isEqualTo: userId)
              .orderBy('submittedAt', descending: true)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return []; // Retourne une liste vide si aucun formulaire n'est trouvé.
      }

      // Utilise la méthode factory `fromFirestore` du modèle pour convertir chaque document
      // en un objet ST2Model, puis retourne la liste de ces objets.
      return querySnapshot.docs
          .map((doc) => ST2Model.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Dans une application réelle, vous devriez gérer cette erreur,
      // par exemple en la loggant ou en affichant un message à l'utilisateur.
      debugPrint("Erreur lors de la récupération des formulaires : $e");
      return []; // Retourne une liste vide en cas d'erreur.
    }
  }
}
