import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../transaction_controller.dart';

class TransactionNoteField extends ConsumerWidget {
  const TransactionNoteField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(transactionControllerProvider.notifier);

    return TextField(
      controller: controller.noteController,
      decoration: const InputDecoration(
        labelText: "Note (optional)",
        border: OutlineInputBorder(),
      ),
    );
  }
}
