import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/notification_service.dart';
import '../storage/hive_helper.dart';

Future<void> initializeApp() async {
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  await Hive.initFlutter();
  await HiveHelper.initHive();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService.init();
  await NotificationService.scheduleDailyReminder();
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background Message: ${message.messageId}');
}
