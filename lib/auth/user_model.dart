class AppUser {
  final String uid;
  final String email;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
