import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

class EditUserView extends StatefulWidget {
  final UserModel user;

  const EditUserView({super.key, required this.user});

  @override
  State<EditUserView> createState() => _EditUserViewState();
}

class _EditUserViewState extends State<EditUserView> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _schoolNameController;
  String? _role;
  String? _niveau;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _schoolNameController = TextEditingController(
      text: widget.user.schoolName,
    ); // si existait
    _role = widget.user.role;
    _niveau = widget.user.niveauEcole;
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'schoolName': _schoolNameController.text.trim(),
          'role': _role,
          'niveauEcole': _niveau,
        });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("✅ Utilisateur mis à jour.")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier l'utilisateur")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator:
                    (val) => val == null || val.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator:
                    (val) => val == null || val.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Rôle'),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                    value: 'chef',
                    child: Text('Chef d’établissement'),
                  ),
                  DropdownMenuItem(
                    value: 'chef_service',
                    child: Text('Chef de service'),
                  ),
                  DropdownMenuItem(
                    value: 'directeur',
                    child: Text('Directeur'),
                  ),
                ],
                onChanged: (val) => setState(() => _role = val),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _niveau,
                decoration: const InputDecoration(labelText: "Niveau d'école"),
                items: const [
                  DropdownMenuItem(
                    value: 'Maternelle',
                    child: Text('Maternelle'),
                  ),
                  DropdownMenuItem(value: 'Primaire', child: Text('Primaire')),
                  DropdownMenuItem(
                    value: 'Secondaire',
                    child: Text('Secondaire'),
                  ),
                ],
                onChanged: (val) => setState(() => _niveau = val),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Enregistrer"),
                onPressed: _updateUser,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
