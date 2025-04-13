import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

final transactionControllerProvider =
    NotifierProvider<TransactionController, TransactionState>(
      () => TransactionController(),
    );

class TransactionState {
  final String type;
  final String category;
  final DateTime date;
  final bool isSubmitting;

  TransactionState({
    required this.type,
    required this.category,
    required this.date,
    required this.isSubmitting,
  });

  TransactionState copyWith({
    String? type,
    String? category,
    DateTime? date,
    bool? isSubmitting,
  }) {
    return TransactionState(
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class TransactionController extends Notifier<TransactionState> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  List<String> categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Bills',
    'Shopping',
    'Other',
  ];

  @override
  TransactionState build() {
    return TransactionState(
      type: 'expense',
      category: 'Food',
      date: DateTime.now(),
      isSubmitting: false,
    );
  }

  void setType(String newType) {
    state = state.copyWith(type: newType);
  }

  void setCategory(String newCategory) {
    state = state.copyWith(category: newCategory);
  }

  void setDate(DateTime newDate) {
    state = state.copyWith(date: newDate);
  }

  Future<void> submit(BuildContext context) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    final amount = double.tryParse(amountController.text.trim());

    if (userEmail == null || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      await FirebaseFirestore.instance.collection('transactions').add({
        'userEmail': userEmail,
        'type': state.type,
        'amount': amount,
        'category': state.category,
        'note': noteController.text.trim(),
        'date': Timestamp.fromDate(state.date),
        'archived': false,
      });

      if (state.type == 'expense') {
        final goalSnap =
            await FirebaseFirestore.instance
                .collection('goals')
                .where('userEmail', isEqualTo: userEmail)
                .where('type', isEqualTo: 'expense_limit')
                .where('category', isEqualTo: state.category)
                .get();

        if (goalSnap.docs.isNotEmpty) {
          final limit = (goalSnap.docs.first.data()['limit'] ?? 0).toDouble();

          final transactions =
              await FirebaseFirestore.instance
                  .collection('transactions')
                  .where('userEmail', isEqualTo: userEmail)
                  .where('type', isEqualTo: 'expense')
                  .where('category', isEqualTo: state.category)
                  .get();

          double total = 0;
          for (var doc in transactions.docs) {
            total += (doc.data()['amount'] ?? 0).toDouble();
          }

          final percentUsed = (total / limit) * 100;

          if (percentUsed >= 80 && percentUsed < 100) {
            await _sendLimitWarning(
              "You're about to reach your limit for ${state.category}!",
            );
            await goalSnap.docs.first.reference.update({'exceeded': true});
          } else if (percentUsed >= 100) {
            await _sendLimitWarning(
              "You've exceeded your limit for ${state.category}!",
            );
            await goalSnap.docs.first.reference.update({'exceeded': true});
          } else {
            await goalSnap.docs.first.reference.update({'exceeded': false});
          }
        }
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Transaction added!")));
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> _sendLimitWarning(String message) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _sendPushNotification(
        targetToken: token,
        title: "Budget Alert",
        body: message,
      );
    }
  }

  Future<void> _sendPushNotification({
    required String targetToken,
    required String title,
    required String body,
  }) async {
    final serviceAccount = await rootBundle.loadString('assets/key.json');
    final credentials = ServiceAccountCredentials.fromJson(serviceAccount);

    final client = await clientViaServiceAccount(credentials, [
      'https://www.googleapis.com/auth/firebase.messaging',
    ]);

    final Map<String, dynamic> json = jsonDecode(serviceAccount);
    final projectId = json['project_id'];

    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );

    final message = {
      "message": {
        "token": targetToken,
        "notification": {"title": title, "body": body},
        "data": {"route": "/viewgoals", "category": state.category},
      },
    };

    await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(message),
    );
  }
}

class AddTransactionPage extends ConsumerWidget {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionControllerProvider);
    final controller = ref.read(transactionControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FB),
      appBar: AppBar(
        title: const Text("Add Transaction"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8),
              ],
            ),
            child: Column(
              children: [
                ToggleButtons(
                  isSelected: [state.type == 'income', state.type == 'expense'],
                  onPressed:
                      (index) =>
                          controller.setType(index == 0 ? 'income' : 'expense'),
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: state.type == 'income' ? Colors.green : Colors.red,
                  color: Colors.black,
                  constraints: const BoxConstraints(
                    minWidth: 100,
                    minHeight: 40,
                  ),
                  children: const [Text("Income"), Text("Expense")],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: state.category,
                  items:
                      controller.categories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged: (val) => controller.setCategory(val!),
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.noteController,
                  decoration: const InputDecoration(
                    labelText: "Note (optional)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text("Date: "),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: state.date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) controller.setDate(picked);
                      },
                      child: Text(
                        "${state.date.toLocal()}".split(' ')[0],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        state.isSubmitting
                            ? null
                            : () => controller.submit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        state.isSubmitting
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Add Transaction",
                              style: TextStyle(color: Colors.white),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
