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

  /// Inscription simple (avec email, mot de passe, rôle)
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

  /// ✅ Inscription étendue avec informations supplémentaires
  Future<UserModel?> registerExtended({
    required String email,
    required String password,
    required String fullName,
    required String schoolName,
    required String gender,
    required String role,
    required File? photo,
  }) async {
    final user = await _authService.signUpExtended(
      email: email,
      password: password,
      fullName: fullName,
      schoolName: schoolName,
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
