import 'package:app/Pages/Profile/profile_page.dart';
import 'package:app/Pages/setting/settings_page.dart';
import 'package:app/Pages/sharing_profiles/sharing_profiles_page.dart';
import 'package:app/storage/hive_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateProvider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});

final transactionsProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      final userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) return Stream.value([]);

      return FirebaseFirestore.instance
          .collection('transactions')
          .where('userEmail', isEqualTo: userEmail)
          .orderBy('date', descending: true)
          .where('archived', isEqualTo: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final map = doc.data() as Map<String, dynamic>;
              return {'id': doc.id, ...map};
            }).toList();
          });
    });

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardContent(),
    SharingProfilesPage(),
    const ProfilePage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0077B6),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Sharing'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class DashboardContent extends ConsumerWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    if (currentUser == null) {
      Future.microtask(() => context.go('/login'));
      return const SizedBox();
    }

    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FB),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.dashboard_customize_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      await HiveHelper.setLoginStatus(false);
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00B4D8),
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
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
            child: transactionsAsync.when(
              data: (transactions) {
                double totalIncome = 0;
                double totalExpense = 0;

                for (var tx in transactions) {
                  final amount = (tx['amount'] ?? 0).toDouble();
                  final type = tx['type'] ?? 'expense';

                  if (type == 'income') {
                    totalIncome += amount;
                  } else {
                    totalExpense += amount;
                  }
                }

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
                                                  ? Colors.green
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
                                                    ? Colors.green
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (e, st) =>
                      const Center(child: Text("Error loading transactions")),
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

    final controller = PageController(viewportFraction: 0.65);

    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: controller,
        itemCount: features.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              double value = 1.0;
              if (controller.position.haveDimensions) {
                value = controller.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }

              return Center(
                child: Transform(
                  transform:
                      Matrix4.identity()
                        ..scale(value)
                        ..rotateY((1 - value) * 0.2),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: features[index]['onTap'] as VoidCallback,
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            features[index]['icon'] as IconData,
                            color: const Color(0xFF0077B6),
                            size: 30,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            features[index]['label'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
