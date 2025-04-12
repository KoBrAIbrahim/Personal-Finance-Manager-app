import 'package:app/Pages/Goals/goal_details_page.dart';
import 'package:app/Pages/Goals/goal_page.dart';
import 'package:app/Pages/Goals/view_goals.dart';
import 'package:app/Pages/Profile/profile_page.dart';
import 'package:app/Pages/add_transaction_page.dart';
import 'package:app/Pages/edit_transaction_page.dart';
import 'package:app/Pages/setting/about_Setting_page.dart';
import 'package:app/Pages/setting/account_info_page.dart';
import 'package:app/Pages/setting/appearance_settings_page.dart';
import 'package:app/Pages/setting/contact_support_page.dart';
import 'package:app/Pages/setting/faq_page.dart';
import 'package:app/Pages/setting/notifications_settings_page.dart';
import 'package:app/Pages/setting/privacy_settings_page.dart';
import 'package:app/Pages/setting/region_settings_page.dart';
import 'package:app/Pages/setting/settings_page.dart';
import 'package:app/Pages/sharing_profiles/shared_user_transactions_page.dart';
import 'package:app/Pages/spanshot/snapshot_chart_page.dart';
import 'package:app/Pages/spanshot/snapshot_history_page.dart';
import 'package:app/Pages/spanshot/snapshot_page.dart';
import 'package:app/pages/dashboard_page.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/welcomePage/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'storage/hive_helper.dart';
import 'package:app/Pages/Model/theme_provider.dart' as theme_model;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background Message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  await Hive.initFlutter();
  await HiveHelper.initHive();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService.init();
  // await NotificationService.showTestNotification();
  await NotificationService.scheduleDailyReminder();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Foreground: ${message.notification!.title}');
        final context = navigatorKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.notification!.body ?? 'New Notification'),
            ),
          );
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final context = navigatorKey.currentContext;
      final route = message.data['route'];
      final goalId = message.data['goalId'];

      if (context != null && route != null) {
        final router = GoRouter.of(context);
        if (route == '/goal-details' && goalId != null) {
          router.go(route, extra: goalId);
        } else {
          router.go(route);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = HiveHelper.isLoggedIn();
    final themeMode = ref.watch(theme_model.themeModeProvider);

    final _router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder:
              (_, __) =>
                  isLoggedIn ? const DashboardPage() : const WelcomePage(),
        ),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/signup', builder: (_, __) => const SignUpPage()),
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

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Personal Finance Manager',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      routerConfig: _router,
      builder:
          (context, child) => ScaffoldMessenger(
            key: GlobalKey<ScaffoldMessengerState>(),
            child: child!,
          ),
    );
  }
}
