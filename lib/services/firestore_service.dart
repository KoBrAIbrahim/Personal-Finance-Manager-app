import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/user_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> createUser(AppUser user) async {
    final ref = _db.collection("users").doc(user.email);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set(user.toMap());
    }
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!);
    }
    return null;
  }
}
