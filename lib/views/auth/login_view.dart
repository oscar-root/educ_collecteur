import 'package:flutter/material.dart';
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
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _controller = AuthController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final UserModel? user = await _controller.login(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        print('Utilisateur connecté avec rôle: ${user.role}');
        switch (user.role.toLowerCase()) {
          case 'admin':
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
            break;
          case 'chef':
            Navigator.pushReplacementNamed(context, '/chef-dashboard');
            break;
          case 'chef_service':
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
            break;
          case 'directeur':
            Navigator.pushReplacementNamed(context, '/directeur-dashboard');
            break;
          default:
            setState(() => _error = 'Rôle non reconnu: ${user.role}');
        }
      } else {
        setState(() => _error = 'Email ou mot de passe incorrect.');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: Colors.indigo,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Connexion",
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _email,
                          labelText: 'Email',
                          icon: Icons.email_outlined,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Champ requis'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _password,
                          labelText: 'Mot de passe',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Champ requis';
                            if (value.length < 6)
                              return 'Au moins 6 caractères';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_error != null)
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: _isLoading ? 'Connexion...' : 'Se connecter',
                          icon: Icons.login,
                          onPressed: _isLoading ? null : _login,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed:
                              () => Navigator.pushNamed(
                                context,
                                '/reset-password',
                              ),
                          child: const Text('Mot de passe oublié ?'),
                        ),
                        const Divider(),
                        TextButton(
                          onPressed:
                              () => Navigator.pushNamed(context, '/register'),
                          child: const Text('Créer un compte'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
