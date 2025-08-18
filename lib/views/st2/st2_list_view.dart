// lib/st2/pages/st2_list_view.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- IMPORTS DE VOTRE PROJET ---
import 'package:educ_collecteur/controllers/st2_controller.dart';
import 'package:educ_collecteur/models/st2_model.dart';
import 'package:educ_collecteur/views/st2/st2_detail_view.dart';
import 'package:educ_collecteur/views/st2/pages/st2_form_page.dart'; // AJOUTÉ: Pour la navigation

class ST2ListView extends StatefulWidget {
  const ST2ListView({super.key});

  @override
  State<ST2ListView> createState() => _ST2ListViewState();
}

class _ST2ListViewState extends State<ST2ListView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ST2Controller _st2Controller =
      ST2Controller(); // AMÉLIORÉ: Utilisation du contrôleur
  User? _currentUser;
  late Future<List<ST2Model>> _formsFuture;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(
      'fr_FR',
      null,
    ); // AJOUTÉ: Pour le format de date local
    _currentUser = _auth.currentUser;
    _loadForms();
  }

  // AMÉLIORÉ: La logique de récupération est maintenant dans une méthode claire
  void _loadForms() {
    if (_currentUser != null) {
      // La vue demande simplement les formulaires au contrôleur, sans savoir comment il les obtient.
      _formsFuture = _st2Controller.getForms(
        context: context,
        userId: _currentUser!.uid,
      );
    } else {
      _formsFuture = Future.value([]); // Pas d'utilisateur, pas de formulaires.
    }
  }

  // AMÉLIORÉ: Le rafraîchissement met à jour l'état avec la nouvelle future
  Future<void> _refreshForms() async {
    setState(() {
      _loadForms();
    });
  }

  // AJOUTÉ: Méthode pour naviguer vers la page de création
  void _navigateToCreateForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ST2FormPage()),
    ).then((_) => _refreshForms()); // Rafraîchit la liste au retour
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Formulaires Soumis"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: _refreshForms,
          ),
        ],
      ),
      body:
          _currentUser == null
              ? const Center(
                child: Text(
                  "Veuillez vous connecter pour voir vos formulaires.",
                ),
              )
              : FutureBuilder<List<ST2Model>>(
                future: _formsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refreshForms,
                      child: ListView(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(top: 150.0),
                            child: Center(
                              child: Text(
                                "Aucun formulaire soumis pour le moment.\nAppuyez sur '+' pour en créer un.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final forms = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: _refreshForms,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        8,
                        8,
                        8,
                        80,
                      ), // Espace pour le FAB
                      itemCount: forms.length,
                      itemBuilder: (context, index) {
                        final form = forms[index];
                        final submissionDate =
                            form.submittedAt != null
                                ? DateFormat(
                                  'dd/MM/yyyy à HH:mm',
                                  'fr_FR',
                                ).format(form.submittedAt!)
                                : 'Date inconnue';

                        // AMÉLIORÉ: Widget de statut pour une meilleure visualisation
                        final statusWidget = _buildStatusChip(form.status);

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              child: Text(
                                form.niveauEcole
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            title: Text(
                              form.schoolName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Période: ${form.periode ?? 'N/A'}\nSoumis le: $submissionDate',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  statusWidget,
                                ],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ST2DetailView(form: form),
                                ),
                              ).then(
                                (_) => _refreshForms(),
                              ); // AMÉLIORÉ: Rafraîchit au retour
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      // AJOUTÉ: Bouton pour créer un nouveau formulaire
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateForm,
        label: const Text('Nouveau Formulaire'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  // AJOUTÉ: Widget helper pour la puce de statut
  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    String label;

    switch (status) {
      case 'Validé':
        backgroundColor = Colors.green.shade100;
        label = 'Validé';
        break;
      case 'Rejeté':
        backgroundColor = Colors.red.shade100;
        label = 'Rejeté';
        break;
      case 'Soumis':
      default:
        backgroundColor = Colors.blue.shade100;
        label = 'Soumis';
        break;
    }

    return Chip(
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      side: BorderSide.none,
    );
  }
}
