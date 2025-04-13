import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../auth/user_model.dart';
import '../services/firestore_service.dart';
import '../storage/hive_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<void> signInWithGoogle(BuildContext context) async {
  try {
    state = const AsyncValue.loading();

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      state = const AsyncValue.data(null);
      return;
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final user = userCredential.user;

    if (user != null) {
      await HiveHelper.setLoginStatus(true);
      await HiveHelper.setUserEmail(user.email ?? "");

      final firestore = FirestoreService();
      await firestore.createUser(AppUser(
        uid: user.uid,
        email: user.email ?? '',
        createdAt: DateTime.now(),
      ));

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'fcmToken': token}, SetOptions(merge: true));
      }

      state = const AsyncValue.data(null);
    }
  } catch (e, st) {
    print("Google login error: $e");
    state = AsyncValue.error(e, st);
  }
}
Future<void> loginWithGoogle(BuildContext context) async {
  try {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // المستخدم لغى العملية

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    if (context.mounted) context.go('/dashboard');
  } catch (e) {
    debugPrint("Google Sign-In Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign-in failed')),
    );
  }
}

}
