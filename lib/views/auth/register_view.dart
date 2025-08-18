// lib/views/auth/register_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; // Recommandé pour un style cohérent
import 'package:educ_collecteur/controllers/auth_controller.dart';
import 'package:educ_collecteur/widgets/custom_button.dart';
import 'package:educ_collecteur/widgets/custom_text_field.dart';

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

  // Variables
  String? _selectedNiveauEcole;
  String? _selectedGender;
  String? _selectedRole;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _schoolNameController.dispose();
    _codeEcoleController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (widget.fromAdmin) {
        await _authController.createUserByAdmin(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          gender: _selectedGender!,
          role: _selectedRole!,
          // Les champs de l'école sont envoyés comme nulls
          schoolName: null,
          codeEcole: null,
          niveauEcole: null,
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
          role: 'chef',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Utilisateur créé avec succès !"),
            backgroundColor: Colors.green));
        if (widget.fromAdmin) {
          Navigator.pop(context);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Erreur : ${e.toString()}"),
            backgroundColor: Colors.red));
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
      appBar: AppBar(title: Text(pageTitle, style: GoogleFonts.poppins())),
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
                  CustomTextField(
                      controller: _phoneController,
                      labelText: 'Numéro de téléphone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v!.isEmpty ? 'Numéro requis' : null),
                  const SizedBox(height: 16),
                  _buildDropdown(
                      value: _selectedGender,
                      hint: 'Genre',
                      items: ['Masculin', 'Féminin'],
                      onChanged: (val) =>
                          setState(() => _selectedGender = val)),
                ],
              ),
              if (!widget.fromAdmin)
                _buildSectionCard(
                  title: "Informations sur l'Établissement",
                  children: [
                    CustomTextField(
                        controller: _schoolNameController,
                        labelText: "Nom de l’établissement",
                        icon: Icons.apartment_outlined,
                        validator: (v) => !widget.fromAdmin && v!.isEmpty
                            ? 'Champ requis'
                            : null),
                    const SizedBox(height: 16),
                    CustomTextField(
                        controller: _codeEcoleController,
                        labelText: 'Code école',
                        icon: Icons.pin_outlined,
                        validator: (v) => !widget.fromAdmin && v!.isEmpty
                            ? 'Champ requis'
                            : null),
                    const SizedBox(height: 16),
                    _buildDropdown(
                        value: _selectedNiveauEcole,
                        hint: 'Niveau d’école',
                        items: ['Maternel', 'Primaire', 'Secondaire'],
                        onChanged: (val) =>
                            setState(() => _selectedNiveauEcole = val),
                        isRequired: !widget.fromAdmin),
                  ],
                ),
              _buildSectionCard(
                title: "Identifiants & Rôle",
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
                  if (widget.fromAdmin) ...[
                    const SizedBox(height: 16),
                    _buildDropdown(
                      value: _selectedRole,
                      hint: 'Rôle de l\'utilisateur',
                      items: ['chef', 'chef_service', 'directeur', 'admin'],
                      onChanged: (val) => setState(() => _selectedRole = val),
                      isRequired: widget.fromAdmin,
                    ),
                  ]
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                  text: _isLoading ? 'Enregistrement en cours...' : buttonTitle,
                  icon: Icons.person_add_alt_1,
                  onPressed: _isLoading ? null : _handleRegister),
              const SizedBox(height: 20),
              if (!widget.fromAdmin)
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child:
                        const Text("Vous avez déjà un compte ? Se connecter")),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // MÉTHODES MANQUANTES, MAINTENANT RESTAURÉES
  // =========================================================================

  /// Construit une carte stylisée pour regrouper les champs du formulaire.
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
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
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Construit un menu déroulant stylisé et avec validation.
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = true,
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
          .map((item) => DropdownMenuItem(
              value: item,
              child: Text(item[0].toUpperCase() + item.substring(1))))
          .toList(),
      onChanged: onChanged,
      validator: (value) => isRequired && value == null
          ? 'Veuillez sélectionner une option'
          : null,
    );
  }
}
