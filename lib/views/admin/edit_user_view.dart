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

  // Contrôleurs
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _schoolNameController;
  late TextEditingController _codeEcoleController;

  // Variables d'état
  String? _selectedNiveauEcole;
  String? _selectedGender;
  String? _selectedRole;
  bool _isLoading = false;

  // Nouvelle variable pour contrôler l'UI dynamiquement
  bool _isHighLevelRole = false;

  // Listes pour les Dropdowns (en minuscules pour correspondre aux données)
  final List<String> _roles = ['chef', 'chef_service', 'directeur', 'admin'];
  final List<String> _niveaux = ['maternel', 'primaire', 'secondaire'];
  final List<String> _genders = ['masculin', 'féminin'];

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone);
    _schoolNameController = TextEditingController(text: widget.user.schoolName);
    _codeEcoleController = TextEditingController(text: widget.user.codeEcole);

    _selectedGender = widget.user.gender.toLowerCase();
    _selectedRole = widget.user.role.toLowerCase();

    // --- LOGIQUE D'INITIALISATION SÉCURISÉE POUR ÉVITER LE CRASH ---
    if (_niveaux.contains(widget.user.niveauEcole.toLowerCase())) {
      _selectedNiveauEcole = widget.user.niveauEcole.toLowerCase();
    } else {
      _selectedNiveauEcole = null;
    }

    // Appliquer la logique d'affichage dès le chargement de la page
    _onRoleChanged(_selectedRole);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _schoolNameController.dispose();
    _codeEcoleController.dispose();
    super.dispose();
  }

  // Méthode pour mettre à jour l'UI en fonction du rôle
  void _onRoleChanged(String? newRole) {
    setState(() {
      _selectedRole = newRole;
      if (newRole == 'admin' ||
          newRole == 'directeur' ||
          newRole == 'chef_service') {
        _isHighLevelRole = true;
        _schoolNameController.text = "DIRECTION PROVINCIALE";
        _selectedNiveauEcole = null; // Cacher le champ
      } else {
        _isHighLevelRole = false;
        // Si on change pour 'chef', on efface le nom de l'école pour le rendre modifiable
        if (widget.user.role != 'chef') {
          _schoolNameController.text = '';
        }
      }
    });
  }

  Future<void> _handleUpdateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'schoolName': _schoolNameController.text.trim(),
        'codeEcole': _codeEcoleController.text.trim(),
        'niveauEcole': _selectedNiveauEcole ?? 'N/A', // Mettre 'N/A' si caché
        'gender': _selectedGender!,
        'role': _selectedRole!,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Utilisateur mis à jour avec succès !"),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Erreur de mise à jour : $e"),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              Text("Informations de Profil",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              CustomTextField(
                controller: TextEditingController(
                    text: widget.user.email), // Utilise un contrôleur local
                labelText: 'Email (non modifiable)',
                icon: Icons.email_outlined,
                enabled: false,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                  controller: _fullNameController,
                  labelText: 'Nom complet',
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Champ requis' : null),
              const SizedBox(height: 16),
              CustomTextField(
                  controller: _phoneController,
                  labelText: 'Téléphone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Champ requis' : null),
              const SizedBox(height: 16),
              _buildDropdown(
                value: _selectedGender,
                hint: 'Genre',
                items: _genders,
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
              const Divider(height: 40),

              Text("Informations Professionnelles",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              // Champ Rôle
              _buildDropdown(
                value: _selectedRole,
                hint: 'Rôle',
                items: _roles,
                onChanged:
                    _onRoleChanged, // Appel de la méthode de mise à jour de l'UI
              ),
              const SizedBox(height: 16),

              // Champ Nom de l'établissement conditionnel
              CustomTextField(
                controller: _schoolNameController,
                labelText: "Nom de l’établissement",
                icon: Icons.apartment_outlined,
                enabled: !_isHighLevelRole, // Désactivé si rôle élevé
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                  controller: _codeEcoleController,
                  labelText: 'Code école',
                  icon: Icons.pin_outlined,
                  validator: (v) => v!.isEmpty ? 'Champ requis' : null),
              const SizedBox(height: 16),

              // Champ Niveau d'école conditionnel
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isHighLevelRole ? 0.0 : 1.0,
                child: _isHighLevelRole
                    ? const SizedBox.shrink()
                    : _buildDropdown(
                        value: _selectedNiveauEcole,
                        hint: 'Niveau d’école',
                        items: _niveaux,
                        onChanged: (val) =>
                            setState(() => _selectedNiveauEcole = val),
                        validator: (value) {
                          // La validation ne s'applique que si le champ est visible
                          if (!_isHighLevelRole && value == null) {
                            return 'Veuillez sélectionner une option';
                          }
                          return null;
                        },
                      ),
              ),

              const SizedBox(height: 32),
              CustomButton(
                text: _isLoading ? 'Mise à jour...' : 'Sauvegarder',
                icon: Icons.save_alt_outlined,
                onPressed: _isLoading ? null : _handleUpdateUser,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    String? value, // La valeur peut être nulle
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration:
          InputDecoration(labelText: hint, border: const OutlineInputBorder()),
      items: items
          .map((item) => DropdownMenuItem(
              value: item,
              child: Text(item[0].toUpperCase() + item.substring(1))))
          .toList(),
      onChanged: onChanged,
      validator: validator ??
          (val) => val == null ? 'Veuillez sélectionner une option' : null,
    );
  }
}
