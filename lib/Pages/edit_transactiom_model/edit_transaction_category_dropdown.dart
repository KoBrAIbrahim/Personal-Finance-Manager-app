import 'package:app/Pages/edit_transactiom_model/edit_transaction_controller.dart' show currentTransactionProvider, editTransactionControllerProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditTransactionCategoryDropdown extends ConsumerWidget {
  const EditTransactionCategoryDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(editTransactionControllerProvider(ref.watch(currentTransactionProvider)));

    return DropdownButtonFormField<String>(
      value: controller.selectedCategory,
      items: controller.categories
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (val) => controller.setCategory(val!),
      decoration: const InputDecoration(
        labelText: "Category",
        border: OutlineInputBorder(),
      ),
    );
  }
}
