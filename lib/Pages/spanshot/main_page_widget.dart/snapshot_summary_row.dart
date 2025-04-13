import 'package:flutter/material.dart';

class SnapshotSummaryRow extends StatelessWidget {
  final double income;
  final double expense;

  const SnapshotSummaryRow({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;

    return Row(
      children: [
        SummaryBox(title: "Income", amount: income, color: Colors.green),
        const SizedBox(width: 10),
        SummaryBox(title: "Expense", amount: expense, color: Colors.red),
        const SizedBox(width: 10),
        SummaryBox(title: "Balance", amount: balance, color: Colors.teal),
      ],
    );
  }
}

class SummaryBox extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const SummaryBox({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              "\$${amount.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
