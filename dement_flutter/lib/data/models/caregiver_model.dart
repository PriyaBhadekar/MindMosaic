class CaregiverModel {
  final int id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? profileImagePath;
  final String uniqueCode;
  final String? createdAt;

  CaregiverModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImagePath,
    required this.uniqueCode,
    this.createdAt,
  });

  factory CaregiverModel.fromJson(Map<String, dynamic> json) => CaregiverModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phoneNumber: json['phoneNumber'],
    profileImagePath: json['profileImagePath'],
    uniqueCode: json['uniqueCode'] ?? '',
    createdAt: json['createdAt'],
  );
}