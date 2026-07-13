// REPLACE lib/providers/game_provider.dart
import 'package:flutter/material.dart';
import '../data/models/game_model.dart';
import '../data/services/game_service.dart';
import '../data/services/api_client.dart';    // ADD THIS
import '../data/storage/local_storage.dart';

enum GameStatus { idle, playing, finished }

class GameProvider extends ChangeNotifier {
  List<FlashcardQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;
  GameStatus _status = GameStatus.idle;
  bool _isLoading = false;
  String? _error;
  String _difficulty = 'EASY';
  List<GameScoreModel> _history = [];

  List<FlashcardQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  String? get selectedAnswer => _selectedAnswer;
  bool get answered => _answered;
  GameStatus get status => _status;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get difficulty => _difficulty;
  List<GameScoreModel> get history => _history;

  FlashcardQuestion? get currentQuestion =>
      _questions.isEmpty ? null : _questions[_currentIndex];
  bool get isLastQuestion => _currentIndex >= _questions.length - 1;
  double get progressPercent =>
      _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length;

  void setDifficulty(String d) { _difficulty = d; notifyListeners(); }

  Future<void> loadFlashcardGame() async {
    _isLoading = true;
    _error = null;
    _status = GameStatus.idle;
    notifyListeners();

    try {
      int? caregiverId = LocalStorage.getCaregiverId();

      // Fallback: fetch caregiverId from patient detail
      if (caregiverId == null) {
        final patientId = LocalStorage.getPatientId();
        if (patientId == null) {
          _error = 'Please log in again.';
          _isLoading = false;
          notifyListeners();
          return;
        }
        try {
          final resp = await ApiClient.get('/patients/$patientId');
          final data = resp['data'] as Map<String, dynamic>;
          final cid = data['caregiverId'];
          caregiverId = cid is int ? cid : int.tryParse(cid.toString());
          if (caregiverId != null) {
            await LocalStorage.saveCaregiverId(caregiverId);
          }
        } catch (_) {}
      }

      if (caregiverId == null) {
        _error = 'Not linked to a caregiver. Please re-link your device.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final data = await GameService.getMemoryFlashcardGame(caregiverId, _difficulty);
      final rawQ = data['questions'] as List<dynamic>? ?? [];

      if (rawQ.isEmpty) {
        _error = 'No memories found. Ask your caregiver to add family photos first.';
        _questions = [];
      } else {
        _questions = rawQ
            .map((q) => FlashcardQuestion.fromJson(q as Map<String, dynamic>))
            .toList();
        _error = null;
      }

      _currentIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _answered = false;
      _status = GameStatus.idle;
    } catch (e) {
      _error = e.toString().contains('Connection refused')
          ? 'Cannot reach server. Is the backend running?'
          : 'Failed to load game. Please try again.';
      _questions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // THIS WAS MISSING — caused game to stay on idle screen
  void startGame() {
    if (_questions.isEmpty) return;
    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _answered = false;
    _status = GameStatus.playing;
    notifyListeners();
  }

  void selectAnswer(String answer) {
    if (_answered) return;
    _selectedAnswer = answer;
    _answered = true;
    final q = currentQuestion;
    if (q != null && answer == q.correctAnswer) _score++;
    notifyListeners();
  }

  void nextQuestion() {
    if (isLastQuestion) {
      _status = GameStatus.finished;
      _saveScore();
    } else {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
    }
    notifyListeners();
  }

  Future<void> _saveScore() async {
    try {
      final patientId = LocalStorage.getPatientId();
      if (patientId == null) return;
      await GameService.saveScore(
        patientId: patientId,
        gameType: 'MEMORY_FLASHCARD',
        score: _score,
        maxScore: _questions.length,
        difficultyLevel: _difficulty,
      );
    } catch (_) {}
  }

  void restart() {
    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _answered = false;
    _status = GameStatus.playing;
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    try {
      final patientId = LocalStorage.getPatientId();
      if (patientId == null) return;
      _history = await GameService.getScoreHistory(patientId);
      notifyListeners();
    } catch (_) {}
  }

  void reset() {
    _status = GameStatus.idle;
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _answered = false;
    notifyListeners();
  }
}