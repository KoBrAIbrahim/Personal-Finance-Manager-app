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
