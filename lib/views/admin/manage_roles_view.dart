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
  String? _selectedRoleFilter; // Pour le filtrage par rôle

  /// Met à jour le rôle et les champs associés d'un utilisateur dans Firestore.
  Future<void> _updateUserRole(UserModel user, String newRole) async {
    try {
      final Map<String, dynamic> updatedData = {'role': newRole};

      if (newRole == 'admin' ||
          newRole == 'directeur' ||
          newRole == 'chef_service') {
        updatedData['schoolName'] = "DIRECTION PROVINCIALE";
        updatedData['niveauEcole'] = "N/A";
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Le profil de ${user.fullName} a été mis à jour."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Erreur lors de la mise à jour : $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Affiche la boîte de dialogue pour changer le rôle d'un utilisateur.
  Future<void> _showChangeRoleDialog(UserModel user) async {
    String selectedRole = user.role.toLowerCase();
    final List<String> roles = ['chef', 'chef_service', 'directeur', 'admin'];

    final String? newRole = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Rôle de ${user.fullName}"),
              content: DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                items: roles.map((role) {
                  return DropdownMenuItem(
                      value: role,
                      child: Text(role[0].toUpperCase() + role.substring(1)));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => selectedRole = value);
                },
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Annuler")),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, selectedRole),
                    child: const Text("Sauvegarder")),
              ],
            );
          },
        );
      },
    );

    if (newRole != null && newRole.toLowerCase() != user.role.toLowerCase()) {
      _updateUserRole(user, newRole.toLowerCase());
    }
  }

  // --- MÉTHODE CORRIGÉE ---
  /// Retourne une icône et une couleur basées sur le rôle, avec un cas par défaut.
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
      // Ce cas par défaut attrape toutes les autres valeurs possibles ('', 'n/a', etc.)
      // et garantit que la fonction retourne TOUJOURS une valeur valide.
      default:
        return (icon: Icons.help_outline, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          _buildRoleFilterChips(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('archived', isEqualTo: false)
                  .orderBy('fullName')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text("Une erreur est survenue."));
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());

                final users = snapshot.data!.docs
                    .map((doc) => UserModel.fromMap(doc.data()))
                    .where((user) {
                  final searchLower = _searchController.text.toLowerCase();
                  final roleFilterMatch = _selectedRoleFilter == null ||
                      user.role.toLowerCase() == _selectedRoleFilter;
                  final searchMatch = searchLower.isEmpty ||
                      user.fullName.toLowerCase().contains(searchLower) ||
                      user.email.toLowerCase().contains(searchLower);
                  return roleFilterMatch && searchMatch;
                }).toList();

                if (users.isEmpty)
                  return const Center(child: Text("Aucun utilisateur trouvé."));

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final roleAppearance = _getRoleAppearance(user.role);
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              roleAppearance.color.withOpacity(0.1),
                          child: Icon(roleAppearance.icon,
                              color: roleAppearance.color),
                        ),
                        title: Text(user.fullName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(user.role.isNotEmpty
                            ? user.role[0].toUpperCase() +
                                user.role.substring(1)
                            : 'Rôle non défini'),
                        trailing: TextButton.icon(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Modifier'),
                          onPressed: () => _showChangeRoleDialog(user),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Rechercher par nom ou email...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchController.clear()))
              : null,
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildRoleFilterChips() {
    final roles = ['chef', 'chef_service', 'directeur', 'admin'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: const Text('Tous'),
                selected: _selectedRoleFilter == null,
                onSelected: (selected) =>
                    setState(() => _selectedRoleFilter = null),
              ),
            ),
            ...roles.map((role) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ChoiceChip(
                  label: Text(role[0].toUpperCase() + role.substring(1)),
                  selected: _selectedRoleFilter == role,
                  onSelected: (selected) {
                    setState(() {
                      _selectedRoleFilter = selected ? role : null;
                    });
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
