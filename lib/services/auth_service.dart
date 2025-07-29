// lib/controllers/auth_controller.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Note : L'import de 'user_model.dart' est conservé car il est utilisé dans 'getCurrentUserModel'.
// Assurez-vous que ce fichier n'attend plus de 'photoUrl' dans son constructeur.
import '../models/user_model.dart';

/// Gère toutes les opérations d'authentification et de gestion des utilisateurs avec Firebase.
class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Note : FirebaseStorage a été retiré car il n'est plus utilisé.

  /// Connecte un utilisateur avec son email et son mot de passe.
  /// Retourne l'objet User en cas de succès, sinon propage une exception.
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// **MÉTHODE MISE À JOUR**
  /// Enregistre un nouvel utilisateur avec toutes les informations du formulaire,
  /// sans la photo.
  /// Crée un compte dans Firebase Auth, puis sauvegarde les informations détaillées
  /// dans un document de la collection 'users' sur Firestore.
  Future<User?> registerExtended({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String schoolName,
    required String codeEcole,
    required String niveauEcole,
    required String gender,
    required String role,
  }) async {
    // 1. Créer l'utilisateur dans Firebase Authentication
    final UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;
    if (user == null) {
      // Ce cas est peu probable mais c'est une bonne sécurité
      throw Exception(
        "La création de l'utilisateur a échoué, aucun utilisateur retourné.",
      );
    }

    // 2. La logique de téléversement de la photo a été complètement retirée.

    // 3. Créer le document utilisateur dans Firestore
    final userData = {
      'uid': user.uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'schoolName': schoolName,
      'codeEcole': codeEcole,
      'niveauEcole':
          niveauEcole
              .toLowerCase(), // Sauvegarde en minuscules pour la cohérence
      'gender': gender,
      'role': role.toLowerCase(), // Sauvegarde en minuscules
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _db.collection('users').doc(user.uid).set(userData);

    return user;
  }

  /// Récupère les données de l'utilisateur actuellement connecté
  /// et les transforme en un objet UserModel.
  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
    }
    return null;
  }

  /// Déconnecte l'utilisateur actuel.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Envoie un email de réinitialisation de mot de passe à l'adresse fournie.
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
