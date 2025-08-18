// lib/controllers/auth_controller.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // Assurez-vous que le chemin vers votre modèle est correct

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Getter public pour un accès en lecture seule à l'instance FirebaseAuth.
  FirebaseAuth get auth => _auth;

  /// Connecte un utilisateur et vérifie son statut (archivé, bloqué).
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user == null)
      throw Exception("Utilisateur non trouvé après l'authentification.");

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data() == null) {
      await _auth.signOut();
      throw Exception(
        "Profil utilisateur introuvable. Veuillez contacter l'administrateur.",
      );
    }

    final userModel = UserModel.fromMap(doc.data()!);

    if (userModel.archived) {
      await _auth.signOut();
      throw Exception(
        "Ce compte a été archivé. Veuillez contacter l'administrateur.",
      );
    }
    if (userModel.isBlocked) {
      await _auth.signOut();
      throw Exception(
        "Votre compte est actuellement bloqué. Veuillez contacter l'administrateur.",
      );
    }

    return userModel;
  }

  /// Enregistre un nouvel utilisateur (inscription standard) et le connecte.
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
    if (user == null)
      throw Exception("La création de l'utilisateur (Auth) a échoué.");

    final newUserModel = UserModel(
      uid: user.uid,
      email: email,
      fullName: fullName,
      phone: phone,
      schoolName: schoolName,
      codeEcole: codeEcole,
      niveauEcole: niveauEcole.toLowerCase(),
      gender: gender,
      role: role.toLowerCase(),
    );

    await _db.collection('users').doc(user.uid).set(newUserModel.toMap());
    return user;
  }

  // =========================================================================
  // MÉTHODE MISE À JOUR
  // =========================================================================
  /// Crée un nouvel utilisateur (par un admin) sans déconnecter l'admin.
  /// Les champs liés à l'école sont maintenant optionnels.
  Future<void> createUserByAdmin({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String gender,
    required String role,
    // CORRIGÉ: Les paramètres suivants sont maintenant optionnels (String?)
    String? schoolName,
    String? codeEcole,
    String? niveauEcole,
  }) async {
    final tempAppName =
        'temp_registration_${DateTime.now().millisecondsSinceEpoch}';
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: tempAppName,
      options: Firebase.app().options,
    );
    FirebaseAuth tempAuth = FirebaseAuth.instanceFor(app: tempApp);

    try {
      UserCredential newUserCredential = await tempAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final newUser = newUserCredential.user;
      if (newUser == null)
        throw Exception("La création de l'utilisateur (Auth) a échoué.");

      // Le modèle UserModel est rempli avec les données fournies.
      // On utilise l'opérateur `?? ''` pour fournir une chaîne vide par défaut si les
      // valeurs sont nulles, afin de ne pas stocker de `null` dans Firestore.
      final newUserModel = UserModel(
        uid: newUser.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        // CORRIGÉ: Utilisation de `?? ''` pour gérer les valeurs optionnelles.
        schoolName: schoolName ?? '',
        codeEcole: codeEcole ?? '',
        niveauEcole: (niveauEcole ?? '').toLowerCase(),
        gender: gender,
        role: role.toLowerCase(),
      );

      // On écrit le document de l'utilisateur dans Firestore.
      await _db.collection('users').doc(newUser.uid).set(newUserModel.toMap());
    } catch (e) {
      // Propage l'erreur pour qu'elle soit affichée dans la SnackBar de la vue.
      rethrow;
    } finally {
      // Assure que l'application temporaire est toujours supprimée, même en cas d'erreur.
      await tempApp.delete();
    }
  }

  /// --- NOUVELLE MÉTHODE POUR LA SUPPRESSION DÉFINITIVE ---
  Future<void> deleteUserAccount(UserModel userToDelete) async {
    try {
      await _db.collection('users').doc(userToDelete.uid).delete();
      // NOTE: La suppression de Firebase Auth nécessite une Cloud Function.
    } catch (e) {
      rethrow;
    }
  }

  /// Récupère le profil Firestore de l'utilisateur actuellement connecté.
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
