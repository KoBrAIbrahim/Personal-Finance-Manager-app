import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalsState {
  final bool isSaving;
  final String selectedCategory;

  GoalsState({required this.isSaving, required this.selectedCategory});

  GoalsState copyWith({bool? isSaving, String? selectedCategory}) {
    return GoalsState(
      isSaving: isSaving ?? this.isSaving,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

final goalsControllerProvider = NotifierProvider<GoalsController, GoalsState>(
  () => GoalsController(),
);

class GoalsController extends Notifier<GoalsState> {
  final savingTitleController = TextEditingController();
  final savingAmountController = TextEditingController();
  final expenseLimitController = TextEditingController();

  final List<String> categories = ['Food', 'Transport', 'Shopping', 'Other'];

  String? get userEmail => FirebaseAuth.instance.currentUser?.email;

  @override
  GoalsState build() => GoalsState(isSaving: false, selectedCategory: 'Food');

  void setCategory(String value) {
    state = state.copyWith(selectedCategory: value);
  }

  Future<void> saveSavingGoal(BuildContext context) async {
    final title = savingTitleController.text.trim();
    final amount = double.tryParse(savingAmountController.text.trim()) ?? 0;

    if (userEmail == null || title.isEmpty || amount <= 0) return;

    state = state.copyWith(isSaving: true);
    try {
      await FirebaseFirestore.instance.collection('goals').add({
        'type': 'saving',
        'completed': false,
        'title': title,
        'amount': amount,
        'userEmail': userEmail,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saving goal added successfully!")),
      );

      savingTitleController.clear();
      savingAmountController.clear();
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<void> saveExpenseLimit(BuildContext context) async {
    final limit = double.tryParse(expenseLimitController.text.trim()) ?? 0;

    if (userEmail == null || limit <= 0) return;

    state = state.copyWith(isSaving: true);
    try {
      await FirebaseFirestore.instance.collection('goals').add({
        'type': 'expense_limit',
        'category': state.selectedCategory,
        'limit': limit,
        'userEmail': userEmail,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense limit added successfully!")),
      );

      expenseLimitController.clear();
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalsControllerProvider);
    final controller = ref.read(goalsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Monthly Goals"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body:
          state.isSaving
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Saving Goal",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Set a goal and the amount you want to save."),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller.savingTitleController,
                      decoration: const InputDecoration(
                        labelText: "Saving for (e.g. Laptop)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller.savingAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Target Amount (\$)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => controller.saveSavingGoal(context),
                      child: const Text("Save Saving Goal"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                      ),
                    ),

                    const Divider(height: 40),

                    const Text(
                      "💸 Expense Limit",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Choose a category and set a spending limit."),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: state.selectedCategory,
                      items:
                          controller.categories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                      onChanged: (val) => controller.setCategory(val!),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Category",
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller.expenseLimitController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Limit Amount (\$)",
                        border: OutlineInputBorder(),
                      ),
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
                ),
              ),
    );
  }
}
