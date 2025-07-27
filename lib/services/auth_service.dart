import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Connexion
  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// Enregistrement basique
  Future<User?> signUp(String email, String password, String role) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return user;
  }

  /// Enregistrement complet avec photo, téléphone, école, etc.
  Future<User?> signUpExtended({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String schoolName,
    required String codeEcole,
    required String niveauEcole,
    required String gender,
    required String role,
    File? photo,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;
    if (user == null) return null;

    String photoUrl = '';
    if (photo != null) {
      final ref = _storage.ref().child('profile_photos/${user.uid}.jpg');
      await ref.putFile(photo);
      photoUrl = await ref.getDownloadURL();
    }

    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'schoolName': schoolName,
      'codeEcole': codeEcole,
      'niveauEcole': niveauEcole,
      'gender': gender,
      'role': role,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return user;
  }

  /// Récupérer l'utilisateur actuel avec ses données
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

  /// Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
