class AuthResponse {
  final String accessToken;
  final String tokenType;
  final String role;
  final int userId;
  final String name;
  final String? uniqueCode;
  final String? email;
  final String? phoneNumber;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.role,
    required this.userId,
    required this.name,
    this.uniqueCode,
    this.email,
    this.phoneNumber,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: json['accessToken'] ?? '',
    tokenType: json['tokenType'] ?? 'Bearer',
    role: json['role'] ?? '',
    userId: json['userId'] ?? 0,
    name: json['name'] ?? '',
    uniqueCode: json['uniqueCode'],
    email: json['email'],
    phoneNumber: json['phoneNumber'],
  );
}