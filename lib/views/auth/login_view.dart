// lib/views/auth/login_view.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Nécessaire pour FirebaseAuthException
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

  /// Gère la connexion et tous les scénarios d'erreur possibles.
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final UserModel? user = await _authController.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null && mounted) {
        // La redirection par rôle se fait ici si tout s'est bien passé
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
      // Note : Le cas 'user == null' ne devrait pas arriver car AuthController lève des exceptions.
      // C'est une sécurité si la méthode login retournait null sans erreur.
    } on FirebaseAuthException catch (e) {
      // --- ATTRAPE LES ERREURS SPÉCIFIQUES À L'AUTHENTIFICATION FIREBASE ---
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
      print("Erreur FirebaseAuth: ${e.code}"); // Pour le débogage
    } catch (e) {
      // --- ATTRAPE NOS ERREURS PERSONNALISÉES (BLOQUÉ, ARCHIVÉ, PROFIL INTROUVABLE) ---
      // Le `e.toString()` récupère le message de notre `throw Exception(...)` dans AuthController.
      // On nettoie le message pour l'affichage.
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      print("Erreur de logique de connexion: $e"); // Pour le débogage
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Affiche une SnackBar d'erreur avec un message personnalisé.
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
                    Icon(
                      Icons.lock_person_sharp,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
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
                                  ? 'Le mot de passe doit faire au moins 6 caractères'
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
