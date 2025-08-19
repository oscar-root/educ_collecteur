// lib/views/auth/reset_password_view.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

// Assurez-vous que ces chemins sont corrects
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _emailController = TextEditingController();
  final _controller = AuthController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    // Valide le formulaire avant de continuer
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // --- CORRECTION APPLIQUÉE ICI ---
      // L'appel utilise maintenant le paramètre nommé 'email:'
      await _controller.resetPassword(email: _emailController.text.trim());

      // Affichage d'un message de succès clair via un SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Un email de réinitialisation a été envoyé.'),
            backgroundColor: Colors.green,
          ),
        );
        // On peut optionnellement retourner à l'écran de connexion après succès
        Navigator.pop(context);
      }
    } catch (e) {
      // Affichage d'un message d'erreur clair via un SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Permet d'avoir une flèche de retour avec la bonne couleur
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeInDown(
                  child: const Icon(
                    Icons.lock_reset_outlined,
                    size: 80,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  child: Text(
                    "Mot de passe oublié ?",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    "Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: CustomTextField(
                    controller: _emailController,
                    labelText: 'Adresse Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: CustomButton(
                    text: _isLoading ? 'Envoi en cours...' : 'Envoyer le lien',
                    icon: Icons.send_outlined,
                    onPressed: _isLoading ? null : _handleReset,
                  ),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Retour à la connexion'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
