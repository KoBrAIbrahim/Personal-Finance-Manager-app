import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MonthlySnapshotPage extends StatefulWidget {
  const MonthlySnapshotPage({super.key});

  @override
  State<MonthlySnapshotPage> createState() => _MonthlySnapshotPageState();
}

class _MonthlySnapshotPageState extends State<MonthlySnapshotPage> {
  final userEmail = FirebaseAuth.instance.currentUser?.email;
  DateTime? _startDate;
  DateTime _endDate = DateTime.now();
  double _income = 0;
  double _expense = 0;
  bool _snapshotExists = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOldestDate();
  }

  Future<void> _loadOldestDate() async {
    if (userEmail == null) return;

    try {
      final query =
          await FirebaseFirestore.instance
              .collection('transactions')
              .where('userEmail', isEqualTo: userEmail)
              .where('archived', isEqualTo: false)
              .orderBy('date')
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        _startDate = (query.docs.first['date'] as Timestamp).toDate();
        _endDate = _endDate.copyWith(hour: 23, minute: 59, second: 59);
        await _checkSnapshot();
        await _calculateTotals();
      }
    } catch (e) {
      print("🔥 Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading date or index missing.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkSnapshot() async {
    if (_startDate == null || userEmail == null) return;
    final id =
        "${_startDate!.toIso8601String()}_${_endDate.toIso8601String()}_${userEmail!}";
    final snapshot =
        await FirebaseFirestore.instance.collection('snapshots').doc(id).get();
    setState(() => _snapshotExists = snapshot.exists);
  }

  Future<void> _calculateTotals() async {
    if (_startDate == null || userEmail == null) return;
    setState(() => _isLoading = true);

    try {
      final transactions =
          await FirebaseFirestore.instance
              .collection('transactions')
              .where('userEmail', isEqualTo: userEmail)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!),
              )
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(_endDate))
              .get();

      double income = 0;
      double expense = 0;

      for (var doc in transactions.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toDouble();
        final archived = data['archived'] ?? false;

        if (!archived) {
          if (data['type'] == 'income') {
            income += amount;
          } else {
            expense += amount;
          }
        }
      }

      setState(() {
        _income = income;
        _expense = expense;
      });
    } catch (e) {
      print("Error calculating totals: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _takeSnapshot() async {
    if (_startDate == null || userEmail == null) return;

    final id =
        "${_startDate!.toIso8601String()}_${_endDate.toIso8601String()}_${userEmail!}";

    final batch = FirebaseFirestore.instance.batch();

    final snapshotRef = FirebaseFirestore.instance
        .collection('snapshots')
        .doc(id);
    batch.set(snapshotRef, {
      'userEmail': userEmail,
      'start': Timestamp.fromDate(_startDate!),
      'end': Timestamp.fromDate(_endDate),
      'income': _income,
      'expense': _expense,
      'balance': _income - _expense,
      'createdAt': Timestamp.now(),
    });

    final periodRef =
        FirebaseFirestore.instance.collection('snapshot_periods').doc();
    batch.set(periodRef, {
      'userEmail': userEmail,
      'start': Timestamp.fromDate(_startDate!),
      'end': Timestamp.fromDate(_endDate),
      'createdAt': Timestamp.now(),
    });

    final transactions =
        await FirebaseFirestore.instance
            .collection('transactions')
            .where('userEmail', isEqualTo: userEmail)
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!),
            )
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(_endDate))
            .get();

    for (var doc in transactions.docs) {
      batch.update(doc.reference, {'archived': true});
    }

    await batch.commit();

    await _checkSavingGoalsCompletion(_income - _expense);

    setState(() => _snapshotExists = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Snapshot created and transactions archived."),
      ),
    );
  }

  Future<void> _checkSavingGoalsCompletion(double balance) async {
    if (userEmail == null) return;

    final goals =
        await FirebaseFirestore.instance
            .collection('goals')
            .where('userEmail', isEqualTo: userEmail)
            .where('type', isEqualTo: 'saving')
            .where('completed', isEqualTo: false)
            .get();

    for (var doc in goals.docs) {
      final data = doc.data();
      final goalAmount = (data['amount'] ?? 0).toDouble();
      final title = data['title'] ?? 'Goal';

      if (balance >= goalAmount) {
        await doc.reference.update({'completed': true});
        _showGoalNotification(title, doc.id);
      }
    }
  }

  void _showGoalNotification(String title, String goalId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You've reached your goal: $title!"),
        action: SnackBarAction(
          label: "View",
          onPressed: () {
            context.push('/goal-details/$goalId');
          },
        ),
      ),
    );
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked.copyWith(hour: 23, minute: 59, second: 59);
        _snapshotExists = false;
      });
      await _checkSnapshot();
      await _calculateTotals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = _income - _expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Snapshot"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Period: ${_startDate?.toLocal().toString().split(' ')[0]} - ${_endDate.toLocal().toString().split(' ')[0]}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _pickEndDate,
                      icon: const Icon(Icons.date_range),
                      label: const Text("Change End Date"),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _summaryBox("Income", _income, Colors.green),
                        const SizedBox(width: 10),
                        _summaryBox("Expense", _expense, Colors.red),
                        const SizedBox(width: 10),
                        _summaryBox("Balance", balance, Colors.teal),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _snapshotExists
                        ? const Text(
                          "Snapshot already exists for this period.",
                          style: TextStyle(color: Colors.grey),
                        )
                        : ElevatedButton.icon(
                          onPressed: _takeSnapshot,
                          icon: const Icon(Icons.camera),
                          label: const Text("Take Snapshot"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B4D8),
                          ),
                        ),
                  ],
                ),
              ),
    );
  }

  Widget _summaryBox(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "\$${amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
