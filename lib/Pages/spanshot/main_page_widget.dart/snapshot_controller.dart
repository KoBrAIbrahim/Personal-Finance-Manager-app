import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final snapshotControllerProvider =
    NotifierProvider<SnapshotController, SnapshotState>(
  SnapshotController.new,
);

class SnapshotState {
  final DateTime? startDate;
  final DateTime endDate;
  final double income;
  final double expense;
  final bool snapshotExists;
  final bool isLoading;

  SnapshotState({
    required this.startDate,
    required this.endDate,
    required this.income,
    required this.expense,
    required this.snapshotExists,
    required this.isLoading,
  });

  SnapshotState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    double? income,
    double? expense,
    bool? snapshotExists,
    bool? isLoading,
  }) {
    return SnapshotState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      snapshotExists: snapshotExists ?? this.snapshotExists,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SnapshotController extends Notifier<SnapshotState> {
  final userEmail = FirebaseAuth.instance.currentUser?.email;

  @override
  SnapshotState build() {
    _loadOldestDate();
    return SnapshotState(
      startDate: null,
      endDate: DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
      income: 0,
      expense: 0,
      snapshotExists: false,
      isLoading: true,
    );
  }

  Future<void> _loadOldestDate() async {
    if (userEmail == null) return;

    try {
      final query = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userEmail', isEqualTo: userEmail)
          .where('archived', isEqualTo: false)
          .orderBy('date')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final startDate = (query.docs.first['date'] as Timestamp).toDate();
        state = state.copyWith(startDate: startDate);
        await _checkSnapshot();
        await _calculateTotals();
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _checkSnapshot() async {
    if (state.startDate == null || userEmail == null) return;
    final id =
        "${state.startDate!.toIso8601String()}_${state.endDate.toIso8601String()}_${userEmail!}";
    final snapshot =
        await FirebaseFirestore.instance.collection('snapshots').doc(id).get();
    state = state.copyWith(snapshotExists: snapshot.exists);
  }

  Future<void> _calculateTotals() async {
    if (state.startDate == null || userEmail == null) return;
    state = state.copyWith(isLoading: true);

    try {
      final transactions = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userEmail', isEqualTo: userEmail)
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(state.startDate!),
          )
          .where(
            'date',
            isLessThanOrEqualTo: Timestamp.fromDate(state.endDate),
          )
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

      state = state.copyWith(income: income, expense: expense);
    } catch (e) {
      print("Error calculating totals: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> takeSnapshot(BuildContext context) async {
    if (state.startDate == null || userEmail == null) return;

    final id =
        "${state.startDate!.toIso8601String()}_${state.endDate.toIso8601String()}_${userEmail!}";
    final batch = FirebaseFirestore.instance.batch();

    final snapshotRef =
        FirebaseFirestore.instance.collection('snapshots').doc(id);
    batch.set(snapshotRef, {
      'userEmail': userEmail,
      'start': Timestamp.fromDate(state.startDate!),
      'end': Timestamp.fromDate(state.endDate),
      'income': state.income,
      'expense': state.expense,
      'balance': state.income - state.expense,
      'createdAt': Timestamp.now(),
    });

    final periodRef =
        FirebaseFirestore.instance.collection('snapshot_periods').doc();
    batch.set(periodRef, {
      'userEmail': userEmail,
      'start': Timestamp.fromDate(state.startDate!),
      'end': Timestamp.fromDate(state.endDate),
      'createdAt': Timestamp.now(),
    });

    final transactions = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userEmail', isEqualTo: userEmail)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(state.startDate!),
        )
        .where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(state.endDate),
        )
        .get();

    for (var doc in transactions.docs) {
      batch.update(doc.reference, {'archived': true});
    }

    await batch.commit();

    await _checkSavingGoalsCompletion(context, state.income - state.expense);
    state = state.copyWith(snapshotExists: true);
  }

  Future<void> _checkSavingGoalsCompletion(
    BuildContext context,
    double balance,
  ) async {
    if (userEmail == null) return;

    final goals = await FirebaseFirestore.instance
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You've reached your goal: $title!"),
            action: SnackBarAction(
              label: "View",
              onPressed: () => context.push('/goal-details/${doc.id}'),
            ),
          ),
        );
      }
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.endDate,
      firstDate: state.startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final newEndDate = picked.copyWith(hour: 23, minute: 59, second: 59);
      state = state.copyWith(endDate: newEndDate, snapshotExists: false);
      await _checkSnapshot();
      await _calculateTotals();
    }
  }
}
