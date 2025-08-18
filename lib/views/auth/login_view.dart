// lib/views/auth/login_view.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controllers/auth_controller.dart';
import '../../../models/user_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = AuthController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final UserModel? user = await _authController.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null && mounted) {
        switch (user.role.toLowerCase()) {
          case 'admin':
            Navigator.pushReplacementNamed(context, '/admin_dashboard');
            break;
          case 'chef':
            Navigator.pushReplacementNamed(context, '/chef_dashboard');
            break;
          case 'directeur':
            Navigator.pushReplacementNamed(context, '/directeur_dashboard');
            break;
          case 'chef_service':
            Navigator.pushReplacementNamed(context, '/chef_service_dashboard');
            break;
          default:
            _showErrorSnackBar(
              'Votre rôle (${user.role}) n\'est pas reconnu ou ne permet pas l\'accès.',
            );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'L\'email ou le mot de passe est incorrect.';
          break;
        case 'user-disabled':
          errorMessage = 'Ce compte utilisateur a été désactivé.';
          break;
        case 'invalid-email':
          errorMessage = 'Le format de l\'email est invalide.';
          break;
        default:
          errorMessage = 'Une erreur d\'authentification est survenue.';
      }
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Dégradé arrière-plan
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFECEFF1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85), // Formulaire transparent
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.lock_person_sharp,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Bienvenue",
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Connectez-vous à votre compte",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value == null || !value.contains('@')
                              ? 'Veuillez entrer un email valide'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Mot de passe',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) => value == null || value.length < 6
                          ? 'Le mot de passe doit faire au moins 6 caractères'
                          : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/reset-password'),
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text:
                          _isLoading ? 'Connexion en cours...' : 'Se connecter',
                      icon: Icons.login,
                      onPressed: _isLoading ? null : _handleLogin,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Pas encore de compte ?"),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Text('S\'inscrire'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
