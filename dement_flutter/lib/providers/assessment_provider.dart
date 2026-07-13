import 'package:flutter/material.dart';

class AssessmentProvider extends ChangeNotifier {
  // =====================================================
  // Patient Information
  // =====================================================

  int gender = 0; // 0 = Female, 1 = Male
  double age = 65;
  double education = 12;
  double ses = 2;

  // =====================================================
  // MMSE Score
  // =====================================================

  int mmseScore = 30;

  /// Getter used by DementiaDetectionScreen
  int get mmse => mmseScore;

  // =====================================================
  // Prediction Result
  // =====================================================

  Map<String, dynamic>? prediction;

  bool loading = false;

  // =====================================================
  // MMSE Answers
  // =====================================================

  final Map<String, dynamic> answers = {};

  // =====================================================
  // Patient Information
  // =====================================================

  void setPatientInfo({
    required int gender,
    required double age,
    required double education,
    required double ses,
  }) {
    this.gender = gender;
    this.age = age;
    this.education = education;
    this.ses = ses;

    notifyListeners();
  }

  // =====================================================
  // MMSE Answers
  // =====================================================

  void setAnswer(String key, dynamic value) {
    answers[key] = value;
    notifyListeners();
  }

  dynamic getAnswer(String key) {
    return answers[key];
  }

  // =====================================================
  // MMSE
  // =====================================================

  void setMMSE(int score) {
    mmseScore = score;
    notifyListeners();
  }

  // =====================================================
  // Prediction
  // =====================================================

  void setPrediction(Map<String, dynamic> result) {
    prediction = result;
    notifyListeners();
  }

  Map<String, dynamic>? getPrediction() {
    return prediction;
  }

  // =====================================================
  // Loading
  // =====================================================

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  // =====================================================
  // Reset Assessment
  // =====================================================

  void reset() {
    answers.clear();

    prediction = null;

    loading = false;

    mmseScore = 30;

    gender = 0;
    age = 65;
    education = 12;
    ses = 2;

    notifyListeners();
  }
}