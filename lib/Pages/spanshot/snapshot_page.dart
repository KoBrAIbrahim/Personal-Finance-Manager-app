import 'package:app/Pages/spanshot/main_page_widget.dart/snapshot_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonthlySnapshotPage extends ConsumerWidget {
  const MonthlySnapshotPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(snapshotControllerProvider);
    final controller = ref.read(snapshotControllerProvider.notifier);
    final balance = state.income - state.expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Snapshot"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Period: ${_formatDate(state.startDate)} - ${_formatDate(state.endDate)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => controller.pickEndDate(context),
                    icon: const Icon(Icons.date_range),
                    label: const Text("Change End Date"),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _summaryBox("Income", state.income, Colors.green),
                      const SizedBox(width: 10),
                      _summaryBox("Expense", state.expense, Colors.red),
                      const SizedBox(width: 10),
                      _summaryBox("Balance", balance, Colors.teal),
                    ],
                  ),
                  const SizedBox(height: 24),
                  state.snapshotExists
                      ? const Text(
                          "Snapshot already exists for this period.",
                          style: TextStyle(color: Colors.grey),
                        )
                      : ElevatedButton.icon(
                          onPressed: () => controller.takeSnapshot(context),
                          icon: const Icon(Icons.camera),
                          label: const Text("Take Snapshot"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B4D8),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '---';
    return date.toLocal().toString().split(' ')[0];
  }

  Widget _summaryBox(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "\$${amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
