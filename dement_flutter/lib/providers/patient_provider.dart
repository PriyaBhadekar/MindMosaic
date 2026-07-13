import 'dart:io';
import 'package:flutter/material.dart';

import '../data/models/game_model.dart';
import '../data/models/patient_model.dart';
import '../data/services/game_service.dart';
import '../data/services/patient_service.dart';
import '../data/storage/local_storage.dart';

class PatientProvider extends ChangeNotifier {
  List<PatientModel> _patients = [];
  PatientModel? _selected;

  bool _isLoading = false;
  String? _error;

  // ==========================
  // Game Data
  // ==========================

  List<GameScoreModel> _gameHistory = [];
  Map<String, dynamic> _gameStats = {};

  List<GameScoreModel> get gameHistory => _gameHistory;
  Map<String, dynamic> get gameStats => _gameStats;

  // ==========================
  // Getters
  // ==========================

  List<PatientModel> get patients => _patients;
  PatientModel? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void selectPatient(PatientModel patient) {
    _selected = patient;
    notifyListeners();
  }

  // ==========================
  // Fetch Patients
  // ==========================

  Future<void> fetchPatients() async {
    _setLoading(true);
    _setError(null);

    try {
      final caregiverId = LocalStorage.getUserId();

      if (caregiverId == null || caregiverId == 0) {
        throw Exception("Invalid caregiver id");
      }

      _patients =
          await PatientService.getPatientsForCaregiver(caregiverId);
    } catch (e) {
      _setError(_parse(e));
    } finally {
      _setLoading(false);
    }
  }

  // ==========================
  // Add Patient
  // ==========================

  Future<bool> addPatient({
    required String name,
    int? age,
    String? address,
    String? emergencyContactNumber,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final caregiverId = LocalStorage.getUserId();

      if (caregiverId == null || caregiverId == 0) {
        throw Exception("Invalid caregiver id");
      }

      final patient = await PatientService.createPatient(
        caregiverId: caregiverId,
        name: name,
        age: age,
        address: address,
        emergencyContactNumber: emergencyContactNumber,
        phoneNumber: phoneNumber,
      );

      _patients.add(patient);

      notifyListeners();

      return true;
    } catch (e) {
      _setError(_parse(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================
  // Update Patient
  // ==========================

  Future<bool> updatePatient(
    int patientId,
    Map<String, dynamic> data,
  ) async {
    _setLoading(true);
    _setError(null);

    try {
      final updated =
          await PatientService.updatePatient(patientId, data);

      final index =
          _patients.indexWhere((p) => p.id == patientId);

      if (index != -1) {
        _patients[index] = updated;
      }

      if (_selected?.id == patientId) {
        _selected = updated;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _setError(_parse(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================
  // Upload Patient Photo
  // ==========================

  Future<bool> uploadPhoto(
    int patientId,
    File file,
  ) async {
    _setLoading(true);
    _setError(null);

    try {
      final updated =
          await PatientService.uploadPatientPhoto(
        patientId,
        file,
      );

      final index =
          _patients.indexWhere((p) => p.id == patientId);

      if (index != -1) {
        _patients[index] = updated;
      }

      if (_selected?.id == patientId) {
        _selected = updated;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _setError(_parse(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ====================================================
  // GAME HISTORY
  // ====================================================

  Future<void> fetchPatientGameHistory(int patientId) async {
    try {
      _gameHistory =
          await GameService.getScoreHistory(patientId);

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ====================================================
  // GAME STATS
  // ====================================================

  Future<void> fetchPatientGameStats(int patientId) async {
    try {
      _gameStats =
          await GameService.getGameStats(patientId);

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ====================================================
  // LOAD EVERYTHING
  // ====================================================

  Future<void> loadPatientPerformance(int patientId) async {
    await Future.wait([
      fetchPatientGameHistory(patientId),
      fetchPatientGameStats(patientId),
    ]);
  }

  // ====================================================
  // ERROR PARSER
  // ====================================================

  String _parse(Object e) {
    final message = e.toString();

    if (message.contains("403")) {
      return "Access denied from backend.";
    }

    if (message.contains("404")) {
      return "Backend endpoint not found.";
    }

    if (message.contains("500")) {
      return "Backend server error.";
    }

    if (message.contains("Connection refused") ||
        message.contains("SocketException")) {
      return "Cannot reach server. Is backend running?";
    }

    return "Something went wrong. Please try again.";
  }
}