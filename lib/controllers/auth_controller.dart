import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<UserModel?> login(String email, String password) async {
    final user = await _authService.signIn(email, password);
    if (user != null) {
      return await _authService.getCurrentUserModel();
    }
    return null;
  }

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

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
