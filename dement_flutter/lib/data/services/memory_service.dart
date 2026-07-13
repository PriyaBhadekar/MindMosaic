import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../models/memory_model.dart';
import 'api_client.dart';
import '../storage/local_storage.dart';

class MemoryService {

  static Future<List<MemoryModel>> getMemories() async {

    final patientId = LocalStorage.getPatientId();

    print('========================');
    print('PATIENT ID: $patientId');
    print('========================');

    final response = await ApiClient.get(
      '/api/memories/patient/$patientId',
    );

    print('========================');
    print('MEMORIES RESPONSE');
    print(response);
    print('========================');

    final List data = response['data'] ?? [];

    return data
        .map((e) => MemoryModel.fromJson(e))
        .toList();
  }

  static Future<MemoryModel> createMemory({
    required String title,
    String? description,
    String? relationInfo,
    String? category,
    String? tags,
    XFile? imageFile,
  }) async {

    final memoryData = {
      "title": title,
      "description": description ?? '',
      "relationInfo": relationInfo ?? '',
      "category": category ?? '',
      "tags": tags ?? '',
    };

    FormData formData = FormData.fromMap({

      'data': MultipartFile.fromString(
        jsonEncode(memoryData),
        contentType: DioMediaType(
          'application',
          'json',
        ),
      ),
    });

    if (imageFile != null) {

      final bytes = await imageFile.readAsBytes();

      formData.files.add(
        MapEntry(
          'image',
          MultipartFile.fromBytes(
            bytes,
            filename: imageFile.name,
          ),
        ),
      );
    }

    final response = await ApiClient.postMultipart(
      '/api/memories',
      formData,
    );

    return MemoryModel.fromJson(response['data']);
  }

  static Future<void> deleteMemory(int memoryId) async {

    await ApiClient.delete('/api/memories/$memoryId');
  }
  static Future<void> updateMemory({
    required int memoryId,
    required String title,
    required String description,
    required String relationInfo,
  }) async {

    await ApiClient.put(

      '/api/memories/$memoryId',

      data: {

        'title': title,

        'description': description,

        'relationInfo': relationInfo,
      },
    );
  }

}

