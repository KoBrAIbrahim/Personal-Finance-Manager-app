import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/user_model.dart';
import '../services/firestore_service.dart';
import '../storage/hive_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<void>>((ref) {
      return LoginController(ref);
    });

class LoginController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  LoginController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = const AsyncValue.loading();

    try {
      final auth = FirebaseAuth.instance;
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await HiveHelper.setLoginStatus(rememberMe);
      if (rememberMe) {
        await HiveHelper.setUserEmail(email.trim());
      }

      final user = credential.user;

      state = const AsyncValue.data(null);

      if (user != null) {
        try {
          final firestore = FirestoreService();
          await firestore.createUser(
            AppUser(
              uid: user.uid,
              email: user.email ?? '',
              createdAt: DateTime.now(),
            ),
          );

          final token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({'fcmToken': token}, SetOptions(merge: true));
          }
        } catch (e) {
          print("Non-blocking post-login error: $e");
        }
      }

      return true;
    } catch (e, st) {
      print("Login error: $e");
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
