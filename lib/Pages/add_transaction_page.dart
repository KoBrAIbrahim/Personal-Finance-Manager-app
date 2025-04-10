import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  String _type = 'expense';
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Bills',
    'Shopping',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
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
                  isSelected: [_type == 'income', _type == 'expense'],
                  onPressed: (index) {
                    setState(() {
                      _type = index == 0 ? 'income' : 'expense';
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: _type == 'income' ? Colors.green : Colors.red,
                  color: Colors.black,
                  constraints: const BoxConstraints(
                    minWidth: 100,
                    minHeight: 40,
                  ),
                  children: const [Text("Income"), Text("Expense")],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items:
                      _categories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
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
                      onPressed: _pickDate,
                      child: Text(
                        "${_selectedDate.toLocal()}".split(' ')[0],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isSubmitting
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    final amount = double.tryParse(_amountController.text.trim());

    if (userEmail == null || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('transactions').add({
        'userEmail': userEmail,
        'type': _type,
        'amount': amount,
        'category': _selectedCategory,
        'note': _noteController.text.trim(),
        'date': Timestamp.fromDate(_selectedDate),
        'archived': false,
      });

      if (_type == 'expense') {
        final goalSnap =
            await FirebaseFirestore.instance
                .collection('goals')
                .where('userEmail', isEqualTo: userEmail)
                .where('type', isEqualTo: 'expense_limit')
                .where('category', isEqualTo: _selectedCategory)
                .get();

        if (goalSnap.docs.isNotEmpty) {
          final limit = (goalSnap.docs.first.data()['limit'] ?? 0).toDouble();

          final transactions =
              await FirebaseFirestore.instance
                  .collection('transactions')
                  .where('userEmail', isEqualTo: userEmail)
                  .where('type', isEqualTo: 'expense')
                  .where('category', isEqualTo: _selectedCategory)
                  .get();

          double total = 0;
          for (var doc in transactions.docs) {
            total += (doc.data()['amount'] ?? 0).toDouble();
          }

          final percentUsed = (total / limit) * 100;

          if (percentUsed >= 80 && percentUsed < 100) {
            await _sendLimitWarning(
              "⚠️ You're about to reach your limit for $_selectedCategory!",
            );
            await goalSnap.docs.first.reference.update({'exceeded': true});
          } else if (percentUsed >= 100) {
            await _sendLimitWarning(
              "🚫 You've exceeded your limit for $_selectedCategory!",
            );
            await goalSnap.docs.first.reference.update({'exceeded': true});
          } else {
            // ✅ المصاريف تحت الحد
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
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _sendLimitWarning(String message) async {
    final token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      print("🔔 Sending notification...");
      await sendPushNotification(
        targetToken: token,
        title: "Budget Alert",
        body: message,
      );
    }
  }

  Future<void> sendPushNotification({
    required String targetToken,
    required String title,
    required String body,
  }) async {
    final serviceAccount = await rootBundle.loadString(
      'assets/key.json',
    );
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
        "data": {"route": "/viewgoals", "category": _selectedCategory},
      },
    };

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(message),
    );

    print("📬 FCM Response: ${response.statusCode} ${response.body}");
  }
}
