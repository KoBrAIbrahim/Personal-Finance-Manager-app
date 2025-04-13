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