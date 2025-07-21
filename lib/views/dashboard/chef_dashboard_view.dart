import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChefDashboardView extends StatefulWidget {
  const ChefDashboardView({super.key});

  @override
  State<ChefDashboardView> createState() => _ChefDashboardViewState();
}

class _ChefDashboardViewState extends State<ChefDashboardView> {
  User? _firebaseUser;
  String? _fullName;
  String? _photoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _firebaseUser = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_firebaseUser == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_firebaseUser!.uid)
            .get();

    if (doc.exists) {
      final data = doc.data();
      setState(() {
        _fullName = data?['fullName'] ?? _firebaseUser!.email;
        _photoUrl = data?['photoUrl'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _fullName = _firebaseUser!.email;
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage:
                        _photoUrl != null
                            ? NetworkImage(_photoUrl!)
                            : const AssetImage(
                                  'assets/images/profile_placeholder.png',
                                )
                                as ImageProvider,
                    radius: 30,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _fullName ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                // TODO: Naviguer vers la page paramètres
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Se déconnecter'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  _photoUrl != null
                      ? NetworkImage(_photoUrl!)
                      : const AssetImage(
                            'assets/images/profile_placeholder.png',
                          )
                          as ImageProvider,
            ),
            const SizedBox(width: 12),
            const Text(
              "Tableau de bord – Chef d’établissement",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _buildFeatureCard(
                      context,
                      title: 'Remplir ST2',
                      subtitle: 'Soumettre un formulaire',
                      icon: Icons.edit_document,
                      color: Colors.green,
                      onTap: () => Navigator.pushNamed(context, '/st2-form'),
                    ),
                    _buildFeatureCard(
                      context,
                      title: 'Consulter ST2',
                      subtitle: 'Voir ou modifier les ST2',
                      icon: Icons.folder_open,
                      color: Colors.blue,
                      onTap: () => Navigator.pushNamed(context, '/st2-list'),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
