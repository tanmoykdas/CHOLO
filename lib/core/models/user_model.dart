import 'package:cloud_firestore/cloud_firestore.dart';

class CholoUser {
  final String id;
  final String name;
  final String email; // login email
  final String universityEmail; // academic email
  final bool isAdmin;

  const CholoUser({
    required this.id,
    required this.name,
    required this.email,
  required this.universityEmail,
  required this.isAdmin,
  });

  factory CholoUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CholoUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      universityEmail: data['universityEmail'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'universityEmail': universityEmail,
        'isAdmin': isAdmin,
      };

  CholoUser copyWith({
    String? name,
    String? email,
    String? universityEmail,
    bool? isAdmin,
  }) => CholoUser(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        universityEmail: universityEmail ?? this.universityEmail,
        isAdmin: isAdmin ?? this.isAdmin,
      );
}
