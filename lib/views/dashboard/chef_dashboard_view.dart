import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_view.dart';
import '../st2/pages/st2_form_page1.dart';
import '../st2/pages/st2_form_page2.dart';
import '../st2/pages/st2_form_page3.dart';
import '../st2/pages/st2_form_page4.dart';
import '../st2/st2_list_view.dart';

class ChefDashboardView extends StatefulWidget {
  const ChefDashboardView({super.key});

  @override
  State<ChefDashboardView> createState() => _ChefDashboardViewState();
}

class _ChefDashboardViewState extends State<ChefDashboardView> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  String fullName = "Chargement...";
  String email = "";
  String photoUrl = "";
  String niveauEcole = "secondaire";

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
      final data = doc.data();
      if (data != null) {
        setState(() {
          fullName = data['fullName'] ?? 'Chef';
          email = data['email'] ?? '';
          photoUrl = data['photoUrl'] ?? '';
          niveauEcole = data['niveauEcole'] ?? 'secondaire';
        });
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  void _startST2Form() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ST2FormPage1(
              onSave: (page1Data) {
                // Tu peux ici stocker les données
              },
              onNext: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ST2FormPage2(
                          onSave: (page2Data) {},
                          onPrevious: () => Navigator.pop(context),
                          onNext: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ST2FormPage3(
                                      niveauEcole: niveauEcole,
                                      onSave: (page3Data) {},
                                      onPrevious: () => Navigator.pop(context),
                                      onNext: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => ST2FormPage4(
                                                  niveauEcole: niveauEcole,
                                                  onSave: (page4Data) {
                                                    // ici tu peux combiner toutes les données
                                                  },
                                                  onPrevious:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  onSubmit: () {
                                                    Navigator.popUntil(
                                                      context,
                                                      (route) => route.isFirst,
                                                    );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "✅ Formulaire soumis avec succès !",
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                              ),
                            );
                          },
                        ),
                  ),
                );
              },
            ),
      ),
    );
  }

  final List<Widget> _pages = [_AccueilPage(), ST2ListView()];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        drawer: _buildSidebar(),
        appBar: AppBar(
          title: const Text('Dashboard – Chef d’établissement'),
          backgroundColor: Colors.indigo,
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.indigo,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Consulter ST2',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _startST2Form,
          icon: const Icon(Icons.edit_document),
          label: const Text("Remplir ST2"),
        ),
      ),
    );
  }

  Drawer _buildSidebar() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(fullName),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
            ),
            decoration: const BoxDecoration(color: Colors.indigo),
          ),
          ListTile(
            leading: const Icon(Icons.edit_document),
            title: const Text('Remplir ST2'),
            onTap: () {
              Navigator.pop(context);
              _startST2Form();
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Consulter ST2'),
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: _isDarkMode,
                onChanged: (val) => setState(() => _isDarkMode = val),
              ),
            ],
          ),
          const Spacer(),
          const Divider(),
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
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Votre session",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        CarouselSlider(
          options: CarouselOptions(
            height: 220,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            viewportFraction: 0.85,
            autoPlayCurve: Curves.fastOutSlowIn,
            autoPlayInterval: const Duration(seconds: 4),
          ),
          items: [
            _carouselCard("Remplissez le ST2 facilement", Icons.edit_document),
            _carouselCard(
              "Consultez vos données à tout moment",
              Icons.list_alt,
            ),
            _carouselCard("Protégez vos accès et données", Icons.security),
          ],
        ),
      ],
    );
  }

  static Widget _carouselCard(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(3, 6)),
        ],
      ),
      child: Center(
        child: ListTile(
          leading: Icon(icon, size: 36, color: Colors.white),
          title: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
