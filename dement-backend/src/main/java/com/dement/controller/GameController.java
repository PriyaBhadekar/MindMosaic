// REPLACE src/main/java/com/dement/controller/GameController.java
package com.dement.controller;

import com.dement.dto.request.GameScoreSubmitRequest;
import com.dement.dto.response.ApiResponse;
import com.dement.dto.response.FlashcardGameResponse;
import com.dement.dto.response.GameScoreResponse;
import com.dement.enums.GameType;
import com.dement.service.GameService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/games")
@RequiredArgsConstructor
public class GameController {

    private final GameService gameService;

    // ── GET /api/games/memory-flashcard/{caregiverId}?difficulty=EASY
    // Generates a flashcard game from caregiver's uploaded memories
    // Response: FlashcardGameResponse with questions array
    @GetMapping("/memory-flashcard/{caregiverId}")
    public ResponseEntity<ApiResponse<FlashcardGameResponse>> getMemoryFlashcard(
            @PathVariable Long caregiverId,
            @RequestParam(defaultValue = "EASY") String difficulty) {
        return ResponseEntity.ok(ApiResponse.success(
                gameService.getMemoryFlashcardGame(caregiverId, difficulty),
                "Flashcard game ready"));
    }

    // ── GET /api/games/word-search?difficulty=EASY
    // Returns word list and grid configuration for word search game
    @GetMapping("/word-search")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getWordSearch(
            @RequestParam(defaultValue = "EASY") String difficulty) {
        return ResponseEntity.ok(ApiResponse.success(
                gameService.getWordSearchGame(difficulty),
                "Word search game ready"));
    }

    // ── POST /api/games/score
    // Submits a completed game score
    // Request: { patientId, gameType, score, maxScore, difficultyLevel, durationSeconds }
    // Response: GameScoreResponse with percentageScore and grade
    @PostMapping("/score")
    public ResponseEntity<ApiResponse<GameScoreResponse>> submitScore(
            @Valid @RequestBody GameScoreSubmitRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                gameService.submitScore(request),
                "Score saved"));
    }

    // ── GET /api/games/history/{patientId}
    // Returns full score history for a patient (newest first)
    @GetMapping("/history/{patientId}")
    public ResponseEntity<ApiResponse<List<GameScoreResponse>>> getHistory(
            @PathVariable Long patientId) {
        return ResponseEntity.ok(ApiResponse.success(
                gameService.getScoreHistory(patientId),
                "Score history fetched"));
    }

    // ── GET /api/games/history/{patientId}/{gameType}
    // Returns score history filtered by game type
    @GetMapping("/history/{patientId}/{gameType}")
    public ResponseEntity<ApiResponse<List<GameScoreResponse>>> getHistoryByType(
            @PathVariable Long patientId,
            @PathVariable GameType gameType) {
        return ResponseEntity.ok(ApiResponse.success(
                gameService.getScoreHistoryByType(patientId, gameType),
                "Score history fetched"));
    }

    // ── GET /api/games/stats/{patientId}
    // Returns aggregate game statistics
    // Response: { MEMORY_FLASHCARD: { averagePercentage, highScore }, totalGamesPlayed }
    @GetMapping("/stats/{patientId}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getStats(
            @PathVariable Long patientId) {
        return ResponseEntity.ok(ApiResponse.success(
                gameService.getGameStats(patientId),
                "Stats fetched"));
    }

    // ── GET /api/games/top/{patientId}?limit=5
    // Returns top N most recent scores
    @GetMapping("/top/{patientId}")
    public ResponseEntity<ApiResponse<List<GameScoreResponse>>> getTopScores(
            @PathVariable Long patientId,
            @RequestParam(defaultValue = "5") int limit) {
        return ResponseEntity.ok(ApiResponse.success(
                gameService.getTopScores(patientId, limit),
                "Top scores fetched"));
    }

    // ── DELETE /api/games/score/{scoreId}
    // Deletes a specific score entry
    @DeleteMapping("/score/{scoreId}")
    public ResponseEntity<ApiResponse<String>> deleteScore(
            @PathVariable Long scoreId) {
        gameService.deleteScore(scoreId);
        return ResponseEntity.ok(ApiResponse.success("Score deleted"));
    }
}