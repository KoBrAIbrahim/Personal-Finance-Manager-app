import 'package:app/Pages/Goals/goal_model.dart/custom_goal_input.dart';
import 'package:app/Pages/Goals/goal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseLimitSection extends ConsumerWidget {
  const ExpenseLimitSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalsControllerProvider);
    final controller = ref.read(goalsControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "💸 Expense Limit",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text("Choose a category and set a spending limit."),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: state.selectedCategory,
          items: controller.categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) => controller.setCategory(val!),
          decoration: const InputDecoration(
            labelText: "Category",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        CustomGoalInput(
          label: "Limit Amount (\$)",
          controller: controller.expenseLimitController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => controller.saveExpenseLimit(context),
          child: const Text("Save Expense Limit"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B4D8),
          ),
        ),
      ],
    );
  }
}
