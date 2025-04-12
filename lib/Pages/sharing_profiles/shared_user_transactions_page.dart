import 'package:app/Pages/Model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final sharedTransactionsProvider = FutureProvider.family<List<TransactionModel>, String>((ref, email) async {
  final query = await FirebaseFirestore.instance
      .collection('transactions')
      .where('userEmail', isEqualTo: email)
      .orderBy('date', descending: true)
      .get();

  return query.docs.map((doc) => TransactionModel.fromDoc(doc)).toList();
});

class SharedUserTransactionsPage extends ConsumerWidget {
  final String userEmail;
  const SharedUserTransactionsPage({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(sharedTransactionsProvider(userEmail));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0077B6),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);  
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Transactions of $userEmail",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: transactionsAsync.when(
        data: (transactions) => transactions.isEmpty
            ? const Center(child: Text("No transactions available."))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  Color arrowColor = tx.type == 'income' ? Colors.green : Colors.red;
                  IconData arrowIcon = tx.type == 'income' ? Icons.arrow_upward : Icons.arrow_downward;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,  
                    color: Colors.blue[50],  
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      title: Text(
                        tx.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${tx.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: arrowColor, 
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• ${tx.category}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Date: ${tx.date.day}/${tx.date.month}/${tx.date.year}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        arrowIcon,
                        color: arrowColor,  
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
