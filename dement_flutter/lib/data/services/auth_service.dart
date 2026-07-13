import '../models/auth_model.dart';
import '../models/patient_model.dart';
import '../storage/local_storage.dart';
import 'api_client.dart';

class AuthService {

  static Future<AuthResponse> registerCaregiver({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {

    final response = await ApiClient.post(
      '/api/auth/caregiver/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
      },
    );

    print("REGISTER RESPONSE: $response");

    return AuthResponse.fromJson(response['data']);
  }

  static Future<AuthResponse> loginCaregiver({
    required String email,
    required String password,
  }) async {

    final response = await ApiClient.post(
      '/api/auth/caregiver/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    print("LOGIN RESPONSE: $response");

    return AuthResponse.fromJson(response['data']);
  }

  static Future<PatientModel> linkPatient({
    required String patientCode,
  }) async {

    final response = await ApiClient.get(
      '/api/patient/link/$patientCode',
    );

    print('LINK PATIENT RESPONSE: $response');

    return PatientModel.fromJson(response['data']);
  }

  static Future<void> saveAuthData(AuthResponse auth) async {

    print('==========================');
    print('SAVING AUTH DATA');
    print('USER ID: ${auth.userId}');
    print('ROLE: ${auth.role}');
    print('==========================');

    await LocalStorage.saveToken(auth.accessToken);

    await LocalStorage.saveRole(auth.role);

    await LocalStorage.saveUserId(auth.userId);

    /// IMPORTANT
    if (auth.role == 'CAREGIVER') {
      await LocalStorage.saveCaregiverId(auth.userId);
    }

    if (auth.role == 'PATIENT') {
      await LocalStorage.savePatientId(auth.userId);
    }

    await LocalStorage.saveUserName(auth.name);

    if (auth.uniqueCode != null) {
      await LocalStorage.saveUniqueCode(auth.uniqueCode!);
    }

    print('==========================');
    print('STORED USER ID: ${LocalStorage.getUserId()}');
    print('STORED CAREGIVER ID: ${LocalStorage.getCaregiverId()}');
    print('==========================');
  }

  static Future<void> logout() async {
    await LocalStorage.clearAll();
    ApiClient.reset();
  }
}