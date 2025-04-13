import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    final box = await Hive.openBox('${email}_notifications');
    setState(() {
      _notificationsEnabled = box.get('enabled', defaultValue: true);
    });
  }

  void _toggleNotifications(bool val) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    final box = await Hive.openBox('${email}_notifications');
    await box.put('enabled', val);
    setState(() => _notificationsEnabled = val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: SwitchListTile(
        title: const Text("Enable Notifications"),
        value: _notificationsEnabled,
        onChanged: _toggleNotifications,
        secondary: const Icon(Icons.notifications),
      ),
    );
  }
}
