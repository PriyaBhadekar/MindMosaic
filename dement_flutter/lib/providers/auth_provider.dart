// REPLACE lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../data/models/auth_model.dart';
import '../data/models/caregiver_model.dart';
import '../data/services/auth_service.dart';
import '../data/storage/local_storage.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  CaregiverModel? _caregiver;

  String _email = '';
  String? _phoneNumber;

  bool get isLoading => _isLoading;
  String? get error => _error;
  CaregiverModel? get caregiver => _caregiver;

  String get email => _email;
  String? get phoneNumber => _phoneNumber;

  bool get isLoggedIn => LocalStorage.isLoggedIn();
  bool get isCaregiver => LocalStorage.isCaregiver();
  bool get isPatient => LocalStorage.isPatient();
  String get userName => LocalStorage.getUserName() ?? '';
  int? get userId => LocalStorage.getUserId();
  int? get caregiverId => LocalStorage.getCaregiverId() ?? LocalStorage.getUserId();
  int? get patientId => LocalStorage.getPatientId();
  String get uniqueCode => LocalStorage.getUniqueCode() ?? '';

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Register ──────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final auth = await AuthService.registerCaregiver(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
      await _persistAuth(auth);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final auth = await AuthService.loginCaregiver(
        email: email,
        password: password,
      );
      await _persistAuth(auth);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await AuthService.logout();
    _caregiver = null;
    notifyListeners();
  }

  // ── Persist auth data ─────────────────────────────────────────────────
  Future<void> _persistAuth(AuthResponse auth) async {

    await AuthService.saveAuthData(auth);

    await LocalStorage.saveCaregiverId(auth.userId);

    _email = auth.email ?? '';

    _phoneNumber = auth.phoneNumber;

    notifyListeners();
  }
  // ── Parse DioException or generic error ───────────────────────────────
  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.contains('401') || msg.contains('Unauthorized')) {
      return 'Invalid email or password.';
    }
    if (msg.contains('409') || msg.contains('Conflict')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('SocketException') ||
        msg.contains('Connection refused') ||
        msg.contains('Failed host lookup')) {
      return 'Cannot reach server. Check your connection.';
    }
    if (msg.contains('TimeoutException') || msg.contains('timed out')) {
      return 'Request timed out. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}