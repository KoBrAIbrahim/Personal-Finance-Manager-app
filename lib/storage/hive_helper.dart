import 'package:hive/hive.dart';

class HiveHelper {
  static const String _authBoxName = 'authBox';

  static Future<void> initHive() async {
    await Hive.openBox(_authBoxName);
  }

  static Future<void> setLoginStatus(bool isLoggedIn) async {
    final box = Hive.box(_authBoxName);
    await box.put('isLoggedIn', isLoggedIn);
  }

  static bool isLoggedIn() {
    final box = Hive.box(_authBoxName);
    return box.get('isLoggedIn', defaultValue: false);
  }

  static Future<void> setUserEmail(String email) async {
    final box = Hive.box(_authBoxName);
    await box.put('userEmail', email);
  }

  static String? getUserEmail() {
    final box = Hive.box(_authBoxName);
    return box.get('userEmail');
  }

  static Future<void> clearAuthBox() async {
    final box = Hive.box(_authBoxName);
    await box.clear();
  }
}
