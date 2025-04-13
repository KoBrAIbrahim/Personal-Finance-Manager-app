import 'package:app/Pages/edit_transactiom_model/edit_transaction_controller.dart' show currentTransactionProvider, editTransactionControllerProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditTransactionAmountField extends ConsumerWidget {
  const EditTransactionAmountField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(editTransactionControllerProvider(ref.watch(currentTransactionProvider)));

    return TextField(
      controller: controller.amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Amount",
        border: OutlineInputBorder(),
      ),
    );
  }
}
