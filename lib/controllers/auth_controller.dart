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

  /// Crée un nouvel utilisateur (par un admin) sans déconnecter l'admin.
  Future<void> createUserByAdmin({
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

      final newUserModel = UserModel(
        uid: newUser.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        schoolName: schoolName,
        codeEcole: codeEcole,
        niveauEcole: niveauEcole.toLowerCase(),
        gender: gender,
        role: role.toLowerCase(),
      );

      await _db.collection('users').doc(newUser.uid).set(newUserModel.toMap());
    } catch (e) {
      rethrow;
    } finally {
      await tempApp.delete();
    }
  }

  /// --- NOUVELLE MÉTHODE POUR LA SUPPRESSION DÉFINITIVE ---
  /// Supprime le document d'un utilisateur dans Firestore.
  /// NOTE : Cette méthode ne supprime PAS l'utilisateur de Firebase Authentication.
  /// La suppression complète d'un autre utilisateur nécessite des privilèges d'administrateur
  /// via l'Admin SDK (côté serveur, ex: Cloud Functions) pour des raisons de sécurité.
  /// La suppression du document Firestore est l'action la plus importante côté client.
  Future<void> deleteUserAccount(UserModel userToDelete) async {
    try {
      // Étape 1 : Supprimer le document de l'utilisateur dans Firestore
      await _db.collection('users').doc(userToDelete.uid).delete();

      // Étape 2 (Optionnelle, via Cloud Function) :
      // Ici, on appellerait une fonction Cloud qui, elle, supprimerait l'utilisateur
      // de Firebase Authentication en utilisant l'Admin SDK.
      // ex: https.onCall((data, context) => { admin.auth().deleteUser(data.uid) });
    } catch (e) {
      // Propage l'erreur pour l'afficher dans la vue.
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
