import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../transaction_controller.dart';

class TransactionTypeToggle extends ConsumerWidget {
  const TransactionTypeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionControllerProvider);
    final controller = ref.read(transactionControllerProvider.notifier);

    return ToggleButtons(
      isSelected: [state.type == 'income', state.type == 'expense'],
      onPressed: (index) =>
          controller.setType(index == 0 ? 'income' : 'expense'),
      borderRadius: BorderRadius.circular(12),
      selectedColor: Colors.white,
      fillColor: state.type == 'income' ? Colors.green : Colors.red,
      color: Colors.black,
      constraints: const BoxConstraints(minWidth: 100, minHeight: 40),
      children: const [Text("Income"), Text("Expense")],
    );
  }
}
