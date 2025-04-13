import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidInit,
    );

    await _notificationsPlugin.initialize(initSettings);
    tz.initializeTimeZones(); 
  }

  static Future<void> scheduleDailyReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Reminds user to log expenses daily',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      0,
      'Reminder ',
      "Don't forget to log today's expenses!",
      _nextInstanceOf3_15PM(),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

static tz.TZDateTime _nextInstanceOf3_15PM() {
  final now = tz.TZDateTime.now(tz.local);
  final scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 15, 15);
  return scheduled.isBefore(now)
      ? scheduled.add(const Duration(days: 1))
      : scheduled;
}



  static Future<void> showTestNotification() async {
  const androidDetails = AndroidNotificationDetails(
    'test_channel',
    'Test Notifications',
    channelDescription: 'Used to test local notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  const notificationDetails = NotificationDetails(android: androidDetails);

  await _notificationsPlugin.show(
    999, 
    'Test Notification',
    'This is a test local notification!',
    notificationDetails,
  );
}

}
