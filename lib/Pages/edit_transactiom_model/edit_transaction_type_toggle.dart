import 'package:flutter/material.dart';
import 'package:app/Pages/edit_transactiom_model/edit_transaction_controller.dart' show currentTransactionProvider, editTransactionControllerProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditTransactionTypeToggle extends ConsumerWidget {
  const EditTransactionTypeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(editTransactionControllerProvider(ref.watch(currentTransactionProvider)));

    return ToggleButtons(
      isSelected: [
        controller.type == 'income',
        controller.type == 'expense',
      ],
      onPressed: (index) => controller.setType(index == 0 ? 'income' : 'expense'),
      borderRadius: BorderRadius.circular(12),
      selectedColor: Colors.white,
      fillColor: controller.type == 'income' ? Colors.green : Colors.red,
      color: Colors.black,
      constraints: const BoxConstraints(minWidth: 100, minHeight: 40),
      children: const [Text("Income"), Text("Expense")],
    );
  }
}
