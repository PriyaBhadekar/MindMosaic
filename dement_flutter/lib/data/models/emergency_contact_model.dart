class EmergencyContactModel {
  final int id;
  final String name;
  final String phoneNumber;
  final String? relationship;
  final bool primary;

  EmergencyContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relationship,
    required this.primary,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) =>
      EmergencyContactModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        relationship: json['relationship'],
        primary: json['primary'] ?? false,
      );
}