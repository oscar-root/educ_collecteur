// lib/models/user_model.dart

//import'package.cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final Timestamp? createdAt;
  final bool isBlocked; // <-- NOUVEAU CHAMP
  final bool archived; // <-- CHAMP AJOUTÉ pour plus de clarté

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
    this.isBlocked = false, // Valeur par défaut
    this.archived = false, // Valeur par défaut
  });

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
      createdAt: data['createdAt'] as Timestamp?,
      isBlocked: data['isBlocked'] ?? false, // <-- NOUVEAU CHAMP
      archived: data['archived'] ?? false,
    );
  }

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
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'isBlocked': isBlocked, // <-- NOUVEAU CHAMP
      'archived': archived,
    };
  }
}
