import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateProvider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});

final transactionsProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final userEmail = FirebaseAuth.instance.currentUser?.email;
  if (userEmail == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('transactions')
      .where('userEmail', isEqualTo: userEmail)
      .orderBy('date', descending: true)
      .where('archived', isEqualTo: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();
  });
});
