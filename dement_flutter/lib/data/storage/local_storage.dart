import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await _prefs?.setString(AppConstants.tokenKey, token);
  }

  static String? getToken() => _prefs?.getString(AppConstants.tokenKey);

  static Future<void> saveRole(String role) async {
    await _prefs?.setString(AppConstants.roleKey, role);
  }

  static String? getRole() => _prefs?.getString(AppConstants.roleKey);

  static Future<void> saveUserId(int userId) async {
    await _prefs?.setInt(AppConstants.userIdKey, userId);
  }

  static int? getUserId() => _prefs?.getInt(AppConstants.userIdKey);

  static Future<void> saveUserName(String name) async {
    await _prefs?.setString(AppConstants.userNameKey, name);
  }

  static String? getUserName() => _prefs?.getString(AppConstants.userNameKey);

  static Future<void> saveUniqueCode(String code) async {
    await _prefs?.setString(AppConstants.uniqueCodeKey, code);
  }

  static String? getUniqueCode() => _prefs?.getString(AppConstants.uniqueCodeKey);

  static Future<void> savePatientId(int patientId) async {
    await _prefs?.setInt(AppConstants.patientIdKey, patientId);
  }

  static int? getPatientId() => _prefs?.getInt(AppConstants.patientIdKey);

  static Future<void> saveCaregiverId(int caregiverId) async {
    await _prefs?.setInt(AppConstants.caregiverIdKey, caregiverId);
  }

  static int? getCaregiverId() => _prefs?.getInt(AppConstants.caregiverIdKey);

  static bool isLoggedIn() => getToken() != null && getToken()!.isNotEmpty;

  static bool isCaregiver() => getRole() == AppConstants.roleCaregiver;

  static bool isPatient() => getRole() == AppConstants.rolePatient;

  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}