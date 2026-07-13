import '../models/emergency_contact_model.dart';
import 'api_client.dart';

class EmergencyService {
  static Future<List<EmergencyContactModel>> getContacts() async {
    final response = await ApiClient.get('/api/emergency-contacts');
    final List data = response['data'] ?? [];
    return data.map((e) => EmergencyContactModel.fromJson(e)).toList();
  }

  static Future<EmergencyContactModel> addContact({
    required String name,
    required String phoneNumber,
    String? relationship,
    bool primary = false,
  }) async {
    final response = await ApiClient.post('/api/emergency-contacts', data: {
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'primary': primary,
    });
    return EmergencyContactModel.fromJson(response['data']);
  }

  static Future<void> deleteContact(int contactId) async {
    await ApiClient.delete('/api/emergency-contacts/$contactId');
  }

  static Future<EmergencyContactModel> updateContact({
    required int id,
    required String name,
    required String phoneNumber,
    String? relationship,
    bool primary = false,
  }) async {

    final response = await ApiClient.put(
      '/api/emergency-contacts/$id',
      data: {
        'name': name,
        'phoneNumber': phoneNumber,
        'relationship': relationship,
        'primary': primary,
      },
    );

    return EmergencyContactModel.fromJson(
      response['data'],
    );
  }
}