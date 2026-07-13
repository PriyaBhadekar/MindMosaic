// UPDATE lib/data/models/patient_model.dart — add caregiverId
class PatientModel {
  final int id;
  final String name;
  final String? photoPath;
  final int? age;
  final String? address;
  final String? emergencyContactNumber;
  final String? phoneNumber;
  final String linkedCode;
  final int? caregiverId;     // ADD
  final String? caregiverName; // ADD
  final String? createdAt;

  PatientModel({
    required this.id,
    required this.name,
    this.photoPath,
    this.age,
    this.address,
    this.emergencyContactNumber,
    this.phoneNumber,
    required this.linkedCode,
    this.caregiverId,          // ADD
    this.caregiverName,        // ADD
    this.createdAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) => PatientModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    photoPath: json['photoPath'],
    age: json['age'],
    address: json['address'],
    emergencyContactNumber: json['emergencyContactNumber'],
    phoneNumber: json['phoneNumber'],
    linkedCode: json['linkedCode'] ?? '',
    caregiverId: json['caregiverId'],     // ADD
    caregiverName: json['caregiverName'], // ADD
    createdAt: json['createdAt'],
  );
}