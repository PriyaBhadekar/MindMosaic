import '../models/alert_model.dart';
import 'api_client.dart';

class AlertService {
  static Future<List<SosAlertModel>> getUnresolvedAlerts() async {
    final response = await ApiClient.get('/alerts/unresolved');
    final List data = response['data'] ?? [];
    return data.map((e) => SosAlertModel.fromJson(e)).toList();
  }

  static Future<List<SosAlertModel>> getAllAlerts() async {
    final response = await ApiClient.get('/alerts');
    final List data = response['data'] ?? [];
    return data.map((e) => SosAlertModel.fromJson(e)).toList();
  }

  static Future<void> resolveAlert(int alertId) async {
    await ApiClient.patch('/alerts/$alertId/resolve');
  }
}