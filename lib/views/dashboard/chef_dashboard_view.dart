// lib/views/chef_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
// Import du package de défilement correct
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';

import '../auth/login_view.dart';
import 'package:educ_collecteur/providers/theme_provider.dart';
import '../st2/pages/st2_form_page.dart';
import '../st2/st2_list_view.dart';

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
    if (user == null) {
      _logout();
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (mounted && doc.exists) {
      final data = doc.data()!;
      setState(() {
        _fullName = data['fullName'] ?? 'Chef d\'établissement';
        _email = data['email'] ?? '';
        _photoUrl = data['photoUrl'] ?? '';
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _startST2Form() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ST2FormPage()));
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false);
    }
  }

  final List<Widget> _pages = [const _AccueilPage(), ST2ListView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSidebar(),
      appBar: AppBar(title: const Text('Tableau de Bord')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(index: _selectedIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: _startST2Form,
        child: const Icon(Icons.edit_document),
        tooltip: 'Remplir ST2',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home, index: 0, label: 'Accueil'),
            const SizedBox(width: 40),
            _buildNavItem(icon: Icons.list_alt, index: 1, label: 'Consulter'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required int index, required String label}) {
    final isSelected = _selectedIndex == index;
    final activeColor = Theme.of(context).primaryColor;
    return IconButton(
      icon: Icon(icon, color: isSelected ? activeColor : Colors.grey),
      onPressed: () => setState(() => _selectedIndex = index),
      tooltip: label,
    );
  }

  Drawer _buildSidebar() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_fullName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(_email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: _photoUrl.isNotEmpty
                  ? NetworkImage(_photoUrl)
                  : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
              backgroundColor: Colors.white,
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
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
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(value),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Se déconnecter',
                style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}

// --- PAGE D'ACCUEIL CORRIGÉE ---

class _AccueilPage extends StatelessWidget {
  const _AccueilPage();

  @override
  Widget build(BuildContext context) {
    // Liste des cartes à afficher
    final List<Widget> infoCards = [
      const _InfoCard(
        icon: Icons.upload_file_outlined,
        title: "Fournir les Données Scolaires",
        subtitle:
            "Votre rôle est essentiel. Soumettez les formulaires ST2 avec précision pour refléter la réalité de votre établissement.",
        color: Color(0xFF0293ee),
      ),
      const _InfoCard(
        icon: Icons.history_edu_outlined,
        title: "Consulter l'Historique",
        subtitle:
            "Accédez à tout moment à l'historique de vos soumissions passées pour un suivi et une référence faciles.",
        color: Color(0xFFf8b250),
      ),
      const _InfoCard(
        icon: Icons.rule_folder_outlined,
        title: "Respecter les Normes",
        subtitle:
            "Conseil : Vérifiez chaque information avant de soumettre. Des données exactes sont cruciales pour une planification efficace.",
        color: Color(0xFF845bef),
      ),
      const _InfoCard(
        icon: Icons.school_outlined,
        title: "Prendre Soin de l'Établissement",
        subtitle:
            "Un environnement d'apprentissage de qualité est un facteur clé de succès. Votre gestion fait la différence.",
        color: Color(0xFF13d38e),
      ),
      const _InfoCard(
        icon: Icons.flag_outlined,
        title: "L'Espoir d'une Nation",
        subtitle:
            "L'éducation est le pilier sur lequel repose l'avenir. Chaque élève compte, chaque donnée est importante.",
        color: Color(0xFFff6384),
      ),
      const _InfoCard(
        icon: Icons.lightbulb_outline,
        title: "Votre Impact",
        subtitle:
            "Grâce à votre contribution, les décideurs peuvent allouer les ressources là où elles sont le plus nécessaires.",
        color: Color(0xFF36a2eb),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Bienvenue sur votre espace",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ScrollLoopAutoScroll(
            child: Column(
              children: infoCards,
            ),
            scrollDirection: Axis.vertical,
            // La durée totale pour faire défiler toute la liste une fois.
            // Ajustez cette valeur pour changer la vitesse.
            duration: const Duration(seconds: 100),
            delay: const Duration(seconds: 10),
            // CORRECTION : Le paramètre 'loopForever' est retiré car il n'existe pas.
            // Le widget boucle à l'infini par défaut.
          ),
        ),
      ],
    );
  }
}

// Widget réutilisable pour les cartes d'information (inchangé)
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
