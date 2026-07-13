class AppConstants {
  // Backend base URL - Android Emulator
  static const String baseUrl = 'http://localhost:8080';

  // For real device on local WiFi, replace with your laptop IP:
  // static const String baseUrl = 'http://192.168.1.X:8080/api';

  static const String tokenKey = 'jwt_token';
  static const String roleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String uniqueCodeKey = 'unique_code';
  static const String patientIdKey = 'patient_id';
  static const String caregiverIdKey = 'caregiver_id';

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Roles
  static const String roleCaregiver = 'CAREGIVER';
  static const String rolePatient = 'PATIENT';
}