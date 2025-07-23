import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:educ_collecteur/views/st2/st2_form_view.dart';

class ChefDashboardView extends StatefulWidget {
  const ChefDashboardView({super.key});

  @override
  State<ChefDashboardView> createState() => _ChefDashboardViewState();
}

class _ChefDashboardViewState extends State<ChefDashboardView> {
  User? _firebaseUser;
  String? _fullName;
  String? _email;
  String? _schoolName;
  String? _profileUrl;
  bool _isLoading = true;
  bool _showForm = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        _fullName = data?['fullName'] ?? '';
        _email = data?['email'] ?? _firebaseUser!.email;
        _schoolName = data?['schoolName'] ?? '';
        _profileUrl = data?['photoUrl']; // ✅ Utilise la bonne clé Firestore
        _isLoading = false;
      });
    } else {
      setState(() {
        _fullName = '';
        _email = _firebaseUser!.email;
        _schoolName = '';
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
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage:
                  _profileUrl != null && _profileUrl!.isNotEmpty
                      ? NetworkImage(_profileUrl!)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Tableau de bord – Chef d’établissement',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        actions:
            _showForm
                ? [
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Fermer le formulaire',
                    onPressed: () {
                      setState(() => _showForm = false);
                    },
                  ),
                ]
                : null,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _showForm
              ? const ST2FormView()
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: Colors.indigo[50],
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fullName ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if ((_schoolName ?? '').isNotEmpty)
                            Text(
                              _schoolName!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if (_email != null)
                            Text(
                              _email!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1A73E8),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEducationCarousel(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      bottomNavigationBar:
          _showForm
              ? null
              : BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 8,
                elevation: 10,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: "remplir",
                        backgroundColor: Colors.green,
                        icon: const Icon(Icons.add),
                        label: const Text('Remplir ST2'),
                        onPressed: () {
                          setState(() {
                            _showForm = true;
                          });
                        },
                      ),
                      FloatingActionButton.extended(
                        heroTag: "consulter",
                        backgroundColor: Colors.blue,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Consulter ST2'),
                        onPressed:
                            () => Navigator.pushNamed(context, '/st2-list'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildEducationCarousel() {
    final List<String> quotes = [
      "« L’éducation est l’arme la plus puissante pour changer le monde. » – Nelson Mandela",
      "« Chaque enfant mérite une chance d’apprendre et de réussir. »",
      "« L’école est la fondation du progrès d’une nation. »",
      "« Investir dans l’éducation, c’est investir dans l’avenir. »",
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
        autoPlayInterval: const Duration(seconds: 5),
        viewportFraction: 0.9,
      ),
      items:
          quotes.map((text) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade400, Colors.indigo.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_fullName ?? ''),
            accountEmail: Text(_email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  _profileUrl != null && _profileUrl!.isNotEmpty
                      ? NetworkImage(_profileUrl!)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
            ),
            decoration: const BoxDecoration(color: Colors.indigo),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }
}
