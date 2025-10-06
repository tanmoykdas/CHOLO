class User {
  final String id;
  final String name;
  final String email;
  final String universityEmail;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.universityEmail,
  });

  // Convert a User into a Map for easy database storage (like Firestore or SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'universityEmail': universityEmail,
    };
  }

  // Create a User from a Map (for reading from database)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      universityEmail: map['universityEmail'],
    );
  }
}
