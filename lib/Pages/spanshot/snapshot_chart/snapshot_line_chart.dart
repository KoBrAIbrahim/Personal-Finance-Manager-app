import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SnapshotLineChart extends StatelessWidget {
  final List<DocumentSnapshot> snapshots;

  const SnapshotLineChart({super.key, required this.snapshots});

  @override
  Widget build(BuildContext context) {
    return LineChart(
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
                    (snapshots[index]['start'] as Timestamp).toDate();
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
              getTitlesWidget: (value, meta) => Text("\$${value.toInt()}"),
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
}
