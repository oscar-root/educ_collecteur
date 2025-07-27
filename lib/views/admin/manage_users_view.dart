import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../auth/register_view.dart';
import 'edit_user_view.dart'; // <- Assure-toi que cette vue existe

class ManageUsersView extends StatefulWidget {
  const ManageUsersView({super.key});

  @override
  State<ManageUsersView> createState() => _ManageUsersViewState();
}

class _ManageUsersViewState extends State<ManageUsersView> {
  String? _selectedRole;
  String? _selectedNiveau;
  String _searchQuery = '';

  Stream<QuerySnapshot<Map<String, dynamic>>> _getUserStream() {
    var query = FirebaseFirestore.instance
        .collection('users')
        .where('archived', isEqualTo: false);

    if (_selectedRole != null && _selectedRole != 'Tous') {
      query = query.where('role', isEqualTo: _selectedRole);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gérer les utilisateurs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Ajouter un utilisateur',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterView(fromAdmin: true),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _getUserStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Erreur de chargement"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users =
                    snapshot.data!.docs
                        .map((doc) => UserModel.fromMap(doc.data()))
                        .where(
                          (u) =>
                              (_selectedRole == null ||
                                  _selectedRole == 'Tous' ||
                                  u.role == _selectedRole) &&
                              (_selectedNiveau == null ||
                                  _selectedNiveau == 'Tous' ||
                                  u.niveauEcole == _selectedNiveau) &&
                              (u.fullName.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ) ||
                                  u.email.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  )),
                        )
                        .toList();

                if (users.isEmpty) {
                  return const Center(child: Text("Aucun utilisateur trouvé."));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(user.fullName),
                        subtitle: Text('${user.role} – ${user.email}'),
                        trailing: Wrap(
                          spacing: 6,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Modifier',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditUserView(user: user),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Supprimer',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        title: const Text(
                                          'Supprimer ce compte ?',
                                        ),
                                        content: Text(
                                          "Êtes-vous sûr de vouloir supprimer ${user.fullName} ?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text("Annuler"),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text("Supprimer"),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .update({'archived': true});
                                }
                              },
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
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Rechercher par nom ou email',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Filtrer par rôle',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tous')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'chef', child: Text('Chef')),
                    DropdownMenuItem(
                      value: 'chef_service',
                      child: Text('Chef de service'),
                    ),
                    DropdownMenuItem(
                      value: 'directeur',
                      child: Text('Directeur'),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedRole = val),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedNiveau,
                  decoration: const InputDecoration(
                    labelText: 'Niveau d’école',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tous')),
                    DropdownMenuItem(
                      value: 'Maternelle',
                      child: Text('Maternelle'),
                    ),
                    DropdownMenuItem(
                      value: 'Primaire',
                      child: Text('Primaire'),
                    ),
                    DropdownMenuItem(
                      value: 'Secondaire',
                      child: Text('Secondaire'),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedNiveau = val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
