import 'package:flutter/material.dart';
import '../../../controllers/auth_controller.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _email = TextEditingController();
  final _controller = AuthController();

  bool _success = false;
  String? _error;
  bool _isLoading = false;

  Future<void> _reset() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = false;
    });

    try {
      await _controller.resetPassword(_email.text.trim());
      setState(() => _success = true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Icon(
                Icons.password_outlined,
                size: 80,
                color: Colors.indigo,
              ),
              const SizedBox(height: 24),
              Text(
                "Réinitialiser le mot de passe",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                controller: _email,
                labelText: 'Email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 12),

              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),

              if (_success)
                const Text(
                  'Un email de réinitialisation a été envoyé.',
                  style: TextStyle(color: Colors.green),
                ),

              const SizedBox(height: 12),

              CustomButton(
                text: _isLoading ? 'Envoi...' : 'Envoyer le lien',
                icon: Icons.send,
                onPressed: _isLoading ? null : _reset,
              ),

              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour à la connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
