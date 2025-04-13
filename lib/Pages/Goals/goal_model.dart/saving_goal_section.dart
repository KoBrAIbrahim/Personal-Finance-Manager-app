import 'package:app/Pages/Goals/goal_model.dart/custom_goal_input.dart';
import 'package:app/Pages/Goals/goal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SavingGoalSection extends ConsumerWidget {
  const SavingGoalSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(goalsControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Saving Goal",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text("Set a goal and the amount you want to save."),
        const SizedBox(height: 10),
        CustomGoalInput(
          label: "Saving for (e.g. Laptop)",
          controller: controller.savingTitleController,
        ),
        const SizedBox(height: 10),
        CustomGoalInput(
          label: "Target Amount (\$)",
          controller: controller.savingAmountController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => controller.saveSavingGoal(context),
          child: const Text("Save Saving Goal"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B4D8),
          ),
        ),
      ],
    );
  }
}
