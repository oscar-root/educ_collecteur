import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/auth_controller.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _authController = AuthController();

  String _selectedGender = 'Masculin';
  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Veuillez choisir une photo de profil.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      const role = 'chef';

      final user = await _authController.registerExtended(
        email: email,
        password: password,
        fullName: _fullNameController.text.trim(),
        schoolName: _schoolNameController.text.trim(),
        gender: _selectedGender,
        role: role,
        photo: _selectedImage,
      );

      if (user != null) {
        Navigator.pop(context);
      } else {
        setState(() => _errorMessage = "Échec de l'inscription.");
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription – Chef d’établissement')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.school_outlined,
                  size: 80,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 16),
                Text(
                  "Créer un compte Chef d’établissement",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.indigo.withOpacity(0.2),
                    backgroundImage:
                        _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : null,
                    child:
                        _selectedImage == null
                            ? const Icon(
                              Icons.camera_alt,
                              color: Colors.indigo,
                              size: 32,
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  controller: _fullNameController,
                  labelText: 'Nom complet',
                  icon: Icons.person_outline,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Champ requis'
                              : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _schoolNameController,
                  labelText: 'Nom de l’établissement',
                  icon: Icons.apartment_outlined,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Champ requis'
                              : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email professionnel',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Champ requis'
                              : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Mot de passe',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Champ requis';
                    if (value.length < 6) return 'Au moins 6 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: const [
                    DropdownMenuItem(
                      value: 'Masculin',
                      child: Text('Masculin'),
                    ),
                    DropdownMenuItem(value: 'Féminin', child: Text('Féminin')),
                  ],
                  onChanged: (val) => setState(() => _selectedGender = val!),
                  decoration: const InputDecoration(
                    labelText: 'Genre',
                    prefixIcon: Icon(Icons.person_2_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 12),

                CustomButton(
                  text: _isLoading ? 'Création en cours...' : 'S’inscrire',
                  icon: Icons.person_add_alt,
                  onPressed: _isLoading ? null : _handleRegister,
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Retour à la connexion"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
