// lib/views/auth/login_view.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

// --- (Logique et imports inchangés) ---
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controllers/auth_controller.dart';
import '../../../models/user_model.dart';
// --- FIN des imports ---

import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  // ... (Toute la logique de state, controllers, animation, etc. reste identique à la version "thème clair")
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = AuthController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;
  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _topAlignmentAnimation =
        AlignmentTween(begin: Alignment.topLeft, end: Alignment.topRight)
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.easeInOut));
    _bottomAlignmentAnimation =
        AlignmentTween(begin: Alignment.bottomLeft, end: Alignment.bottomRight)
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.easeInOut));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    /* Logique inchangée */
    if (!_formKey.currentState!.validate()) return;
    if (mounted) setState(() => _isLoading = true);
    try {
      final UserModel? user = await _authController.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
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
            _showErrorSnackBar('Rôle utilisateur non reconnu (${user.role}).');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Une erreur d\'authentification est survenue.';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        errorMessage = 'L\'email ou le mot de passe est incorrect.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Ce compte utilisateur a été désactivé.';
      }
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    /* Logique inchangée */
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.redAccent.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // L'arrière plan reste identique, épuré et animé
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: const [
                  Color(0xFFFFFFFF),
                  Color(0xFFF2F6F9),
                  Color(0xFFE9EEF3)
                ],
                        begin: _topAlignmentAnimation.value,
                        end: _bottomAlignmentAnimation.value))),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                // Conteneur de la carte de formulaire
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 30,
                          spreadRadius: 5)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Section d'en-tête ---
                      FadeInDown(
                          child: Icon(Icons.shield_outlined,
                              size: 50, color: Colors.grey[800])),
                      const SizedBox(height: 16),
                      FadeInDown(
                          delay: const Duration(milliseconds: 100),
                          child: Text("Bienvenue",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87))),
                      const SizedBox(height: 8),
                      FadeInDown(
                          delay: const Duration(milliseconds: 200),
                          child: Text("Connectez-vous à la plateforme",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontSize: 16, color: Colors.grey[600]))),
                      const SizedBox(
                          height: 48), // Espace accru avant le formulaire

                      // --- Début du Formulaire ---
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            FadeInUp(
                                delay: const Duration(milliseconds: 300),
                                child: CustomTextField(
                                    controller: _emailController,
                                    labelText: 'Email',
                                    icon: Icons.alternate_email_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) =>
                                        v == null || !v.contains('@')
                                            ? 'Veuillez entrer un email valide'
                                            : null)),
                            const SizedBox(
                                height: 24), // Espace vertical entre les champs
                            FadeInUp(
                                delay: const Duration(milliseconds: 400),
                                child: CustomTextField(
                                    controller: _passwordController,
                                    labelText: 'Mot de passe',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: !_isPasswordVisible,
                                    suffixIcon: IconButton(
                                        splashRadius: 20,
                                        icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.grey[500]),
                                        onPressed: () => setState(() =>
                                            _isPasswordVisible =
                                                !_isPasswordVisible)),
                                    validator: (v) => v == null || v.length < 6
                                        ? 'Le mot de passe doit faire au moins 6 caractères'
                                        : null)),
                          ],
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: TextButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, '/reset-password'),
                              child: Text('Mot de passe oublié ?',
                                  style: GoogleFonts.poppins(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500))),
                        ),
                      ),
                      const SizedBox(
                          height: 32), // Espace accru avant le bouton principal

                      // --- Section des actions ---
                      FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: CustomButton(
                              text: 'Se connecter',
                              isLoading: _isLoading,
                              onPressed: _handleLogin)),
                      const SizedBox(height: 24),
                      FadeInUp(
                        delay: const Duration(milliseconds: 700),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Pas encore de compte ?",
                                style: GoogleFonts.poppins(
                                    color: Colors.grey[600])),
                            TextButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/register'),
                                child: Text('S\'inscrire',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
