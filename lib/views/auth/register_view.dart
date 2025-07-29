// lib/views/auth/register_view.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Assurez-vous que les chemins d'importation sont corrects pour votre projet
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  final bool fromAdmin;

  const RegisterView({super.key, this.fromAdmin = false});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _codeEcoleController = TextEditingController();
  final _phoneController = TextEditingController();

  final AuthController _authController = AuthController();

  String _selectedRole = 'chef';
  String _selectedGender = 'Masculin';
  String _selectedNiveau = 'secondaire';

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _schoolNameController.dispose();
    _codeEcoleController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authController.registerExtended(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        schoolName: _schoolNameController.text.trim(),
        codeEcole: _codeEcoleController.text.trim(),
        niveauEcole: _selectedNiveau,
        gender: _selectedGender,
        role: _selectedRole,
      );

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compte pour ${user.email} créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
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
    final roles =
        widget.fromAdmin ? ['admin', 'chef_service', 'chef'] : ['chef'];
    if (!widget.fromAdmin) {
      _selectedRole = 'chef';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un Compte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeInDown(
                child: const Icon(
                  Icons.person_add_outlined,
                  size: 60,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                child: Text(
                  "Inscription",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  "Veuillez remplir tous les champs pour créer le nouvel utilisateur.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionCard(
                title: "Informations Personnelles",
                children: [
                  CustomTextField(
                    controller: _fullNameController,
                    labelText: 'Nom complet',
                    icon: Icons.person_outline,
                    validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  // Ce champ utilise maintenant correctement le 'inputFormatters' qui a été ajouté à CustomTextField
                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Numéro de téléphone',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v!.isEmpty ? 'Numéro requis' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    value: _selectedGender,
                    label: 'Genre',
                    icon: Icons.wc_outlined,
                    items: ['Masculin', 'Féminin'],
                    onChanged: (val) => setState(() => _selectedGender = val!),
                  ),
                ],
              ),

              _buildSectionCard(
                title: "Informations sur l'Établissement",
                children: [
                  CustomTextField(
                    controller: _schoolNameController,
                    labelText: "Nom de l’établissement",
                    icon: Icons.apartment_outlined,
                    validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _codeEcoleController,
                    labelText: 'Code école',
                    icon: Icons.pin_outlined,
                    validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    value: _selectedNiveau,
                    label: 'Niveau d’école',
                    icon: Icons.school_outlined,
                    items: ['maternel', 'primaire', 'secondaire'],
                    onChanged: (val) => setState(() => _selectedNiveau = val!),
                  ),
                ],
              ),

              _buildSectionCard(
                title: "Identifiants de Connexion",
                children: [
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator:
                        (v) =>
                            v == null || !v.contains('@')
                                ? 'Email invalide'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Mot de passe',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator:
                        (v) =>
                            v == null || v.length < 6
                                ? '6 caractères minimum'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  if (widget.fromAdmin)
                    _buildDropdown(
                      value: _selectedRole,
                      label: 'Rôle',
                      icon: Icons.verified_user_outlined,
                      items: roles,
                      onChanged: (val) => setState(() => _selectedRole = val!),
                    ),
                ],
              ),

              const SizedBox(height: 32),

              CustomButton(
                text: _isLoading ? 'Création en cours...' : 'Créer le compte',
                icon: Icons.person_add_alt_1,
                onPressed: _isLoading ? null : _handleRegister,
              ),

              const SizedBox(height: 20),

              if (!widget.fromAdmin)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Vous avez déjà un compte ? Se connecter"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const Divider(height: 24),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item[0].toUpperCase() + item.substring(1)),
                ),
              )
              .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
    );
  }
}
