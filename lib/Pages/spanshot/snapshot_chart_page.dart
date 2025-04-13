import 'package:app/Pages/spanshot/snapshot_chart/chart_legend.dart';
import 'package:app/Pages/spanshot/snapshot_chart/custom_chart_appbar.dart';
import 'package:app/Pages/spanshot/snapshot_chart/snapshot_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


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
      appBar: const CustomChartAppBar(),
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
                Expanded(child: SnapshotLineChart(snapshots: snapshots)),
                const SizedBox(height: 20),
                const ChartLegend(),
              ],
            ),
          );
        },
      ),
    );
  }
}
