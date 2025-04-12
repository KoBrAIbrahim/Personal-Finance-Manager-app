import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final userEmail = FirebaseAuth.instance.currentUser?.email;

  final TextEditingController _savingTitleController = TextEditingController();
  final TextEditingController _savingAmountController = TextEditingController();

  final List<String> _categories = ['Food', 'Transport', 'Shopping', 'Other'];
  String _selectedCategory = 'Food';
  final TextEditingController _expenseLimitController = TextEditingController();

  bool _isSaving = false;

  Future<void> _saveSavingGoal() async {
    if (userEmail == null) return;
    final title = _savingTitleController.text.trim();
    final amount = double.tryParse(_savingAmountController.text.trim()) ?? 0;

    if (title.isEmpty || amount <= 0) return;

    setState(() => _isSaving = true);
    await FirebaseFirestore.instance.collection('goals').add({
      'type': 'saving',
      'completed': false,
      'title': title,
      'amount': amount,
      'userEmail': userEmail,
      'createdAt': Timestamp.now(),
    });
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saving goal added successfully!")),
    );
    _savingTitleController.clear();
    _savingAmountController.clear();
  }

  Future<void> _saveExpenseLimit() async {
    if (userEmail == null) return;
    final limit = double.tryParse(_expenseLimitController.text.trim()) ?? 0;

    if (limit <= 0) return;

    setState(() => _isSaving = true);
    await FirebaseFirestore.instance.collection('goals').add({
      'type': 'expense_limit',
      'category': _selectedCategory,
      'limit': limit,
      'userEmail': userEmail,
      'createdAt': Timestamp.now(),
    });
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Expense limit added successfully!")),
    );
    _expenseLimitController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monthly Goals"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("Saving Goal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Set a goal and the amount you want to save."),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _savingTitleController,
                    decoration: const InputDecoration(
                      labelText: "Saving for (e.g. Laptop)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _savingAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Target Amount (\$)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _saveSavingGoal,
                    child: const Text("Save Saving Goal"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B4D8)),
                  ),

                  const Divider(height: 40),

                  const Text("💸 Expense Limit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Choose a category and set a spending limit."),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Category"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _expenseLimitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Limit Amount (\$)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _saveExpenseLimit,
                    child: const Text("Save Expense Limit"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B4D8)),
                  ),
                ],
              ),
            ),
    );
  }
}
