import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../storage/hive_helper.dart';
import '../welcomePage/welcome.dart';
import '../pages/dashboard_page.dart';
import '../auth/login_page.dart';
import '../auth/signup_page.dart';
import '../pages/add_transaction_page.dart';
import '../pages/edit_transaction_page.dart';
import '../Pages/setting/settings_page.dart';
import '../Pages/Goals/goal_details_page.dart';
import '../Pages/Goals/goal_page.dart';
import '../Pages/Goals/view_goals.dart';
import '../Pages/Profile/profile_page.dart';
import '../Pages/sharing_profiles/shared_user_transactions_page.dart';
import '../Pages/spanshot/snapshot_chart_page.dart';
import '../Pages/spanshot/snapshot_history_page.dart';
import '../Pages/spanshot/snapshot_page.dart';
import '../Pages/setting/account_info_page.dart';
import '../Pages/setting/appearance_settings_page.dart';
import '../Pages/setting/contact_support_page.dart';
import '../Pages/setting/faq_page.dart';
import '../Pages/setting/notifications_settings_page.dart';
import '../Pages/setting/privacy_settings_page.dart';
import '../Pages/setting/region_settings_page.dart';
import '../Pages/setting/about_Setting_page.dart';

final isLoggedInProvider = Provider<bool>((ref) => HiveHelper.isLoggedIn());

final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder:
            (_, __) => isLoggedIn ? const DashboardPage() : const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              transitionDuration: const Duration(milliseconds: 1500),
              child: const LoginPage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                final rotateAnim = Tween(
                  begin: 1.0,
                  end: 0.0,
                ).animate(animation);

                return AnimatedBuilder(
                  animation: rotateAnim,
                  child: child,
                  builder: (context, child) {
                    final angle =
                        rotateAnim.value * 3.14; // π radians = 180 degrees

                    return Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                      child:
                          angle > 1.5
                              ? const SizedBox.shrink() // hide backside during half flip
                              : child,
                    );
                  },
                );
              },
            ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              transitionDuration: const Duration(milliseconds: 1500),
              child: const SignUpPage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                final rotateAnim = Tween(
                  begin: -1.0,
                  end: 0.0,
                ).animate(animation);

                return AnimatedBuilder(
                  animation: rotateAnim,
                  child: child,
                  builder: (context, child) {
                    final angle = rotateAnim.value * 3.14;

                    return Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                      child: angle < -1.5 ? const SizedBox.shrink() : child,
                    );
                  },
                );
              },
            ),
      ),

      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
      GoRoute(path: '/add', builder: (_, __) => const AddTransactionPage()),
      GoRoute(
        path: '/edit',
        name: 'edit',
        builder: (_, state) {
          final transaction = state.extra as Map<String, dynamic>;
          return EditTransactionPage(transaction: transaction);
        },
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      GoRoute(
        path: '/settings/account',
        builder: (_, __) => const AccountInfoPage(),
      ),
      GoRoute(
        path: '/settings/privacy',
        builder: (_, __) => const PrivacySettingsPage(),
      ),
      GoRoute(
        path: '/settings/appearance',
        builder: (_, __) => const AppearanceSettingsPage(),
      ),
      GoRoute(
        path: '/settings/notifications',
        builder: (_, __) => const NotificationsSettingsPage(),
      ),
      GoRoute(
        path: '/settings/region',
        builder: (_, __) => const RegionSettingsPage(),
      ),
      GoRoute(path: '/settings/faq', builder: (_, __) => const FAQPage()),
      GoRoute(
        path: '/settings/contact',
        builder: (_, __) => const ContactSupportPage(),
      ),
      GoRoute(path: '/settings/about', builder: (_, __) => const AboutPage()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      GoRoute(
        path: '/snapshot',
        builder: (_, __) => const MonthlySnapshotPage(),
      ),
      GoRoute(
        path: '/snapshotList',
        builder: (_, __) => const SnapshotHistoryPage(),
      ),
      GoRoute(
        path: '/snapshotchart',
        builder: (_, __) => const SnapshotChartPage(),
      ),
      GoRoute(path: '/goals', builder: (_, __) => const GoalsPage()),
      GoRoute(path: '/viewgoals', builder: (_, __) => const ViewGoalsPage()),
      GoRoute(
        path: '/goal-details',
        builder: (_, state) {
          final goalId = state.extra as String;
          return GoalDetailsPage(goalId: goalId);
        },
      ),
      GoRoute(
        path: '/shared-transactions/:email',
        builder: (context, state) {
          final email = state.pathParameters['email']!;
          return SharedUserTransactionsPage(userEmail: email);
        },
      ),
    ],
  );
});
