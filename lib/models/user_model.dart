// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Représente le modèle de données pour un utilisateur de l'application.
/// Cette classe est utilisée pour structurer les informations récupérées de Firestore.
class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final String schoolName;
  final String codeEcole;
  final String niveauEcole;
  final String gender;
  final String role;
  final Timestamp? createdAt; // Champ ajouté pour la date de création

  // --- CORRECTION : Le constructeur est maintenant à l'intérieur de la classe ---
  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.schoolName,
    required this.codeEcole,
    required this.niveauEcole,
    required this.gender,
    required this.role,
    this.createdAt,
  });

  /// Crée une instance de UserModel à partir d'une Map (généralement depuis Firestore).
  /// Utilise des valeurs par défaut ('') pour éviter les erreurs si un champ est manquant.
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      schoolName: data['schoolName'] ?? '',
      codeEcole: data['codeEcole'] ?? '',
      niveauEcole: data['niveauEcole'] ?? '',
      gender: data['gender'] ?? '',
      role: data['role'] ?? '',
      createdAt: data['createdAt'] as Timestamp?, // Lecture du Timestamp
    );
  }

  /// Convertit l'instance de UserModel en une Map pour l'écriture dans Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'schoolName': schoolName,
      'codeEcole': codeEcole,
      'niveauEcole': niveauEcole,
      'gender': gender,
      'role': role,
      'createdAt':
          createdAt ??
          FieldValue.serverTimestamp(), // Utilise la date existante ou en crée une nouvelle
    };
  }
} // --- CORRECTION : L'accolade de fermeture de la classe est ici ---
