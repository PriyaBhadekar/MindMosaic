// REPLACE lib/data/services/voice_service.dart
import 'api_client.dart';
import '../models/ai_chat_response.dart';

class VoiceService {

  // GET /api/voice/prompt/{patientId}
  static Future<Map<String, dynamic>> getWellnessPrompt(int patientId) async {
    final response = await ApiClient.get('/api/voice/prompt/$patientId');
    return response['data'] as Map<String, dynamic>;
  }

  static Future<AiChatResponse> aiChat({
    required int patientId,
    required String message,
  }) async {

    final response = await ApiClient.post(
      '/api/voice/ai-chat',
      data: {
        'patientId': patientId,
        'message': message,
      },
    );

    return AiChatResponse.fromJson(
      response['data'],
    );
  }

  // POST /api/voice/log
  static Future<Map<String, dynamic>> logVoiceResponse({
    required int patientId,
    required String promptText,
    String? patientResponse,
    String? responseType,
  }) async {
    final response = await ApiClient.post('/api/voice/log', data: {
      'patientId': patientId,
      'promptText': promptText,
      'patientResponse': patientResponse,
      'responseType': responseType ?? 'SPOKEN',
    });
    return response['data'] as Map<String, dynamic>;
  }

  // POST /api/voice/mood
  static Future<Map<String, dynamic>> logMood({
    required int patientId,
    required String mood,
    String? notes,
  }) async {
    final response = await ApiClient.post('/api/voice/mood', data: {
      'patientId': patientId,
      'mood': mood,
      'notes': notes,
    });
    return response['data'] as Map<String, dynamic>;
  }

  // POST /api/voice/sos
  static Future<Map<String, dynamic>> triggerSos({
    required int patientId,
    String alertType = 'MANUAL_SOS',
    double? latitude,
    double? longitude,
  }) async {
    final response = await ApiClient.post('/api/voice/sos', data: {
      'patientId': patientId,
      'alertType': alertType,
      'patientLatitude': latitude,
      'patientLongitude': longitude,
    });
    return response['data'] as Map<String, dynamic>;
  }

  // GET /api/voice/logs/{patientId}
  static Future<List<dynamic>> getVoiceLogs(int patientId) async {
    final response = await ApiClient.get('/api/voice/logs/$patientId');
    return response['data'] as List<dynamic>;
  }

  // GET /api/voice/mood-logs/{patientId}
  static Future<List<dynamic>> getMoodLogs(int patientId) async {
    final response = await ApiClient.get('/api/voice/mood-logs/$patientId');
    return response['data'] as List<dynamic>;
  }

  // GET /api/voice/mood-stats/{patientId}
  static Future<Map<String, dynamic>> getMoodStats(int patientId) async {
    final response = await ApiClient.get('/api/voice/mood-stats/$patientId');
    return response['data'] as Map<String, dynamic>;
  }

  // GET /api/voice/sos-alerts (caregiver — uses JWT to identify)
  static Future<List<dynamic>> getSosAlerts() async {
    final response = await ApiClient.get('/api/voice/sos-alerts');
    return response['data'] as List<dynamic>;
  }

  // GET /api/voice/distress (caregiver)
  static Future<List<dynamic>> getDistressLogs() async {
    final response = await ApiClient.get('/api/voice/distress');
    return response['data'] as List<dynamic>;
  }

  // PATCH /api/voice/sos-alerts/{alertId}/resolve
  static Future<void> resolveSosAlert(int alertId) async {
    await ApiClient.patch('/api/voice/sos-alerts/$alertId/resolve');
  }

  // DELETE /api/voice/log/{logId}
  static Future<void> deleteVoiceLog(int logId) async {
    await ApiClient.delete('/api/voice/log/$logId');
  }
}