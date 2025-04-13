import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String title;
  final String category;
  final String type;
  final double amount;
  final DateTime date;

  TransactionModel({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
  });

  factory TransactionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}
