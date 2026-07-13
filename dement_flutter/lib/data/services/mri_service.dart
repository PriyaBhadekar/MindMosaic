import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';

class MriService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<Map<String, dynamic>> predictDementia({
    required int gender,
    required double age,
    required double educ,
    required double ses,
    required double mmse,
  }) async {
    try {
      print("========= AI REQUEST =========");

      final response = await _dio.post(
        "/api/dementia/predict",
        data: {
          "gender": gender,
          "age": age,
          "educ": educ,
          "ses": ses,
          "mmse": mmse,
        },
      );

      print("========= AI RESPONSE =========");
      print(response.data);

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      print("========= AI ERROR =========");
      print(e.response?.data);

      throw Exception(
        e.response?.data.toString() ??
            e.message ??
            "Prediction failed",
      );
    }
  }
}