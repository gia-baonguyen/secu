class User {
  final String userId;
  final String username;
  final String? email;
  final String role;

  User({
    required this.userId,
    required this.username,
    this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'role': role,
    };
  }
}

