// lib/views/admin/edit_user_view.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class EditUserView extends StatefulWidget {
  final UserModel user;

  const EditUserView({super.key, required this.user});

  @override
  State<EditUserView> createState() => _EditUserViewState();
}

class _EditUserViewState extends State<EditUserView> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour tous les champs
  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _schoolNameController;
  late TextEditingController _codeEcoleController;

  // Variables d'état pour les menus déroulants
  late String _selectedNiveauEcole;
  late String _selectedGender;
  late String _selectedRole;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialise tous les contrôleurs avec les données de l'utilisateur existant
    _emailController = TextEditingController(text: widget.user.email);
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone);
    _schoolNameController = TextEditingController(text: widget.user.schoolName);
    _codeEcoleController = TextEditingController(text: widget.user.codeEcole);

    // S'assure que les valeurs initiales sont en minuscules pour correspondre aux options du Dropdown
    _selectedNiveauEcole = widget.user.niveauEcole.toLowerCase();
    _selectedGender = widget.user.gender.toLowerCase();
    _selectedRole = widget.user.role.toLowerCase();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _schoolNameController.dispose();
    _codeEcoleController.dispose();
    super.dispose();
  }

  /// Met à jour les informations de l'utilisateur dans Firestore.
  Future<void> _handleUpdateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // On met à jour uniquement les champs qui peuvent être modifiés
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
            'fullName': _fullNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'schoolName': _schoolNameController.text.trim(),
            'codeEcole': _codeEcoleController.text.trim(),
            'niveauEcole': _selectedNiveauEcole,
            'gender': _selectedGender,
            'role': _selectedRole,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Utilisateur mis à jour avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Retourne à la page de gestion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur de mise à jour : $e"),
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
      appBar: AppBar(title: Text("Modifier le Profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Profil de ${widget.user.fullName}",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // --- SECTION PROFIL ---
              Text(
                "Informations de Profil",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // --- CORRECTION APPLIQUÉE ICI ---
              // On utilise un contrôleur pour l'email mais le champ est désactivé
              CustomTextField(
                controller: _emailController,
                labelText: 'Email (non modifiable)',
                icon: Icons.email_outlined,
                enabled:
                    false, // On utilise la propriété 'enabled' de notre CustomTextField
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _fullNameController,
                labelText: 'Nom complet',
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Téléphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: _selectedGender,
                hint: 'Genre',
                items: ['masculin', 'féminin'],
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),

              const Divider(height: 40),

              // --- SECTION PROFESSIONNELLE ---
              Text(
                "Informations Professionnelles",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
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
                value: _selectedNiveauEcole,
                hint: 'Niveau d’école',
                items: ['maternel', 'primaire', 'secondaire'],
                onChanged: (val) => setState(() => _selectedNiveauEcole = val!),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: _selectedRole,
                hint: 'Rôle',
                items: ['admin', 'directeur', 'chef_service', 'chef'],
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),

              const SizedBox(height: 32),
              CustomButton(
                text:
                    _isLoading
                        ? 'Mise à jour en cours...'
                        : 'Sauvegarder les modifications',
                icon: Icons.save_alt_outlined,
                onPressed: _isLoading ? null : _handleUpdateUser,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit un widget DropdownButtonFormField standardisé
  Widget _buildDropdown({
    required String value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: hint,
        border: const OutlineInputBorder(),
      ),
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item, // La valeur interne est en minuscules
                  child: Text(
                    item[0].toUpperCase() + item.substring(1),
                  ), // Le texte affiché a une majuscule
                ),
              )
              .toList(),
      onChanged: onChanged,
      validator:
          (value) => value == null ? 'Veuillez sélectionner une option' : null,
    );
  }
}
