// lib/views/dashboard/statistics_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:educ_collecteur/models/st2_model.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<List<ST2Model>> _formsFuture;

  @override
  void initState() {
    super.initState();
    _formsFuture = _fetchAllForms();
  }

  Future<List<ST2Model>> _fetchAllForms() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('st2_forms').get();
    return querySnapshot.docs
        .map(
          (doc) => ST2Model.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          ),
        )
        .toList();
  }

  /// Traite les données et retourne un map de [Catégorie -> Nombre].
  Map<String, int> _processData(List<ST2Model> forms, String field) {
    Map<String, int> counts = {};
    for (var form in forms) {
      String key;
      switch (field) {
        case 'regimeGestion':
          key = form.regimeGestion ?? 'Non spécifié';
          break;
        case 'sousDivision':
          key = form.sousDivision ?? 'Non spécifié';
          break;
        case 'niveauEcole':
          key = form.niveauEcole?.toUpperCase() ?? 'Non spécifié';
          break;
        default:
          key = 'Inconnu';
      }
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  Widget _buildPieChartCard({
    required String title,
    required Map<String, int> data,
  }) {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.cyan,
      Colors.pink,
      Colors.brown,
      Colors.grey,
    ];
    int colorIndex = 0;

    final List<PieChartSectionData> sections =
        data.entries.map((entry) {
          final color = colors[colorIndex % colors.length];
          colorIndex++;
          return PieChartSectionData(
            color: color,
            value: entry.value.toDouble(),
            title: '${entry.value}',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black, blurRadius: 2)],
            ),
          );
        }).toList();

    final List<Widget> legend =
        data.entries.map((entry) {
          // Pour retrouver la couleur correspondante
          final sectionIndex = data.keys.toList().indexOf(entry.key);
          final color = colors[sectionIndex % colors.length];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                Container(width: 16, height: 16, color: color),
                const SizedBox(width: 8),
                Text("${entry.key}: ${entry.value}"),
              ],
            ),
          );
        }).toList();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child:
                  sections.isEmpty
                      ? const Center(child: Text("Pas de données"))
                      : PieChart(
                        PieChartData(
                          sections: sections,
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Légende",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 16.0, runSpacing: 8.0, children: legend),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistiques Globales")),
      body: FutureBuilder<List<ST2Model>>(
        future: _formsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Erreur : ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(
              child: Text("Aucune donnée pour les statistiques."),
            );

          final forms = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildPieChartCard(
                  title: "Répartition par Régime de Gestion",
                  data: _processData(forms, 'regimeGestion'),
                ),
                _buildPieChartCard(
                  title: "Répartition par Sous-division",
                  data: _processData(forms, 'sousDivision'),
                ),
                _buildPieChartCard(
                  title: "Répartition par Niveau d'École",
                  data: _processData(forms, 'niveauEcole'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
