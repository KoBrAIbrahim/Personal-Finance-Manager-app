import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

class FirebaseNotificationHandler {
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  FirebaseNotificationHandler({
    required this.navigatorKey,
    required this.scaffoldMessengerKey,
  });

  void setup() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final context = navigatorKey.currentContext;
        if (context != null) {
          scaffoldMessengerKey.currentState?.showSnackBar(
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
}
