import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final signupControllerProvider =
    StateNotifierProvider<SignupController, AsyncValue<void>>((ref) {
  return SignupController(ref);
});

class SignupController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  SignupController(this.ref) : super(const AsyncValue.data(null));

  Future<void> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final auth = FirebaseAuth.instance;
      final result = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = result.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'username': username,
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
