import '../models/schedule_model.dart';
import 'api_client.dart';

class ScheduleService {
  static Future<List<ScheduleModel>> getSchedules() async {
    final response = await ApiClient.get('/api/schedules');
    final List data = response['data'] ?? [];
    return data.map((e) => ScheduleModel.fromJson(e)).toList();
  }

  static Future<List<ScheduleModel>>
  getPatientSchedules(int patientId) async {

    final response = await ApiClient.get(
      '/api/schedules/patient/$patientId',
    );

    final List data = response['data'];

    return data
        .map((e) => ScheduleModel.fromJson(e))
        .toList();
  }

  static Future<ScheduleModel> createSchedule({
    required String title,
    required String scheduledTime,
    String? voiceDescription,
    String repeatType = 'DAILY',
    String reminderType = 'VOICE',
  }) async {
    final response = await ApiClient.post('/api/schedules', data: {
      'title': title,
      'scheduledTime': scheduledTime,
      'voiceDescription': voiceDescription,
      'repeatType': repeatType,
      'reminderType': reminderType,
    });
    return ScheduleModel.fromJson(response['data']);
  }

  static Future<void> toggleSchedule(int scheduleId) async {
    await ApiClient.patch('/api/schedules/$scheduleId/toggle');
  }

  static Future<void> deleteSchedule(int scheduleId) async {
    await ApiClient.delete('/api/schedules/$scheduleId');
  }

  static Future<void> updateSchedule({

    required int scheduleId,
    required String title,
    required String scheduledTime,
    required String voiceDescription,
    required String repeatType,
    required String reminderType,

  }) async {

    await ApiClient.put(

      '/api/schedules/$scheduleId',

      data: {

        'title': title,

        'scheduledTime':
        scheduledTime,

        'voiceDescription':
        voiceDescription,

        'repeatType':
        repeatType,

        'reminderType':
        reminderType,
      },
    );
  }
}