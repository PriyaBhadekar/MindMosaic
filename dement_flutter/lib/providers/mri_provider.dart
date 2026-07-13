import 'package:flutter/foundation.dart';
import '../data/services/mri_service.dart';

class MriProvider extends ChangeNotifier {
  final MriService _mriService = MriService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _predictionResult;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get predictionResult => _predictionResult;

  Future<void> predictDementia({
    required int gender,
    required double age,
    required double educ,
    required double ses,
    required double mmse,
  }) async {
    _isLoading = true;
    _error = null;
    _predictionResult = null;
    notifyListeners();

    try {
      final result = await _mriService.predictDementia(
        gender: gender,
        age: age,
        educ: educ,
        ses: ses,
        mmse: mmse,
      );

      _predictionResult = {
        "hasDementia": result["prediction"] == 1,
        "prediction": result["prediction"],
        "probability": (result["probability"] as num).toDouble() * 100,
        "riskLevel": result["riskLevel"],
        "stage": result["stage"],
        "stageCdr": result["stage_cdr"],
        "recommendation": result["recommendation"],
        "emoji": result["emoji"],
      };
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearPrediction() {
    _predictionResult = null;
    _error = null;
    notifyListeners();
  }
}