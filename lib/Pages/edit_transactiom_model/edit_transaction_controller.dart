import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

final currentTransactionProvider = Provider<Map<String, dynamic>>((ref) {
  throw UnimplementedError(); 
});

final editTransactionControllerProvider = ChangeNotifierProvider.family<EditTransactionController, Map<String, dynamic>>(
  (ref, transaction) => EditTransactionController(transaction),
);

class EditTransactionController extends ChangeNotifier {
  final Map<String, dynamic> transaction;

  EditTransactionController(this.transaction) {
    amountController.text = transaction['amount'].toString();
    noteController.text = transaction['note'] ?? '';
    type = transaction['type'] ?? 'expense';
    selectedCategory = transaction['category'] ?? 'Food';
    selectedDate = (transaction['date'] as Timestamp).toDate();
  }

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String type = 'expense';
  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();
  bool isSubmitting = false;

  final List<String> categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Bills',
    'Shopping',
    'Other',
  ];


  void setType(String newType) {
    type = newType;
    notifyListeners();
  }

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    final id = transaction['id'];
    final amount = double.tryParse(amountController.text.trim());

    if (id == null || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    isSubmitting = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('transactions').doc(id).update({
        'type': type,
        'amount': amount,
        'category': selectedCategory,
        'note': noteController.text.trim(),
        'date': Timestamp.fromDate(selectedDate),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transaction updated successfully!")),
      );

      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
