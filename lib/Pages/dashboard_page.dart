import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
       //context.go('/login');
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    final transactionsStream =
        FirebaseFirestore.instance
            .collection('transactions')
            .where('userEmail', isEqualTo: userEmail)
            .orderBy('date', descending: true)
            .where('archived', isEqualTo: false)
            .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FB),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF0077B6),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00B4D8),
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0077B6),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1)
            context.push('/profile');
          else if (index == 2)
            context.push('/settings');
          else if (index == 3)
            context.push('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: _circleDecoration(
              200,
              const Color(0xFF00B4D8).withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -120,
            child: _circleDecoration(
              250,
              const Color(0xFF0077B6).withOpacity(0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<QuerySnapshot>(
              stream: transactionsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data?.docs ?? [];
                double totalIncome = 0;
                double totalExpense = 0;

                final transactions =
                    data.map((doc) {
                      final map = doc.data() as Map<String, dynamic>;
                      final amount = (map['amount'] ?? 0).toDouble();
                      final type = map['type'] ?? 'expense';

                      if (type == 'income') {
                        totalIncome += amount;
                      } else {
                        totalExpense += amount;
                      }

                      return {'id': doc.id, ...map};
                    }).toList();

                final balance = totalIncome - totalExpense;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _featuresList(context),
                    const SizedBox(height: 16),
                    _summaryCard(balance, totalIncome, totalExpense),
                    const SizedBox(height: 24),
                    const Text(
                      "Latest Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child:
                          transactions.isEmpty
                              ? const Center(
                                child: Text("No transactions found"),
                              )
                              : ListView.builder(
                                itemCount: transactions.length,
                                itemBuilder: (context, index) {
                                  final tx = transactions[index];
                                  final isIncome = tx['type'] == 'income';
                                  final amount = (tx['amount'] ?? 0).toDouble();
                                  final category = tx['category'] ?? '';
                                  final note = tx['note'] ?? '';
                                  final date =
                                      (tx['date'] as Timestamp).toDate();

                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isIncome
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          color:
                                              isIncome
                                                  ? const Color.fromARGB(
                                                    255,
                                                    76,
                                                    197,
                                                    81,
                                                  )
                                                  : Colors.red,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                note,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                "$category • ${date.toLocal().toString().split(' ')[0]}",
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          "${isIncome ? '+' : '-'} \$${amount.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isIncome
                                                    ? const Color.fromARGB(
                                                      255,
                                                      81,
                                                      228,
                                                      86,
                                                    )
                                                    : Colors.red,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            context.push('/edit', extra: tx);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed:
                                              () => _confirmDelete(
                                                context,
                                                tx['id'],
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleDecoration(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _summaryCard(double balance, double income, double expense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Balance", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            "\$${balance.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _infoBox("Income", income, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _infoBox("Expense", expense, Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Delete Transaction"),
            content: const Text(
              "Are you sure you want to delete this transaction?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await FirebaseFirestore.instance
                      .collection('transactions')
                      .doc(docId)
                      .delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Transaction deleted")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  Widget _featuresList(BuildContext context) {
    final features = [
      {
        'icon': Icons.pie_chart,
        'label': 'Snapshot',
        'onTap': () => context.push('/snapshot'),
      },
      {
        'icon': Icons.bar_chart,
        'label': 'Snapshot History',
        'onTap': () => context.push('/snapshotList'),
      },
      {
        'icon': Icons.pie_chart,
        'label': 'Snapshot Chart',
        'onTap': () => context.push('/snapshotchart'),
      },
      {
        'icon': Icons.architecture,
        'label': 'Goal Page',
        'onTap': () => context.push('/goals'),
      },
      {
        'icon': Icons.view_agenda,
        'label': 'View Goal Page',
        'onTap': () => context.push('/viewgoals'),
      },
    ];
    final featureColors = [
      Color(0xFFE0F7FA),
      Color(0xFFB2EBF2),
      Color(0xFF80DEEA),
      Color(0xFF4DD0E1),
      Color(0xFF26C6DA),
      Color(0xFF00BCD4),
    ];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: features.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final feature = features[index];
          return GestureDetector(
            onTap: feature['onTap'] as VoidCallback,
            child: Container(
              width: 175, // 👈 عرض أكبر
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: featureColors[index % featureColors.length],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    feature['icon'] as IconData,
                    color: const Color(0xFF0077B6),
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feature['label'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
