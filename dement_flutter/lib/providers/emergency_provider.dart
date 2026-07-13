// CREATE lib/providers/emergency_provider.dart
import 'package:flutter/material.dart';
import '../data/models/emergency_contact_model.dart';
import '../data/services/emergency_service.dart';

class EmergencyProvider extends ChangeNotifier {
  List<EmergencyContactModel> _contacts = [];
  bool _isLoading = false;
  String? _error;

  List<EmergencyContactModel> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }
  void clearError() { _error = null; notifyListeners(); }

  Future<void> fetchContacts() async {
    _setLoading(true);
    _setError(null);
    try {
      _contacts = await EmergencyService.getContacts();
    } catch (e) {
      _setError(_parse(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addContact({
    required String name,
    required String phoneNumber,
    String? relationship,
    bool primary = false,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final c = await EmergencyService.addContact(
        name: name,
        phoneNumber: phoneNumber,
        relationship: relationship,
        primary: primary,
      );
      _contacts.add(c);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_parse(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteContact(int id) async {

    try {

      await EmergencyService.deleteContact(id);

      _contacts.removeWhere((c) => c.id == id);

      notifyListeners();

      return true;

    } catch (e) {

      _setError(e.toString());

      return false;
    }
  }

  Future<bool> updateContact({
    required int id,
    required String name,
    required String phoneNumber,
    String? relationship,
    bool primary = false,
  }) async {

    try {

      final updated =
      await EmergencyService.updateContact(
        id: id,
        name: name,
        phoneNumber: phoneNumber,
        relationship: relationship,
        primary: primary,
      );

      final index =
      _contacts.indexWhere((c) => c.id == id);

      if (index != -1) {
        _contacts[index] = updated;
      }

      notifyListeners();

      return true;

    } catch (e) {

      _setError(e.toString());

      return false;
    }
  }

  String _parse(Object e) {
    final s = e.toString();
    if (s.contains('Connection refused') || s.contains('SocketException')) {
      return 'Cannot reach server. Is the backend running?';
    }
    return 'Something went wrong. Please try again.';
  }


}