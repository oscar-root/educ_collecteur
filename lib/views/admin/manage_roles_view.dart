// lib/views/admin/manage_roles_view.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';

class ManageRolesView extends StatefulWidget {
  const ManageRolesView({super.key});

  @override
  State<ManageRolesView> createState() => _ManageRolesViewState();
}

class _ManageRolesViewState extends State<ManageRolesView> {
  final TextEditingController _searchController = TextEditingController();

  /// Met à jour le rôle d'un utilisateur dans Firestore.
  Future<void> _updateUserRole(UserModel user, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'role': newRole},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Le rôle de ${user.fullName} a été mis à jour."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la mise à jour : $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Affiche la boîte de dialogue pour changer le rôle d'un utilisateur.
  Future<void> _showChangeRoleDialog(UserModel user) async {
    String selectedRole = user.role; // Le rôle actuel est pré-sélectionné

    final String? newRole = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        // Utilise un StatefulWidget pour gérer l'état de la sélection à l'intérieur du dialogue
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Modifier le rôle de ${user.fullName}"),
              content: DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                    value: 'directeur',
                    child: Text('Directeur'),
                  ),
                  DropdownMenuItem(
                    value: 'chef_service',
                    child: Text('Chef de service'),
                  ),
                  DropdownMenuItem(value: 'chef', child: Text('Chef')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      selectedRole = value;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      selectedRole,
                    ); // Retourne le rôle sélectionné
                  },
                  child: const Text("Sauvegarder"),
                ),
              ],
            );
          },
        );
      },
    );

    // Si un nouveau rôle a été confirmé et qu'il est différent de l'ancien
    if (newRole != null && newRole != user.role) {
      _updateUserRole(user, newRole);
    }
  }

  /// Retourne une icône et une couleur basées sur le rôle.
  ({IconData icon, Color color}) _getRoleAppearance(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return (
          icon: Icons.admin_panel_settings_outlined,
          color: Colors.amber.shade700,
        );
      case 'directeur':
        return (icon: Icons.school_outlined, color: Colors.teal);
      case 'chef_service':
        return (
          icon: Icons.supervisor_account_outlined,
          color: Colors.blue.shade700,
        );
      case 'chef':
        return (icon: Icons.person_outlined, color: Colors.indigo);
      default:
        return (icon: Icons.person_off_outlined, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .where('archived', isEqualTo: false)
                      .orderBy('fullName')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text("Une erreur est survenue."));
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());

                final users =
                    snapshot.data!.docs
                        .map((doc) => UserModel.fromMap(doc.data()))
                        .where((user) {
                          final searchLower =
                              _searchController.text.toLowerCase();
                          if (searchLower.isEmpty) return true;
                          return user.fullName.toLowerCase().contains(
                                searchLower,
                              ) ||
                              user.email.toLowerCase().contains(searchLower);
                        })
                        .toList();

                if (users.isEmpty)
                  return const Center(child: Text("Aucun utilisateur trouvé."));

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final roleAppearance = _getRoleAppearance(user.role);

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: roleAppearance.color.withOpacity(
                            0.1,
                          ),
                          child: Icon(
                            roleAppearance.icon,
                            color: roleAppearance.color,
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(user.email),
                        // Le trailing affiche le rôle actuel et sert de bouton pour le modifier
                        trailing: Chip(
                          label: Text(
                            user.role.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: roleAppearance.color.withOpacity(
                            0.2,
                          ),
                          side: BorderSide.none,
                        ),
                        onTap: () => _showChangeRoleDialog(user),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Rechercher un utilisateur...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _searchController.clear()),
                  )
                  : null,
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }
}
