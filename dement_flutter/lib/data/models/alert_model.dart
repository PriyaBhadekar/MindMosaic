class SosAlertModel {
  final int id;
  final String alertType;
  final String? alertMessage;
  final bool resolved;
  final double? patientLatitude;
  final double? patientLongitude;
  final String? triggeredAt;

  SosAlertModel({
    required this.id,
    required this.alertType,
    this.alertMessage,
    required this.resolved,
    this.patientLatitude,
    this.patientLongitude,
    this.triggeredAt,
  });

  factory SosAlertModel.fromJson(Map<String, dynamic> json) => SosAlertModel(
    id: json['id'] ?? 0,
    alertType: json['alertType'] ?? '',
    alertMessage: json['alertMessage'],
    resolved: json['resolved'] ?? false,
    patientLatitude: json['patientLatitude']?.toDouble(),
    patientLongitude: json['patientLongitude']?.toDouble(),
    triggeredAt: json['triggeredAt'],
  );
}