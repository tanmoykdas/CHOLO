import 'package:cloud_firestore/cloud_firestore.dart';

class CholoUser {
  final String id;
  final String name;
  final String email; // login email
  final String universityEmail; // verified academic email
  final bool emailVerified;
  final bool isAdmin;

  const CholoUser({
    required this.id,
    required this.name,
    required this.email,
    required this.universityEmail,
    required this.emailVerified,
    required this.isAdmin,
  });

  factory CholoUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CholoUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      universityEmail: data['universityEmail'] ?? '',
      emailVerified: data['emailVerified'] ?? false,
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'universityEmail': universityEmail,
        'emailVerified': emailVerified,
        'isAdmin': isAdmin,
      };

  CholoUser copyWith({
    String? name,
    String? email,
    String? universityEmail,
    bool? emailVerified,
    bool? isAdmin,
  }) => CholoUser(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        universityEmail: universityEmail ?? this.universityEmail,
        emailVerified: emailVerified ?? this.emailVerified,
        isAdmin: isAdmin ?? this.isAdmin,
      );
}
