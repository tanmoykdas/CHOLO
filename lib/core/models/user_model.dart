import 'package:cloud_firestore/cloud_firestore.dart';

class CholoUser {
  final String id;
  final String name;
  final String email; // login email
  final String universityEmail; // academic email
  final bool isAdmin;
  final double totalRatings;
  final int ratingCount;
  final String profilePictureUrl;
  final int? age;
  final String gender;
  final String universityName;

  const CholoUser({
    required this.id,
    required this.name,
    required this.email,
    required this.universityEmail,
    required this.isAdmin,
    this.totalRatings = 0.0,
    this.ratingCount = 0,
    this.profilePictureUrl = '',
    this.age,
    this.gender = '',
    this.universityName = '',
  });

  double get averageRating => ratingCount > 0 ? totalRatings / ratingCount : 0.0;

  factory CholoUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CholoUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      universityEmail: data['universityEmail'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
      totalRatings: (data['totalRatings'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      age: data['age'],
      gender: data['gender'] ?? '',
      universityName: data['universityName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'universityEmail': universityEmail,
        'isAdmin': isAdmin,
        'totalRatings': totalRatings,
        'ratingCount': ratingCount,
        'profilePictureUrl': profilePictureUrl,
        'age': age,
        'gender': gender,
        'universityName': universityName,
      };

  CholoUser copyWith({
    String? name,
    String? email,
    String? universityEmail,
    bool? isAdmin,
    double? totalRatings,
    int? ratingCount,
    String? profilePictureUrl,
    int? age,
    String? gender,
    String? universityName,
  }) => CholoUser(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        universityEmail: universityEmail ?? this.universityEmail,
        isAdmin: isAdmin ?? this.isAdmin,
        totalRatings: totalRatings ?? this.totalRatings,
        ratingCount: ratingCount ?? this.ratingCount,
        profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        universityName: universityName ?? this.universityName,
      );
}
