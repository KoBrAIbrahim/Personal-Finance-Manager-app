import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final snapshotListProvider = FutureProvider.autoDispose<List<DocumentSnapshot>>(
  (ref) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return [];

    final query =
        await FirebaseFirestore.instance
            .collection('snapshots')
            .where('userEmail', isEqualTo: email)
            .orderBy('start')
            .get();

    return query.docs;
  },
);

class SnapshotChartPage extends ConsumerWidget {
  const SnapshotChartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(snapshotListProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0077B6),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Snapshot Chart",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: snapshotAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text("Failed to load data.")),
        data: (snapshots) {
          if (snapshots.isEmpty) {
            return const Center(child: Text("No snapshots to display."));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Monthly Overview",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      lineBarsData: _getLines(snapshots),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index < 0 || index >= snapshots.length)
                                return const SizedBox.shrink();
                              final date =
                                  (snapshots[index]['start'] as Timestamp)
                                      .toDate();
                              return Text(
                                DateFormat.MMM().format(date),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 200,
                            reservedSize: 40,
                            getTitlesWidget:
                                (value, meta) => Text("\$${value.toInt()}"),
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLegend(),
              ],
            ),
          );
        },
      ),
    );
  }

  List<LineChartBarData> _getLines(List<DocumentSnapshot> snapshots) {
    return [
      _buildLine(snapshots, 'income', Colors.green),
      _buildLine(snapshots, 'expense', Colors.red),
      _buildLine(snapshots, 'balance', Colors.blue),
    ];
  }

  LineChartBarData _buildLine(
    List<DocumentSnapshot> snapshots,
    String field,
    Color color,
  ) {
    return LineChartBarData(
      spots: List.generate(snapshots.length, (index) {
        final value = (snapshots[index][field] ?? 0).toDouble();
        return FlSpot(index.toDouble(), value);
      }),
      isCurved: true,
      color: color,
      barWidth: 4,
      belowBarData: BarAreaData(show: false),
      dotData: FlDotData(show: true),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _Legend(color: Colors.green, label: 'Income'),
        SizedBox(width: 20),
        _Legend(color: Colors.red, label: 'Expense'),
        SizedBox(width: 20),
        _Legend(color: Colors.blue, label: 'Balance'),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
