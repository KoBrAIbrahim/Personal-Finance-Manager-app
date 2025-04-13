import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final snapshotDetailsProvider =
    FutureProvider.family<DocumentSnapshot?, String>((ref, snapshotId) async {
      final doc =
          await FirebaseFirestore.instance
              .collection('snapshots')
              .doc(snapshotId)
              .get();
      return doc.exists ? doc : null;
    });

class SnapshotDetailsPage extends ConsumerWidget {
  final String snapshotId;
  const SnapshotDetailsPage({super.key, required this.snapshotId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(snapshotDetailsProvider(snapshotId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Snapshot Details"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: snapshotAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text("Error loading snapshot")),
        data: (doc) {
          if (doc == null) {
            return const Center(child: Text("Snapshot not found"));
          }

          final data = doc.data() as Map<String, dynamic>;
          final start = (data['start'] as Timestamp).toDate();
          final end = (data['end'] as Timestamp).toDate();
          final createdAt = (data['createdAt'] as Timestamp).toDate();
          final income = (data['income'] ?? 0).toDouble();
          final expense = (data['expense'] ?? 0).toDouble();
          final balance = (data['balance'] ?? 0).toDouble();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoTile(
                  icon: Icons.calendar_month,
                  title: "Period",
                  value:
                      "${DateFormat.yMMMd().format(start)} - ${DateFormat.yMMMd().format(end)}",
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard("Income", income, Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard("Expense", expense, Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _summaryCard("Balance", balance, Colors.teal),
                const Spacer(),
                Center(
                  child: Text(
                    "Created at: ${DateFormat.yMMMd().add_jm().format(createdAt)}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCard(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "\$${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
