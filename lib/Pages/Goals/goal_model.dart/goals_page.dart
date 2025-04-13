import 'package:app/Pages/Goals/goal_model.dart/expense_limit_section.dart';
import 'package:app/Pages/Goals/goal_model.dart/saving_goal_section.dart';
import 'package:app/Pages/Goals/goal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaving = ref.watch(goalsControllerProvider).isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Monthly Goals"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SavingGoalSection(),
                  Divider(height: 40),
                  ExpenseLimitSection(),
                ],
              ),
            ),
    );
  }
}
