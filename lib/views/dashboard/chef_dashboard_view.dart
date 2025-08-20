// lib/views/chef_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORTS ---
import 'package:educ_collecteur/views/auth/login_view.dart';
import 'package:educ_collecteur/views/st2/pages/st2_form_page.dart';
import 'package:educ_collecteur/views/st2/st2_list_view.dart';

class ChefDashboardView extends StatefulWidget {
  const ChefDashboardView({super.key});

  @override
  State<ChefDashboardView> createState() => _ChefDashboardViewState();
}

class _ChefDashboardViewState extends State<ChefDashboardView> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  String _fullName = "Chargement...";
  String _email = "";
  String _photoUrl = "";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && mounted) {
          final data = doc.data()!;
          setState(() {
            _fullName = data['fullName'] ?? 'Chef d\'établissement';
            _email = user.email ?? '';
            _photoUrl = data['photoUrl'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      _logout();
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
    }
  }

  // CORRIGÉ: Le mot-clé `const` a été retiré de la liste car ST2ListView n'est pas une constante.
  final List<Widget> _pages = [
    const _AccueilPage(),
    const ST2ListView(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ST2FormPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSidebar(),
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Tableau de Bord' : 'Mes Formulaires Soumis',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey.shade600,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Consulter',
          ),
          BottomNavigationBarItem(
            // CORRIGÉ: Utilisation d'une icône valide comme `edit_note`.
            icon: Icon(Icons.edit_note_outlined),
            activeIcon: Icon(Icons.edit_note),
            label: 'Remplir ST2',
          ),
        ],
      ),
    );
  }

  Drawer _buildSidebar() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_fullName,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            accountEmail: Text(_email, style: GoogleFonts.poppins()),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
              backgroundColor: Colors.white,
              child: _photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 40, color: Colors.indigo)
                  : null,
            ),
            decoration: const BoxDecoration(color: Colors.indigo),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text('Accueil', style: GoogleFonts.poppins()),
            onTap: () {
              _onItemTapped(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: Text('Consulter ST2', style: GoogleFonts.poppins()),
            onTap: () {
              _onItemTapped(1);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('Se déconnecter',
                style: GoogleFonts.poppins(color: Colors.red)),
            onTap: _logout,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AccueilPage extends StatelessWidget {
  const _AccueilPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bienvenue sur votre espace",
            style:
                GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Gérez et suivez vos formulaires de données scolaires.",
            style:
                GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          _ActionCard(
            title: "Remplir un Formulaire ST2",
            subtitle:
                "Commencez une nouvelle collecte de données pour la période en cours.",
            // CORRIGÉ: Utilisation d'une icône valide.
            icon: Icons.edit_note_outlined,
            color: Colors.blue.shade700,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ST2FormPage()));
            },
          ),
          const SizedBox(height: 16),
          _ActionCard(
            title: "Consulter Mes Soumissions",
            subtitle:
                "Visualisez et modifiez l'historique de vos formulaires soumis.",
            icon: Icons.history_edu_outlined,
            color: Colors.green.shade700,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ST2ListView()));
            },
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
