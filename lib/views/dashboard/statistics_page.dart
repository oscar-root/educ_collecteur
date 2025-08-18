// lib/views/dashboard/statistics_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:educ_collecteur/controllers/st2_controller.dart';
import 'package:educ_collecteur/models/st2_model.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final ST2Controller _st2Controller = ST2Controller();
  late Future<List<ST2Model>> _formsFuture;

  @override
  void initState() {
    super.initState();
    _loadValidatedForms();
  }

  void _loadValidatedForms() {
    // On récupère uniquement les formulaires qui ont été validés pour les statistiques
    _formsFuture = _st2Controller.getForms(context: context, status: 'Validé');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ST2Model>>(
      future: _formsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "Aucune donnée validée disponible pour générer des statistiques.",
            ),
          );
        }

        final forms = snapshot.data!;
        // --- Calcul des statistiques ---
        final int totalEcoles = forms.length;
        int totalEleves = 0;
        int totalGarcons = 0;
        int totalFilles = 0;
        int totalEnseignants = 0;

        for (var form in forms) {
          totalEnseignants += form.totalEnseignants;
          for (var effectif in form.effectifsEleves.values) {
            totalEleves += effectif.total;
            totalGarcons += effectif.garcons;
            totalFilles += effectif.filles;
          }
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() => _loadValidatedForms()),
          child: GridView.count(
            padding: const EdgeInsets.all(16.0),
            crossAxisCount: 2, // 2 cartes par ligne
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _StatisticCard(
                icon: Icons.school_outlined,
                label: "Écoles Ayant Soumis",
                value: totalEcoles.toString(),
                color: Colors.blue,
              ),
              _StatisticCard(
                icon: Icons.groups_outlined,
                label: "Total Élèves Inscrits",
                value: totalEleves.toString(),
                color: Colors.green,
              ),
              _StatisticCard(
                icon: Icons.escalator_warning_outlined,
                label: "Total Enseignants",
                value: totalEnseignants.toString(),
                color: Colors.orange,
              ),
              _StatisticCard(
                icon: Icons.person_outline,
                label: "Élèves / Enseignant",
                value:
                    totalEnseignants > 0
                        ? (totalEleves / totalEnseignants).toStringAsFixed(1)
                        : "N/A",
                color: Colors.purple,
              ),
              _StatisticCard(
                icon: Icons.male_outlined,
                label: "Garçons",
                value: totalGarcons.toString(),
                color: Colors.teal,
              ),
              _StatisticCard(
                icon: Icons.female_outlined,
                label: "Filles",
                value: totalFilles.toString(),
                color: Colors.pink,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Un widget réutilisable pour afficher une carte de statistique.
class _StatisticCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatisticCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
