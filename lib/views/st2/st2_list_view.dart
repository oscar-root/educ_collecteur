// lib/st2/pages/st2_list_view.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
// --- IMPORTS DE VOTRE PROJET ---
import 'package:educ_collecteur/models/st2_model.dart';
// La ligne suivante est maintenant active pour la navigation
import 'package:educ_collecteur/views/st2/st2_detail_view.dart';

class ST2ListView extends StatefulWidget {
  const ST2ListView({super.key});

  @override
  State<ST2ListView> createState() => _ST2ListViewState();
}

class _ST2ListViewState extends State<ST2ListView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  late Future<List<ST2Model>> _formsFuture;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _formsFuture = _fetchUserForms();
    } else {
      _formsFuture = Future.value([]);
    }
  }

  // Dans lib/st2/pages/st2_list_view.dart

  // Dans lib/st2/pages/st2_list_view.dart

  Future<List<ST2Model>> _fetchUserForms() async {
    if (_currentUser == null) {
      print(
        "DEBUG: _fetchUserForms a été appelé mais _currentUser est null. Annulation.",
      );
      return [];
    }

    // Affiche l'UID de l'utilisateur pour lequel on recherche des formulaires.
    print("DEBUG: Recherche des formulaires pour l'UID : ${_currentUser!.uid}");

    try {
      // Affiche le nom de la collection et le filtre utilisé.
      print(
        "DEBUG: Requête sur la collection 'st2_forms' avec le filtre 'submittedBy'.",
      );

      final querySnapshot = await FirebaseFirestore.instance
          .collection('st2_forms')
          .where('submittedBy', isEqualTo: _currentUser!.uid)
          .orderBy('submittedAt', descending: true)
          .get();

      // AFFICHE LE NOMBRE DE DOCUMENTS TROUVÉS. C'EST LA LIGNE LA PLUS IMPORTANTE !
      print(
        "DEBUG: La requête Firestore a retourné ${querySnapshot.docs.length} document(s).",
      );

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      // Tente de convertir chaque document et attrape les erreurs de conversion.
      return querySnapshot.docs
          .map((doc) {
            try {
              print("DEBUG: Conversion du document ID: ${doc.id}");
              return ST2Model.fromFirestore(doc);
            } catch (e) {
              print(
                "ERREUR FATALE: Impossible de convertir le document ${doc.id}. Erreur: $e",
              );
              // Retourner null ou gérer l'erreur comme vous le souhaitez
              return null;
            }
          })
          .where((form) => form != null)
          .cast<ST2Model>()
          .toList(); // Filtre les documents qui n'ont pas pu être convertis
    } on FirebaseException catch (e) {
      print(
        "ERREUR FIREBASE: Une exception Firebase a eu lieu: ${e.message} (Code: ${e.code})",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur de chargement : ${e.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    } catch (e) {
      print(
        "ERREUR INATTENDUE: Une erreur générale a eu lieu dans _fetchUserForms: $e",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Une erreur inattendue est survenue : $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }

  Future<void> _refreshForms() async {
    if (_currentUser != null) {
      setState(() {
        _formsFuture = _fetchUserForms();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Formulaires ST2"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: _refreshForms,
          ),
        ],
      ),
      body: _currentUser == null
          ? const Center(child: Text("Veuillez vous connecter."))
          : FutureBuilder<List<ST2Model>>(
              future: _formsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshForms,
                    child: ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: 150.0),
                          child: Center(
                            child: Text(
                              "Aucun formulaire soumis pour le moment.",
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
                    padding: const EdgeInsets.all(8.0),
                    itemCount: forms.length,
                    itemBuilder: (context, index) {
                      final form = forms[index];
                      final submissionDate = form.submittedAt != null
                          ? DateFormat(
                              'dd/MM/yyyy à HH:mm',
                              'fr_FR',
                            ).format(form.submittedAt!)
                          : 'Date inconnue';

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
                              form.niveauEcole?.substring(0, 1).toUpperCase() ??
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
                            child: Text(
                              'Période: ${form.periode ?? 'N/A'}\nSoumis le: $submissionDate',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            // --- NAVIGATION VERS LA PAGE DE DÉTAILS ---
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ST2DetailView(form: form),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
