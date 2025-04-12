import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SnapshotChartPage extends StatefulWidget {
  const SnapshotChartPage({super.key});

  @override
  State<SnapshotChartPage> createState() => _SnapshotChartPageState();
}

class _SnapshotChartPageState extends State<SnapshotChartPage> {
  List<DocumentSnapshot> _snapshots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSnapshots();
  }

  Future<void> _loadSnapshots() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    final query = await FirebaseFirestore.instance
        .collection('snapshots')
        .where('userEmail', isEqualTo: email)
        .orderBy('start')
        .get();

    setState(() {
      _snapshots = query.docs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () {
                      context.pop();
                    },
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _snapshots.isEmpty
              ? const Center(child: Text("No snapshots to display."))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Monthly Overview",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            lineBarsData: _getLines(),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index < 0 || index >= _snapshots.length)
                                      return const SizedBox.shrink();
                                    final date = (_snapshots[index]['start']
                                            as Timestamp)
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
                                  getTitlesWidget: (value, meta) {
                                    return Text("\$${value.toInt()}");
                                  },
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
                ),
    );
  }

  List<LineChartBarData> _getLines() {
    return [
      _buildLine('income', Colors.green),
      _buildLine('expense', Colors.red),
      _buildLine('balance', Colors.blue),
    ];
  }

  LineChartBarData _buildLine(String field, Color color) {
    return LineChartBarData(
      spots: List.generate(_snapshots.length, (index) {
        final value = (_snapshots[index][field] ?? 0).toDouble();
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
