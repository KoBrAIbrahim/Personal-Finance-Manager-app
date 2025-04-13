import 'package:app/Pages/Profile/profile_page.dart';
import 'package:app/Pages/dashboard_model.dart/dashboard_controller.dart';
import 'package:app/Pages/dashboard_model.dart/widget/dashboard_feature_slider.dart';
import 'package:app/Pages/dashboard_model.dart/widget/dashboard_summary_card.dart';
import 'package:app/Pages/dashboard_model.dart/widget/dashboard_transaction_list.dart';
import 'package:app/Pages/setting/settings_page.dart';
import 'package:app/Pages/sharing_profiles/sharing_profiles_page.dart';
import 'package:app/storage/hive_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardContent(),
    SharingProfilesPage(),
    ProfilePage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // زر الإضافة
      context.push('/add');
      return; // لا تغيّر الصفحة
    }

    setState(() => _selectedIndex = index > 2 ? index - 1 : index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex >= 2 ? _selectedIndex + 1 : _selectedIndex,
        selectedItemColor: const Color(0xFF0077B6),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Sharing"),

          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: Color(0xFF00B4D8),
              child: Icon(Icons.add, color: Colors.white),
            ),
            label: '',
          ),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}


class DashboardContent extends ConsumerWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    if (user == null) {
      Future.microtask(() => context.go('/login'));
      return const SizedBox();
    }

    return Scaffold(
backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0077B6),
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await HiveHelper.setLoginStatus(false);
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text("Error loading data")),
        data: (transactions) {
          double income = 0;
          double expense = 0;

          for (var tx in transactions) {
            final amount = (tx['amount'] ?? 0).toDouble();
            if (tx['type'] == 'income') {
              income += amount;
            } else {
              expense += amount;
            }
          }

          final balance = income - expense;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardFeatureSlider(),
                const SizedBox(height: 16),
                DashboardSummaryCard(
                  balance: balance,
                  income: income,
                  expense: expense,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Latest Transactions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: DashboardTransactionList(transactions: transactions),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
