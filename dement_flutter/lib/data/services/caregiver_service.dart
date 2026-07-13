import 'dart:io';
import 'package:dio/dio.dart';
import '../models/caregiver_model.dart';
import 'api_client.dart';

class CaregiverService {
  static Future<CaregiverModel> getProfile() async {
    final response = await ApiClient.get('/caregiver/profile');
    return CaregiverModel.fromJson(response['data']);
  }

  static Future<CaregiverModel> updateProfile({
    String? name,
    String? phoneNumber,
  }) async {
    final response = await ApiClient.put('/caregiver/profile',
        data: {'name': name, 'phoneNumber': phoneNumber});
    return CaregiverModel.fromJson(response['data']);
  }

  static Future<CaregiverModel> uploadProfileImage(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path,
          filename: imageFile.path.split('/').last),
    });
    final response = await ApiClient.postMultipart(
        '/caregiver/profile/image', formData);
    return CaregiverModel.fromJson(response['data']);
  }
}