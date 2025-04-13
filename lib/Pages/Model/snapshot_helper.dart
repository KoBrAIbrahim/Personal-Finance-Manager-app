import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SnapshotHelper {
  static Future<void> createMonthlySnapshot() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final email = user.email!;
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    final query = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userEmail', isEqualTo: email)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
        .get();

    double income = 0;
    double expense = 0;
    List<Map<String, dynamic>> transactions = [];

    for (var doc in query.docs) {
      final data = doc.data();
      final amount = (data['amount'] ?? 0).toDouble();
      final type = data['type'] ?? 'expense';

      if (type == 'income') {
        income += amount;
      } else {
        expense += amount;
      }

      transactions.add({
        'amount': amount,
        'type': type,
        'category': data['category'],
        'note': data['note'],
        'date': data['date'],
      });
    }

    final balance = income - expense;

    await FirebaseFirestore.instance.collection('snapshots').add({
      'userEmail': email,
      'fromDate': Timestamp.fromDate(firstDay),
      'toDate': Timestamp.fromDate(lastDay),
      'totalIncome': income,
      'totalExpense': expense,
      'balance': balance,
      'transactions': transactions,
      'createdAt': Timestamp.now(),
    });
  }
}
