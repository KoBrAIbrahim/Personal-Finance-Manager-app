import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../transaction_controller.dart';

class TransactionDatePicker extends ConsumerWidget {
  const TransactionDatePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionControllerProvider);
    final controller = ref.read(transactionControllerProvider.notifier);

    return Row(
      children: [
        const Text("Date: "),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: state.date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) controller.setDate(picked);
          },
          child: Text(
            "${state.date.toLocal()}".split(' ')[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
