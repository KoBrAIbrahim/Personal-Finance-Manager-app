import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardTransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const DashboardTransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (transactions.isEmpty) {
      return Center(
        child: Text(
          "No transactions found",
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isIncome = tx['type'] == 'income';
        final amount = (tx['amount'] ?? 0).toDouble();
        final category = tx['category'] ?? '';
        final note = tx['note'] ?? '';
        final date = (tx['date'] as Timestamp).toDate();

        return GestureDetector(
          onLongPress: () => context.push('/edit', extra: tx),
          onDoubleTap: () => _confirmDelete(context, tx['id']),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isIncome ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        "$category • ${date.toLocal().toString().split(' ')[0]}",
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey[400]
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${isIncome ? '+' : '-'} \$${amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit,
                      color: isDark ? Colors.grey[300] : Colors.grey),
                  onPressed: () => context.push('/edit', extra: tx),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(context, tx['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Transaction"),
        content: const Text("Are you sure you want to delete this transaction?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await FirebaseFirestore.instance
                  .collection('transactions')
                  .doc(docId)
                  .delete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Transaction deleted")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
