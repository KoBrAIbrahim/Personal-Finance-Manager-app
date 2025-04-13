import 'package:cloud_firestore/cloud_firestore.dart';

class PublicUser {
  final String email;
  final String phone;
  final String gender;
  final DateTime birthday;

  PublicUser({
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthday,
  });

  factory PublicUser.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PublicUser(
      email: doc.id,
      phone: data['phone'] ?? '',
      gender: data['gender'] ?? '',
      birthday: (data['birthday'] as Timestamp).toDate(),
    );
  }
}