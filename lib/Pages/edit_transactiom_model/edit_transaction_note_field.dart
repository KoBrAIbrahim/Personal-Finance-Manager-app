import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/Pages/edit_transactiom_model/edit_transaction_controller.dart' show currentTransactionProvider, editTransactionControllerProvider;


class EditTransactionNoteField extends ConsumerWidget {
  const EditTransactionNoteField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(editTransactionControllerProvider(ref.watch(currentTransactionProvider)));

    return TextField(
      controller: controller.noteController,
      decoration: const InputDecoration(
        labelText: "Note (optional)",
        border: OutlineInputBorder(),
      ),
    );
  }
}
