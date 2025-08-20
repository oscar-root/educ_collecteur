// lib/views/auth/login_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';
import '../../../models/user_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = AuthController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _iconController.dispose();
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
          errorMessage = 'Ce compte a été désactivé.';
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
      body: Stack(
        children: [
          // Dégradé d'arrière-plan
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6D83F2), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Cercles décoratifs flous
          Positioned(
            top: -50,
            left: -30,
            child: _buildCircle(120, Colors.white.withOpacity(0.2)),
          ),
          Positioned(
            bottom: -60,
            right: -40,
            child: _buildCircle(180, Colors.white.withOpacity(0.15)),
          ),

          // Contenu
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: Tween(begin: 0.9, end: 1.1).animate(
                              CurvedAnimation(
                                parent: _iconController,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: Icon(
                              Icons.lock_person_rounded,
                              size: 90,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Bienvenue",
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Connectez-vous à votre compte",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 28),
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
                          const SizedBox(height: 18),
                          CustomTextField(
                            controller: _passwordController,
                            labelText: 'Mot de passe',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) => value == null ||
                                    value.length < 6
                                ? 'Le mot de passe doit faire au moins 6 caractères'
                                : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, '/reset-password'),
                              child: const Text(
                                'Mot de passe oublié ?',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: _isLoading
                                ? 'Connexion en cours...'
                                : 'Se connecter',
                            icon: Icons.login,
                            onPressed: _isLoading ? null : _handleLogin,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Pas encore de compte ?",
                                style: TextStyle(color: Colors.white70),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/register'),
                                child: const Text(
                                  'S\'inscrire',
                                  style: TextStyle(color: Colors.white),
                                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
