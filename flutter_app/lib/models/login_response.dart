class LoginResponse {
  final String accessToken;
  final String tokenType;
  final String userId;
  final String email;
  final String role;
  final int expiresIn;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.email,
    required this.role,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      expiresIn: json['expiresIn'] ?? 0,
    );
  }
}

