import '../models/game_model.dart';
import 'api_client.dart';

class GameService {
  // =========================
  // Memory Flashcard
  // =========================

  static Future<Map<String, dynamic>> getMemoryFlashcardGame(
      int caregiverId, String difficulty) async {
    final response = await ApiClient.get(
      '/api/games/memory-flashcard/$caregiverId',
      params: {
        'difficulty': difficulty,
      },
    );

    return response['data'] as Map<String, dynamic>;
  }

  // =========================
  // Word Search
  // =========================

  static Future<Map<String, dynamic>> getWordSearchGame(
      String difficulty) async {
    final response = await ApiClient.get(
      '/api/games/word-search',
      params: {
        'difficulty': difficulty,
      },
    );

    return response['data'] as Map<String, dynamic>;
  }

  // =========================
  // Save Score
  // =========================

  static Future<GameScoreModel> saveScore({
    required int patientId,
    required String gameType,
    required int score,
    required int maxScore,
    String? difficultyLevel,
    int? durationSeconds,
  }) async {
    final response = await ApiClient.post(
      '/api/games/score',
      data: {
        'patientId': patientId,
        'gameType': gameType,
        'score': score,
        'maxScore': maxScore,
        'difficultyLevel': difficultyLevel,
        'durationSeconds': durationSeconds,
      },
    );

    return GameScoreModel.fromJson(response['data']);
  }

  // =========================
  // Score History
  // =========================

  static Future<List<GameScoreModel>> getScoreHistory(
      int patientId) async {
    final response = await ApiClient.get(
      '/api/games/history/$patientId',
    );

    final List data = response['data'] ?? [];

    return data
        .map((e) => GameScoreModel.fromJson(e))
        .toList();
  }

  // =========================
  // Statistics
  // =========================

  static Future<Map<String, dynamic>> getGameStats(
      int patientId) async {
    final response = await ApiClient.get(
      '/api/games/stats/$patientId',
    );

    return response['data'] as Map<String, dynamic>;
  }

  // =========================
  // Top Scores
  // =========================

  static Future<List<GameScoreModel>> getTopScores(
      int patientId,
      int limit,
      ) async {
    final response = await ApiClient.get(
      '/api/games/top/$patientId',
      params: {
        'limit': limit,
      },
    );

    final List data = response['data'] ?? [];

    return data
        .map((e) => GameScoreModel.fromJson(e))
        .toList();
  }
}