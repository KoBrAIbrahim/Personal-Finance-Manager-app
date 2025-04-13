
import 'dart:convert';
import 'package:app/Pages/add_transaction_model/transaction_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis_auth/auth_io.dart';


final transactionControllerProvider =
    NotifierProvider<TransactionController, TransactionState>(
  TransactionController.new,
);

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

  void setType(String newType) => state = state.copyWith(type: newType);
  void setCategory(String newCategory) => state = state.copyWith(category: newCategory);
  void setDate(DateTime newDate) => state = state.copyWith(date: newDate);

  Future<void> submit(BuildContext context) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    final amount = double.tryParse(amountController.text.trim());

    if (userEmail == null || amount == null || amount <= 0) {
      _showSnack(context, "Please enter a valid amount");
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
        await _checkGoalLimit(userEmail);
      }

      _showSnack(context, "Transaction added!");
      context.pop();
    } catch (e) {
      _showSnack(context, "Error: ${e.toString()}");
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> _checkGoalLimit(String userEmail) async {
    final goalSnap = await FirebaseFirestore.instance
        .collection('goals')
        .where('userEmail', isEqualTo: userEmail)
        .where('type', isEqualTo: 'expense_limit')
        .where('category', isEqualTo: state.category)
        .get();

    if (goalSnap.docs.isNotEmpty) {
      final limit = (goalSnap.docs.first.data()['limit'] ?? 0).toDouble();

      final transactions = await FirebaseFirestore.instance
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
        await _sendLimitWarning("You're about to reach your limit for ${state.category}!");
        await goalSnap.docs.first.reference.update({'exceeded': true});
      } else if (percentUsed >= 100) {
        await _sendLimitWarning("You've exceeded your limit for ${state.category}!");
        await goalSnap.docs.first.reference.update({'exceeded': true});
      } else {
        await goalSnap.docs.first.reference.update({'exceeded': false});
      }
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
