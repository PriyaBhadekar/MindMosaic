// REPLACE lib/data/services/geofence_service.dart
import 'api_client.dart';
import '../models/geofence_model.dart';

class GeofenceService {
  // GET /api/geofence
  static Future<GeofenceModel> getGeofence() async {
    final response = await ApiClient.get('/api/geofence');
    return GeofenceModel.fromJson(response['data']);
  }

  // POST /api/geofence
  static Future<GeofenceModel> setGeofence({
    required double latitude,
    required double longitude,
    required double radius,
    String? address,
  }) async {
    final response = await ApiClient.post('/api/geofence', data: {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'address': address,
    });
    return GeofenceModel.fromJson(response['data']);
  }

  static Future<bool> checkPatientLocation({
    required int patientId,
    required double latitude,
    required double longitude,
  }) async {

    final response = await ApiClient.post(
      '/api/geofence/check-location',
      data: {
        'patientId': patientId,
        'currentLatitude': latitude,
        'currentLongitude': longitude,
      },
    );

    return response['data'] ?? false;
  }

  static Future<List<dynamic>> getAlerts() async {

    final response =
    await ApiClient.get(
      '/api/geofence/alerts',
    );

    return response['data'];
  }
}