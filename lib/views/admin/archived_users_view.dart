import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ArchivedUsersView extends StatelessWidget {
  const ArchivedUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final archivedStream =
        FirebaseFirestore.instance
            .collection('users')
            .where('archived', isEqualTo: true)
            .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text("Comptes archivés")),
      body: StreamBuilder<QuerySnapshot>(
        stream: archivedStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text("Aucun compte archivé."));
          }

          return ListView(
            children:
                users.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.archive),
                    title: Text(data['fullName'] ?? ''),
                    subtitle: Text(data['email'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.restore, color: Colors.green),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(doc.id)
                            .update({'archived': false});
                      },
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
