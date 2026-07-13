import 'dart:io';
import 'package:dio/dio.dart';
import '../models/patient_model.dart';
import '../storage/local_storage.dart';
import 'api_client.dart';

class PatientService {
  static Future<List<PatientModel>> getPatientsForCaregiver(int caregiverId) async {
    final response = await ApiClient.get('/api/patient/caregiver/$caregiverId');
    final List data = response['data'] ?? [];
    return data.map((e) => PatientModel.fromJson(e)).toList();
  }

  static Future<PatientModel> getPatient(int patientId) async {
    final response = await ApiClient.get('/api/patient/$patientId');
    return PatientModel.fromJson(response['data']);
  }

  static Future<PatientModel> createPatient({
    required int caregiverId,
    required String name,
    int? age,
    String? address,
    String? emergencyContactNumber,
    String? phoneNumber,
  }) async {
    final response = await ApiClient.post('/api/patient/caregiver/$caregiverId',
        data: {
          'name': name,
          'age': age,
          'address': address,
          'emergencyContactNumber': emergencyContactNumber,
          'phoneNumber': phoneNumber,
        });
    return PatientModel.fromJson(response['data']);
  }

  static Future<PatientModel> updatePatient(int patientId, Map<String, dynamic> data) async {
    final response = await ApiClient.put('/api/patient/$patientId', data: data);
    return PatientModel.fromJson(response['data']);
  }

  static Future<PatientModel> uploadPatientPhoto(int patientId, File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last),
    });
    final response = await ApiClient.postMultipart(
        '/api/patient/$patientId/photo', formData);
    return PatientModel.fromJson(response['data']);
  }

  static Future<void> updateLocation(int patientId, double lat, double lng) async {
    await ApiClient.put('/api/patient/$patientId/location',
        data: null);
    await ApiClient.dio.put('/api/patient/$patientId/location',
        queryParameters: {'latitude': lat, 'longitude': lng});
  }

  static Future<PatientModel> linkPatient(
      String code,
      ) async {

    final response = await ApiClient.get(
      '/api/patient/link/$code',
    );

    return PatientModel.fromJson(
      response['data'],
    );
  }
}