import 'package:uuid/uuid.dart';

class User {
  final String id; // Change id type to String
  final String username;
  final String email;
  final String password;

  User({
    required this.id, // Update id type to String
    required this.username,
    required this.email,
    required this.password,
  });

  // Factory method to create a User instance from a map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }

  // Method to convert User instance to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
    };
  }

  // Method to create a copy of the User with optional parameter updates
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  // Static method to generate a unique user ID using the uuid package
  static String generateUserId() {
    return Uuid().v4();
  }
}
