import 'package:app/Pages/Model/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppearanceSettingsPage extends ConsumerStatefulWidget {
  const AppearanceSettingsPage({super.key});

  @override
  ConsumerState<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends ConsumerState<AppearanceSettingsPage> {
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    final box = await Hive.openBox('${email}_appearance');
    final value = box.get('darkMode', defaultValue: false);
    setState(() => _isDark = value);

    ref.read(themeModeProvider.notifier).state = value ? ThemeMode.dark : ThemeMode.light;
  }

  void _toggleTheme(bool value) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    final box = await Hive.openBox('${email}_appearance');
    await box.put('darkMode', value);
    setState(() => _isDark = value);

    ref.read(themeModeProvider.notifier).state = value ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance Settings'),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: SwitchListTile(
        title: const Text("Dark Mode"),
        value: _isDark,
        onChanged: _toggleTheme,
      ),
    );
  }
}
