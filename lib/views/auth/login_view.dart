// lib/views/auth/login_view.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- IMPORT NÉCESSAIRE pour FirebaseAuthException
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

  /// Gère le processus de connexion, la redirection par rôle et les erreurs spécifiques.
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
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Votre rôle (${user.role}) ne permet pas l\'accès.',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible de récupérer les informations du profil.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // --- GESTION D'ERREURS AMÉLIORÉE ---
      // Affiche l'erreur exacte dans la console du développeur
      print("Erreur d'authentification Firebase : ${e.code}");

      String errorMessage = "Une erreur d'authentification est survenue.";
      // Traduit les codes d'erreur de Firebase en messages clairs pour l'utilisateur
      if (e.code == 'user-not-found') {
        errorMessage = 'Aucun compte n\'est associé à cet email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Le mot de passe est incorrect.';
      } else if (e.code == 'invalid-credential' || e.code == 'invalid-email') {
        // 'invalid-credential' est plus récent et plus général
        errorMessage = 'L\'email ou le mot de passe est incorrect.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Ce compte utilisateur a été désactivé.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      // Pour toutes les autres erreurs non liées à l'authentification Firebase (ex: réseau)
      print("Erreur de connexion générale : $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Une erreur inattendue est survenue. Veuillez vérifier votre connexion.',
            ),
            backgroundColor: Color.fromARGB(255, 233, 56, 56),
          ),
        );
      }
    } finally {
      // Quoi qu'il arrive, on s'assure de réactiver le bouton et de ne plus afficher le chargement.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons
                          .lock_person_sharp, // Icône légèrement modifiée pour le style
                      size: 80,
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Bienvenue",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Connectez-vous à votre compte",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator:
                          (value) =>
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
                      validator:
                          (value) =>
                              value == null || value.length < 6
                                  ? 'Le mot de passe doit contenir au moins 6 caractères'
                                  : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            () =>
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
                          onPressed:
                              () => Navigator.pushNamed(context, '/register'),
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
