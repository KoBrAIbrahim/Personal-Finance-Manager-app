import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../transaction_controller.dart';

class TransactionAmountField extends ConsumerWidget {
  const TransactionAmountField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(transactionControllerProvider.notifier);

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
