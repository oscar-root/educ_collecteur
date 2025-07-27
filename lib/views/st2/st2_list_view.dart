import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ST2ListView extends StatelessWidget {
  const ST2ListView({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _getMyForms() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('formulaires_st2')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes formulaires ST2"),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _getMyForms(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de chargement"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun formulaire trouvé."));
          }

          final forms = snapshot.data!.docs;

          return ListView.separated(
            itemCount: forms.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final data = forms[index].data();
              final nomEts = data['nomEts'] ?? 'Établissement inconnu';
              final periode = data['periode'] ?? 'Période non précisée';
              final province = data['province'] ?? 'Province inconnue';
              final timestamp = data['timestamp'] as Timestamp?;
              final date =
                  timestamp != null ? timestamp.toDate() : DateTime.now();

              return ListTile(
                leading: const Icon(
                  Icons.description_outlined,
                  color: Colors.indigo,
                ),
                title: Text(
                  nomEts,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Période : $periode\nProvince : $province"),
                trailing: Text(
                  "${date.day}/${date.month}/${date.year}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  // 👉 Tu peux ajouter ici une navigation vers une vue détaillée
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: Text("Formulaire - $nomEts"),
                          content: Text(
                            "Période : $periode\nProvince : $province",
                          ),
                          actions: [
                            TextButton(
                              child: const Text("Fermer"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
