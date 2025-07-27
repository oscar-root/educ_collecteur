import 'dart:io';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthController {
  final AuthService _authService = AuthService();

  /// Connexion utilisateur
  Future<UserModel?> login(String email, String password) async {
    final user = await _authService.signIn(email, password);
    if (user != null) {
      return await _authService.getCurrentUserModel();
    }
    return null;
  }

  /// Enregistrement simple
  Future<UserModel?> register(
    String email,
    String password,
    String role,
  ) async {
    final user = await _authService.signUp(email, password, role);
    if (user != null) {
      return await _authService.getCurrentUserModel();
    }
    return null;
  }

  /// Enregistrement complet avec données supplémentaires
  Future<UserModel?> registerExtended({
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
    final user = await _authService.signUpExtended(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      schoolName: schoolName,
      codeEcole: codeEcole,
      niveauEcole: niveauEcole,
      gender: gender,
      role: role,
      photo: photo,
    );
    if (user != null) {
      return await _authService.getCurrentUserModel();
    }
    return null;
  }

  /// Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  /// Déconnexion
  Future<void> logout() async {
    await _authService.signOut();
  }
}
