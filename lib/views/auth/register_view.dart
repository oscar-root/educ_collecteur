// lib/views/auth/register_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

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
  final _authController = AuthController();

  // Contrôleurs
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _codeEcoleController = TextEditingController();

  // Variables d'état
  String? _selectedNiveauEcole;
  String? _selectedGender;
  String? _selectedRole;
  bool _isLoading = false;

  // --- NOUVELLE VARIABLE D'ÉTAT POUR CONTRÔLER L'UI ---
  bool _isHighLevelRole = false;

  @override
  void dispose() {
    // Nettoyage des contrôleurs
    super.dispose();
  }

  // --- NOUVELLE MÉTHODE POUR METTRE À JOUR L'UI EN FONCTION DU RÔLE ---
  void _onRoleChanged(String? newRole) {
    setState(() {
      _selectedRole = newRole;
      if (newRole == 'Admin' ||
          newRole == 'Directeur' ||
          newRole == 'Chef_service') {
        _isHighLevelRole = true;
        _schoolNameController.text = "DIRECTION PROVINCIALE";
        _selectedNiveauEcole = null; // Réinitialiser pour le cacher
      } else {
        _isHighLevelRole = false;
        _schoolNameController.clear();
      }
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (widget.fromAdmin) {
        // La logique de décision est déjà faite, on utilise directement les valeurs
        await _authController.createUserByAdmin(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole!,
          schoolName: _schoolNameController.text.trim(),
          codeEcole: _codeEcoleController.text.trim(),
          niveauEcole:
              _selectedNiveauEcole ?? 'N/A', // Valeur par défaut si caché
          gender: _selectedGender!,
        );
      } else {
        await _authController.registerExtended(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          schoolName: _schoolNameController.text.trim(),
          codeEcole: _codeEcoleController.text.trim(),
          niveauEcole: _selectedNiveauEcole!,
          gender: _selectedGender!,
          role: 'Chef',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Utilisateur créé avec succès !"),
              backgroundColor: Colors.green),
        );
        Navigator.of(context)
            .pop(); // L'admin ou l'utilisateur retourne à la page précédente
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Erreur : ${e.toString()}"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle =
        widget.fromAdmin ? "Ajouter un Utilisateur" : "Créer un Compte";
    final buttonTitle =
        widget.fromAdmin ? "Enregistrer l'Utilisateur" : "Créer mon Compte";

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: "Informations Personnelles",
                children: [
                  CustomTextField(
                      controller: _fullNameController,
                      labelText: 'Nom complet',
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Champ requis' : null),
                  const SizedBox(height: 16),
                  // --- CHAMP RÔLE CONDITIONNEL ---
                  if (widget.fromAdmin)
                    _buildDropdown(
                      value: _selectedRole,
                      hint: 'Rôle de l\'utilisateur',
                      items: ['Chef', 'Chef_service', 'Directeur', 'Admin'],
                      onChanged: _onRoleChanged, // Appel de notre méthode
                    ),
                  if (widget.fromAdmin) const SizedBox(height: 16),
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
                    hint: 'Genre',
                    items: ['Masculin', 'Féminin'],
                    onChanged: (val) => setState(() => _selectedGender = val),
                  ),
                ],
              ),
              _buildSectionCard(
                title: "Informations sur l'Établissement",
                children: [
                  // --- CHAMP NOM ÉCOLE CONDITIONNEL ---
                  CustomTextField(
                    controller: _schoolNameController,
                    labelText: "Nom de l’établissement",
                    icon: Icons.apartment_outlined,
                    enabled: !_isHighLevelRole, // Champ activé/désactivé
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
                  // --- CHAMP NIVEAU ÉCOLE CONDITIONNEL ---
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isHighLevelRole ? 0.0 : 1.0,
                    child: _isHighLevelRole
                        ? const SizedBox.shrink()
                        : _buildDropdown(
                            value: _selectedNiveauEcole,
                            hint: 'Niveau d’école',
                            items: ['Maternel', 'Primaire', 'Secondaire'],
                            onChanged: (val) =>
                                setState(() => _selectedNiveauEcole = val),
                            // Validation seulement si le champ est visible
                            validator: (value) {
                              if (!_isHighLevelRole && value == null) {
                                return 'Veuillez sélectionner une option';
                              }
                              return null;
                            },
                          ),
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
                      validator: (v) => v == null || !v.contains('@')
                          ? 'Email invalide'
                          : null),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _passwordController,
                      labelText: 'Mot de passe',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (v) => v == null || v.length < 6
                          ? '6 caractères minimum'
                          : null),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: _isLoading ? 'Enregistrement...' : buttonTitle,
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

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
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
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo)),
              const Divider(height: 24),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator, // Rendre le validateur optionnel
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      decoration: InputDecoration(
        labelText: hint,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: validator ??
          (value) => value == null ? 'Veuillez sélectionner une option' : null,
    );
  }
}
