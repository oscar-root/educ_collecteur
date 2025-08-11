// lib/views/admin/manage_users_view.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import pour le formatage de la date

import '../../../controllers/auth_controller.dart';
import '../../../models/user_model.dart';
import '../auth/register_view.dart';
import 'edit_user_view.dart'; // Assurez-vous que le chemin vers votre page d'édition est correct

class ManageUsersView extends StatefulWidget {
  const ManageUsersView({super.key});

  @override
  State<ManageUsersView> createState() => _ManageUsersViewState();
}

class _ManageUsersViewState extends State<ManageUsersView> {
  final TextEditingController _searchController = TextEditingController();
  final AuthController _authController = AuthController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Récupère le flux des utilisateurs actifs depuis Firestore.
  Stream<QuerySnapshot<Map<String, dynamic>>> _getUserStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('archived', isEqualTo: false)
        .orderBy('fullName')
        .snapshots();
  }

  /// Gère le blocage et le déblocage d'un utilisateur.
  Future<void> _toggleBlockUser(UserModel user) async {
    final bool block = !user.isBlocked;
    final String actionText = block ? "Bloquer" : "Débloquer";

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$actionText cet utilisateur ?'),
        content: Text(
          "Le compte de ${user.fullName} sera ${block ? 'restreint' : 'réactivé'}.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              actionText,
              style: TextStyle(
                color: block ? Colors.orange.shade700 : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'isBlocked': block},
      );
    }
  }

  /// Gère l'archivage d'un utilisateur (suppression douce).
  Future<void> _archiveUser(UserModel user) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Archiver cet utilisateur ?'),
        content: Text(
          "Le compte de ${user.fullName} sera désactivé et déplacé vers les archives.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Archiver",
              style: TextStyle(color: Color.fromARGB(255, 244, 79, 76)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'archived': true},
      );
    }
  }

  /// Gère la suppression complète du document utilisateur dans Firestore.
  Future<void> _deleteUser(UserModel user) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          '⚠️ Suppression Définitive ⚠️',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          "Vous êtes sur le point de supprimer définitivement le profil de ${user.fullName}. Cette action est IRREVERSIBLE.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Oui, Supprimer",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authController.deleteUserAccount(user);
    }
  }

  /// Affiche une boîte de dialogue avec les informations complètes de l'utilisateur.
  void _showUserDetailsDialog(UserModel user) {
    final creationDate = user.createdAt != null
        ? DateFormat(
            'dd/MM/yyyy à HH:mm',
            'fr_FR',
          ).format(user.createdAt!.toDate())
        : 'Date inconnue';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getRoleAppearance(user.role).icon,
              color: _getRoleAppearance(user.role).color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                user.fullName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              // _buildDetailRow('UID:', user.uid),
              _buildDetailRow('Email:', user.email),
              _buildDetailRow('Téléphone:', user.phone),
              _buildDetailRow('Rôle:', user.role.toUpperCase()),
              _buildDetailRow('Établissement:', user.schoolName),
              _buildDetailRow('Code École:', user.codeEcole),
              _buildDetailRow('Niveau École:', user.niveauEcole),
              _buildDetailRow('Genre:', user.gender),
              _buildDetailRow(
                'Statut:',
                user.isBlocked ? 'Bloqué' : 'Actif',
              ),
              _buildDetailRow('Créé le:', creationDate),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Helper pour la boîte de dialogue des détails
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  /// Retourne une icône et une couleur basées sur le rôle de l'utilisateur.
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
              stream: _getUserStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Erreur de chargement."));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Aucun utilisateur actif trouvé."),
                  );
                }

                final filteredUsers = snapshot.data!.docs
                    .map((doc) => UserModel.fromMap(doc.data()))
                    .where((user) {
                  final searchLower = _searchController.text.toLowerCase();
                  if (searchLower.isEmpty) return true;
                  return user.fullName.toLowerCase().contains(
                            searchLower,
                          ) ||
                      user.email.toLowerCase().contains(searchLower) ||
                      user.role.toLowerCase().contains(searchLower);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun utilisateur ne correspond à votre recherche.",
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final roleAppearance = _getRoleAppearance(user.role);
                    final isBlocked = user.isBlocked;

                    return Card(
                      elevation: 2,
                      color: isBlocked
                          ? Colors.grey.shade300.withOpacity(0.5)
                          : null,
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration:
                                isBlocked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          "${user.role.toUpperCase()} - ${user.schoolName}\n${user.email}",
                        ),
                        isThreeLine: true,
                        onTap: () => _showUserDetailsDialog(
                          user,
                        ), // Action "Détails" sur le clic principal
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              // Action "Modifier" fonctionnelle
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditUserView(user: user),
                                ),
                              );
                            } else if (value == 'toggle_block') {
                              _toggleBlockUser(user);
                            } else if (value == 'archive') {
                              _archiveUser(user);
                            } else if (value == 'delete') {
                              _deleteUser(user);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('Modifier'),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              value: 'toggle_block',
                              child: Row(
                                children: [
                                  Icon(
                                    isBlocked
                                        ? Icons.lock_open_outlined
                                        : Icons.block,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(isBlocked ? 'Débloquer' : 'Bloquer'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'archive',
                              child: Row(
                                children: [
                                  Icon(Icons.archive_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('Archiver'),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_forever_outlined,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Supprimer',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text("Ajouter Utilisateur"),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RegisterView(fromAdmin: true),
          ),
        ),
      ),
    );
  }

  /// Construit la barre de recherche.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Rechercher un utilisateur...',
          hintText: 'Nom, email ou rôle...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }
}
