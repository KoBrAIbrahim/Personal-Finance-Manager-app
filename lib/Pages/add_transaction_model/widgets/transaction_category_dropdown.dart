import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../transaction_controller.dart';

class TransactionCategoryDropdown extends ConsumerWidget {
  const TransactionCategoryDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionControllerProvider);
    final controller = ref.read(transactionControllerProvider.notifier);

    return DropdownButtonFormField<String>(
      value: state.category,
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
