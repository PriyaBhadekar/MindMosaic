// CREATE lib/providers/voice_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../data/services/voice_service.dart';
import '../data/storage/local_storage.dart';
import '../core/routes/app_routes.dart';
import '../core/navigation/navigation_service.dart';
import 'dart:async';
import '../data/services/schedule_service.dart';

enum VoiceState { idle, listening, processing, speaking }
enum ConversationState {
  idle,
  waitingActivityChoice,
}

class VoiceProvider extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  Timer? _scheduleTimer;
  DateTime? _lastScheduleTrigger;

  ConversationState _conversationState =
      ConversationState.idle;
  VoiceState _state = VoiceState.idle;
  String _currentPrompt = '';
  String _spokenWords = '';
  String? _suggestion;
  bool _sttAvailable = false;
  bool _isLoading = false;

  VoiceState get state => _state;
  String get currentPrompt => _currentPrompt;
  String get spokenWords => _spokenWords;
  String? get suggestion => _suggestion;
  bool get isListening => _state == VoiceState.listening;
  bool get isSpeaking => _state == VoiceState.speaking;
  bool get isProcessing => _state == VoiceState.processing;
  bool get isIdle => _state == VoiceState.idle;
  bool get isLoading => _isLoading;



  VoiceProvider() {
    _initTts();
    _initStt();

    startScheduleMonitoring();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45); // Slower for elderly
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      _state = VoiceState.speaking;
      notifyListeners();
    });
    _tts.setCompletionHandler(() {
      _state = VoiceState.idle;
      notifyListeners();
    });
    _tts.setErrorHandler((_) {
      _state = VoiceState.idle;
      notifyListeners();
    });
  }

  Future<void> _initStt() async {
    _sttAvailable = await _stt.initialize(
      onStatus: (status) async {

        print('STATUS = $status');

        if (status == 'done') {

          if (_state == VoiceState.listening) {

            _state = VoiceState.processing;
            notifyListeners();

            await _logAndRespond();
          }
        }
      },
      onError: (_) {
        _state = VoiceState.idle;
        notifyListeners();
      },
    );
    notifyListeners();
  }

  // ── Fetch wellness prompt from backend ──────────────────────────────
  Future<void> fetchAndSpeakPrompt() async {
    _isLoading = true;
    notifyListeners();

    try {
      final patientId = LocalStorage.getPatientId();
      if (patientId == null) {
        await speak('Hello! How are you feeling today?');
        return;
      }
      final data = await VoiceService.getWellnessPrompt(patientId);
      final prompt = data['promptText'] as String? ??
          'Hello! How are you feeling today?';
      _currentPrompt = prompt;
      await speak(prompt);
    } catch (_) {
      _currentPrompt = 'Hello! How are you feeling today?';
      await speak(_currentPrompt);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── TTS speak ───────────────────────────────────────────────────────
  Future<void> speak(String text) async {
    _currentPrompt = text;
    await _tts.stop();
    await _tts.speak(text);
    notifyListeners();
  }


  Future<void> startScheduleMonitoring() async {

    _scheduleTimer?.cancel();

    _scheduleTimer = Timer.periodic(
      const Duration(minutes: 1),
          (_) async {

        final patientId =
        LocalStorage.getPatientId();

        if (patientId == null) return;

        final schedules =
        await ScheduleService
            .getPatientSchedules(
            patientId);

        final now = TimeOfDay.now();

        for (final schedule in schedules) {

          if (!schedule.active) continue;

          final parts =
          schedule.scheduledTime
              .split(':');

          final hour =
          int.parse(parts[0]);

          final minute =
          int.parse(parts[1]);

          if (now.hour == hour &&
              now.minute == minute) {

            final currentTime = DateTime.now();

            if (_lastScheduleTrigger == null ||
                currentTime
                    .difference(
                    _lastScheduleTrigger!)
                    .inMinutes >=
                    1) {

              _lastScheduleTrigger =
                  currentTime;

              await speak(
                schedule.voiceDescription ??
                    schedule.title,
              );

              await Future.delayed(
                const Duration(seconds: 2),
              );

              await startListening();
            }
          }
        }
      },
    );
  }

  // ── STT listen ──────────────────────────────────────────────────────
  Future<void> startListening() async {

    if (_stt.isListening) {
      return;
    }

    if (!_sttAvailable) {
      await speak(
          'Microphone permission is required. Please allow in settings.');
      return;
    }
    await _tts.stop();
    _spokenWords = '';
    _suggestion = null;
    _state = VoiceState.listening;
    notifyListeners();

    await _stt.listen(
      onResult: (result) {
        _spokenWords = result.recognizedWords;
        notifyListeners();
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
    );
  }

  Future<void> stopListening() async {
    await _stt.stop();
    _state = VoiceState.processing;
    notifyListeners();

    await _logAndRespond();
  }


  // ── Log response + get suggestion ───────────────────────────────────
  Future<void> _logAndRespond() async {

    print('LOG AND RESPOND CALLED');
    print('WORDS = $_spokenWords');

    try {

      final patientId = LocalStorage.getPatientId();

      if (patientId != null) {

        await VoiceService.logVoiceResponse(
          patientId: patientId,
          promptText: _currentPrompt,
          patientResponse:
          _spokenWords.isEmpty
              ? null
              : _spokenWords,
          responseType: 'SPOKEN',
        );
      }

    } catch (_) {}

    print(
        'CONVERSATION STATE = $_conversationState');

    print(
        'SPOKEN WORDS = $_spokenWords');

    final patientId =
    LocalStorage.getPatientId();

    if (patientId == null) {
      return;
    }

    try {

      final aiResponse =
      await VoiceService.aiChat(
        patientId: patientId,
        message: _spokenWords,
      );

      print(
          '========== AI RESPONSE ==========');

      print(
          'WORDS = $_spokenWords');

      print(
          'INTENT = ${aiResponse.intent}');

      print(
          'ACTION = ${aiResponse.action}');

      print(
          'EMOTION = ${aiResponse.emotion}');

      print(
          'RESPONSE = ${aiResponse.response}');

      print(
          '===============================');

      _suggestion =
          aiResponse.response;

      _state = VoiceState.idle;

      notifyListeners();

      await speak(
        aiResponse.response,
      );

      switch (aiResponse.action) {

        case 'OPEN_GAME':

          await Future.delayed(
            const Duration(seconds: 2),
          );

          navigatorKey.currentState
              ?.pushNamed(
            AppRoutes.memoryFlashcard,
          );

          break;

        case 'OPEN_MEMORIES':

          await Future.delayed(
            const Duration(seconds: 2),
          );

          navigatorKey.currentState
              ?.pushNamed(
            AppRoutes.patientMemories,
          );

          break;

        case 'OPEN_MUSIC':

          await Future.delayed(
            const Duration(seconds: 2),
          );

          navigatorKey.currentState
              ?.pushNamed(
            AppRoutes.patientMusic,
          );

          break;

        default:
          break;
      }

    } catch (e, stackTrace) {

      print(
          '========== AI ERROR ==========');

      print(e);

      print(stackTrace);

      _state = VoiceState.idle;

      notifyListeners();
    }
  }


  Future<void> stopAll() async {
    await _tts.stop();
    await _stt.stop();
    _state = VoiceState.idle;
    notifyListeners();
  }



  @override
  void dispose() {
    _scheduleTimer?.cancel();

    _tts.stop();
    _stt.stop();

    super.dispose();
  }


  Future<void> logMood(String mood) async {

    try {

      final patientId =
      LocalStorage.getPatientId();

      if (patientId == null) return;

      await VoiceService.logMood(
        patientId: patientId,
        mood: mood,
      );

      await speak(
        'Thank you for sharing how you feel.',
      );

    } catch (e) {

      print('MOOD LOG ERROR');
      print(e);
    }
  }
}