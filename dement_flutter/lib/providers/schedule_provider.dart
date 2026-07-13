// CREATE lib/providers/schedule_provider.dart
import 'package:flutter/material.dart';
import '../data/models/schedule_model.dart';
import '../data/services/schedule_service.dart';

class ScheduleProvider extends ChangeNotifier {
  List<ScheduleModel> _schedules = [];
  bool _isLoading = false;
  String? _error;

  List<ScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }
  void clearError() { _error = null; notifyListeners(); }

  Future<void> fetchSchedules() async {
    _setLoading(true);
    _setError(null);
    try {
      _schedules = await ScheduleService.getSchedules();
    } catch (e) {
      _setError(_parse(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addSchedule({
    required String title,
    required String scheduledTime,
    String? voiceDescription,
    String repeatType = 'DAILY',
    String reminderType = 'VOICE',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final s = await ScheduleService.createSchedule(
        title: title,
        scheduledTime: scheduledTime,
        voiceDescription: voiceDescription,
        repeatType: repeatType,
        reminderType: reminderType,
      );
      _schedules.insert(0, s);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_parse(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggle(int id) async {
    try {
      await ScheduleService.toggleSchedule(id);
      final i = _schedules.indexWhere((s) => s.id == id);
      if (i != -1) {
        final old = _schedules[i];
        // Create a toggled copy
        _schedules[i] = ScheduleModel(
          id: old.id,
          title: old.title,
          scheduledTime: old.scheduledTime,
          voiceDescription: old.voiceDescription,
          repeatType: old.repeatType,
          reminderType: old.reminderType,
          active: !old.active,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSchedule(int id) async {
    try {
      await ScheduleService.deleteSchedule(id);
      _schedules.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_parse(e));
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

  Future<void> updateSchedule({

    required int scheduleId,
    required String title,
    required String scheduledTime,
    required String voiceDescription,
    required String repeatType,
    required String reminderType,

  }) async {

    await ScheduleService.updateSchedule(

      scheduleId: scheduleId,

      title: title,

      scheduledTime: scheduledTime,

      voiceDescription: voiceDescription,

      repeatType: repeatType,

      reminderType: reminderType,
    );

    await fetchSchedules();
  }
}