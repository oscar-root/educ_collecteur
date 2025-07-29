// lib/controllers/auth_controller.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- CORRECTION APPLIQUÉE ICI ---
  /// Getter public pour accéder à l'instance FirebaseAuth de manière sécurisée.
  /// Cela permet à d'autres parties du code (comme les vues) de lire des informations
  /// sur l'utilisateur actuel (ex: `_authController.auth.currentUser`).
  FirebaseAuth get auth => _auth;
  // ---------------------------------

  /// **NOUVELLE MÉTHODE COMBINÉE**
  /// Tente de connecter un utilisateur, et si la connexion réussit,
  /// récupère immédiatement ses données depuis Firestore et retourne un UserModel.
  /// C'est la méthode que la vue de connexion doit appeler.
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    // 1. Authentifier l'utilisateur
    await _auth.signInWithEmailAndPassword(email: email, password: password);

    // 2. Si l'authentification réussit (pas d'exception levée),
    //    récupérer les données du modèle utilisateur.
    return await getCurrentUserModel();
  }

  // La méthode 'signIn' peut être gardée pour un usage interne ou supprimée si non utilisée.
  // Pour plus de clarté, nous la gardons mais notre vue utilisera 'login'.
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

  /// Enregistre un nouvel utilisateur avec toutes les informations du formulaire.
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
    final UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user;
    if (user == null) {
      throw Exception("La création de l'utilisateur a échoué.");
    }
    final userData = {
      'uid': user.uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'schoolName': schoolName,
      'codeEcole': codeEcole,
      'niveauEcole': niveauEcole.toLowerCase(),
      'gender': gender,
      'role': role.toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _db.collection('users').doc(user.uid).set(userData);
    return user;
  }

  /// Récupère les données de l'utilisateur actuellement connecté.
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

  /// Envoie un email de réinitialisation de mot de passe.
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
