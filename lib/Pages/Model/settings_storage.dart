import 'package:app/Pages/Model/user_settings.dart';
import 'package:hive/hive.dart';

class SettingsStorage {
  static final _box = Hive.box('user_settings');

  static String _key(String email) => email.toLowerCase();

  static UserSettings getSettings(String email) {
    final data = _box.get(_key(email));
    if (data is Map<String, dynamic>) {
      return UserSettings.fromMap(data);
    }
    return UserSettings(theme: 'light', notificationsEnabled: true, region: 'USD');
  }

  static Future<void> saveSettings(String email, UserSettings settings) async {
    await _box.put(_key(email), settings.toMap());
  }

  static Future<void> updateSetting(String email, String key, dynamic value) async {
    final current = getSettings(email).toMap();
    current[key] = value;
    await _box.put(_key(email), current);
  }
}
