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

  // Palette de couleurs pour différencier les données dans les graphiques
  final List<Color> _chartColors = const [
    Color(0xFF0293ee),
    Color(0xFFf8b250),
    Color(0xFF845bef),
    Color(0xFF13d38e),
    Color(0xFFff6384),
    Color(0xFF36a2eb),
    Color(0xFFfd6b19),
    Color(0xFFffcd56),
  ];

  @override
  void initState() {
    super.initState();
    _formsFuture = _fetchAllForms();
  }

  Future<List<ST2Model>> _fetchAllForms() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('st2_forms').get();
    return querySnapshot.docs
        .map((doc) => ST2Model.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistiques Globales")),
      body: FutureBuilder<List<ST2Model>>(
        future: _formsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("Aucune donnée pour les statistiques."));
          }

          final forms = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // --- 1. HISTOGRAMME (BAR CHART) ---
                _buildBarChartCard(
                  title: "Répartition par Régime de Gestion",
                  data: _processData(forms, 'regimeGestion'),
                ),
                const SizedBox(height: 24),
                // --- 2. DIAGRAMME EN SECTEUR (PIE CHART) ---
                _buildPieChartCard(
                  title: "Répartition par Sous-division",
                  data: _processData(forms, 'sousDivision'),
                ),
                const SizedBox(height: 24),
                // --- 3. DIAGRAMME EN BÂTONS (BAR CHART) ---
                _buildBarChartCard(
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

  // Widget pour le diagramme en secteur (Pie Chart)
  Widget _buildPieChartCard(
      {required String title, required Map<String, int> data}) {
    final sections = data.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final dataEntry = entry.value;
      final color = _chartColors[index % _chartColors.length];
      return PieChartSectionData(
        color: color,
        value: dataEntry.value.toDouble(),
        title: '${dataEntry.value}',
        radius: 80,
        titleStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: sections.isEmpty
                  ? const Center(child: Text("Pas de données"))
                  : PieChart(PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40)),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: data.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final dataEntry = entry.value;
                final color = _chartColors[index % _chartColors.length];
                return _buildLegendItem(
                    color: color,
                    text: "${dataEntry.key} (${dataEntry.value})");
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour l'histogramme (Bar Chart)
  Widget _buildBarChartCard(
      {required String title, required Map<String, int> data}) {
    if (data.isEmpty) {
      return Card(
          child: ListTile(
              title: Text(title), subtitle: const Text("Pas de données")));
    }

    final barGroups = data.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final dataEntry = entry.value;
      final color = _chartColors[index % _chartColors.length];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: dataEntry.value.toDouble(),
            color: color,
            width: 16,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4), topRight: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  alignment: BarChartAlignment.spaceAround,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value % 1 != 0)
                                return const SizedBox.shrink();
                              return Text(value.toInt().toString(),
                                  style: Theme.of(context).textTheme.bodySmall);
                            })),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= data.keys.length)
                                return const SizedBox.shrink();
                              return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 4.0,
                                  child: Transform.rotate(
                                      angle: -0.5,
                                      child: Text(data.keys.elementAt(index),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall)));
                            })),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                      show: true,
                      border: Border(
                          bottom:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                          left: BorderSide(
                              color: Colors.grey.shade300, width: 1))),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget réutilisable pour les éléments de la légende
  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
