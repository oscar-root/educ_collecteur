// lib/views/chef_dashboard_view.dart (ou le chemin que vous utilisez)

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Assurez-vous que ces chemins d'importation sont corrects pour votre projet
import '../auth/login_view.dart';
import '../st2/pages/st2_form_page.dart';
import '../st2/st2_list_view.dart';

class ChefDashboardView extends StatefulWidget {
  const ChefDashboardView({super.key});

  @override
  State<ChefDashboardView> createState() => _ChefDashboardViewState();
}

class _ChefDashboardViewState extends State<ChefDashboardView> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;
  bool _isLoading = true;

  // Données de l'utilisateur
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
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _fullName = data['fullName'] ?? 'Chef d\'établissement';
          _email = data['email'] ?? '';
          _photoUrl = data['photoUrl'] ?? '';
          _isLoading = false;
        });
      }
    } else {
      _logout();
    }
  }

  void _startST2Form() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ST2FormPage()),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  // CORRECTION : Retrait de 'const' car ST2ListView n'est probablement pas une constante.
  final List<Widget> _pages = [const _AccueilPage(), const ST2ListView()];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        drawer: _buildSidebar(),
        appBar: AppBar(
          title: const Text('Tableau de Bord'),
          backgroundColor: Colors.indigo,
          elevation: 4,
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.indigo,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'Consulter ST2',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _startST2Form,
          icon: const Icon(Icons.edit_document),
          label: const Text("Remplir ST2"),
          backgroundColor: Colors.indigo,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Drawer _buildSidebar() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              _fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(_email),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  _photoUrl.isNotEmpty
                      ? NetworkImage(_photoUrl)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
              backgroundColor: Colors.white,
            ),
            decoration: const BoxDecoration(color: Colors.indigo),
          ),
          ListTile(
            // CORRECTION : L'icône 'edit_document_outlined' n'existe pas. Utilisation de 'edit_document'.
            leading: const Icon(Icons.edit_document),
            title: const Text('Remplir ST2'),
            onTap: () {
              Navigator.pop(context);
              _startST2Form();
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: const Text('Consulter ST2'),
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ExpansionTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Paramètres'),
            children: [
              SwitchListTile(
                title: const Text('Mode Sombre'),
                value: _isDarkMode,
                onChanged: (val) => setState(() => _isDarkMode = val),
              ),
            ],
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}

class _AccueilPage extends StatelessWidget {
  const _AccueilPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Bienvenue sur votre espace",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        CarouselSlider(
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            aspectRatio: 16 / 9,
            autoPlayInterval: const Duration(seconds: 5),
          ),
          items: [
            _carouselCard(
              "Remplissez vos formulaires ST2",
              "Accédez au formulaire de collecte de données pour votre établissement.",
              Icons.edit_document,
            ),
            _carouselCard(
              "Consultez vos soumissions",
              "Visualisez l'historique de tous les formulaires que vous avez envoyés.",
              Icons.history,
            ),
            _carouselCard(
              "Statistiques et Rapports",
              "Les données consolidées seront bientôt disponibles ici.",
              Icons.bar_chart,
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  static Widget _carouselCard(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
