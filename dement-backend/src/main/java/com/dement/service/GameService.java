// REPLACE src/main/java/com/dement/service/GameService.java
package com.dement.service;

import com.dement.dto.request.GameScoreSubmitRequest;
import com.dement.dto.response.*;
import com.dement.entity.GameScore;
import com.dement.entity.Patient;
import com.dement.enums.GameType;
import com.dement.exception.ResourceNotFoundException;
import com.dement.repository.GameScoreRepository;
import com.dement.repository.MemoryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class GameService {

    private final GameScoreRepository gameScoreRepository;
    private final MemoryRepository memoryRepository;
    private final PatientService patientService;

    @Value("${app.upload.base-dir:uploads}")
    private String uploadBaseDir;

    // Base URL for resolving image paths
    private static final String BASE_URL = "http://localhost:8080";

    // ── Generate memory flashcard game ──────────────────────────────────
    public FlashcardGameResponse getMemoryFlashcardGame(Long caregiverId, String difficulty) {
        List<com.dement.entity.Memory> memories =
                memoryRepository.findByCaregiverId(caregiverId);

        if (memories.isEmpty()) {
            log.warn("No memories found for caregiver: {}", caregiverId);
            return FlashcardGameResponse.builder()
                    .gameType("MEMORY_FLASHCARD")
                    .difficulty(difficulty)
                    .totalQuestions(0)
                    .questions(Collections.emptyList())
                    .build();
        }

        // Determine question count by difficulty
        int questionCount = switch (difficulty.toUpperCase()) {
            case "HARD" -> Math.min(8, memories.size());
            case "MEDIUM" -> Math.min(5, memories.size());
            default -> Math.min(3, memories.size());
        };

        // Shuffle and select
        List<com.dement.entity.Memory> shuffled = new ArrayList<>(memories);
        Collections.shuffle(shuffled);
        List<com.dement.entity.Memory> selected = shuffled.subList(0, questionCount);

        // Build question objects
        List<FlashcardQuestionResponse> questions = selected.stream().map(memory -> {
            // Build wrong options from OTHER memories
            String correctAnswer =
                    memory.getRelationInfo() != null &&
                            !memory.getRelationInfo().isBlank()
                            ? memory.getRelationInfo()
                            : memory.getTitle();

            Set<String> optionSet = new LinkedHashSet<>();

            optionSet.add(correctAnswer);

            List<String> fallbackOptions = List.of(
                    "Mother",
                    "Father",
                    "Brother",
                    "Sister",
                    "Friend",
                    "Grandmother",
                    "Grandfather",
                    "Wife",
                    "Husband",
                    "Daughter",
                    "Son"
            );

            for (String relation : fallbackOptions) {

                if (!relation.equalsIgnoreCase(correctAnswer)) {
                    optionSet.add(relation);
                }

                if (optionSet.size() == 4) {
                    break;
                }
            }

            List<String> finalOptions = new ArrayList<>(optionSet);
            Collections.shuffle(finalOptions);

            // Build options list and shuffle
//            List<String> options = new ArrayList<>();
//            options.add(correctAnswer);
//            options.addAll(wrongOptions);
//            // Ensure no duplicates
//            options = options.stream().distinct().limit(4).collect(Collectors.toList());
//            Collections.shuffle(options);

            // Resolve full image URL
            String imageUrl = null;
            if (memory.getImagePath() != null && !memory.getImagePath().isBlank()) {
                imageUrl = BASE_URL + "/"
                        + memory.getImagePath().replaceAll("\\\\", "/");
            }

            return FlashcardQuestionResponse.builder()
                    .memoryId(memory.getId())
                    .imagePath(memory.getImagePath())
                    .imageUrl(imageUrl)
                    .question("Who is this person?")
                    .description(memory.getDescription())
                    .options(finalOptions)
                    .correctAnswer(correctAnswer)
                    .category(memory.getCategory())
                    .relationInfo(memory.getRelationInfo())
                    .build();
        }).collect(Collectors.toList());

        log.info("Flashcard game generated: {} questions, difficulty: {}",
                questions.size(), difficulty);

        return FlashcardGameResponse.builder()
                .gameType("MEMORY_FLASHCARD")
                .difficulty(difficulty)
                .totalQuestions(questions.size())
                .questions(questions)
                .build();
    }

    // ── Generate word search game ───────────────────────────────────────
    public Map<String, Object> getWordSearchGame(String difficulty) {
        List<String> easyWords = List.of("CAT", "DOG", "SUN", "LOVE", "HOME",
                "BIRD", "TREE", "RAIN");
        List<String> mediumWords = List.of("FAMILY", "MEMORY", "GARDEN",
                "MORNING", "MUSIC", "FLOWER", "FRIEND");
        List<String> hardWords = List.of("CAREGIVER", "HAPPINESS", "REMEMBER",
                "TOGETHER", "SUNSHINE", "BUTTERFLY");

        List<String> words = switch (difficulty.toUpperCase()) {
            case "HARD" -> hardWords;
            case "MEDIUM" -> mediumWords;
            default -> easyWords;
        };

        int gridSize = switch (difficulty.toUpperCase()) {
            case "HARD" -> 14;
            case "MEDIUM" -> 12;
            default -> 10;
        };

        return Map.of(
                "gameType", "WORD_SEARCH",
                "difficulty", difficulty,
                "words", words,
                "gridSize", gridSize,
                "hint", "Find the hidden words in the grid!"
        );
    }

    // ── Submit game score ───────────────────────────────────────────────
    @Transactional
    public GameScoreResponse submitScore(GameScoreSubmitRequest request) {
        Patient patient = patientService.findById(request.getPatientId());

        GameScore score = GameScore.builder()
                .gameType(request.getGameType())
                .score(request.getScore())
                .maxScore(request.getMaxScore())
                .difficultyLevel(request.getDifficultyLevel())
                .durationSeconds(request.getDurationSeconds())
                .patient(patient)
                .build();

        GameScore saved = gameScoreRepository.save(score);
        log.info("Score saved: {} scored {}/{} in {}",
                patient.getName(), request.getScore(),
                request.getMaxScore(), request.getGameType());

        return mapToScoreResponse(saved, patient);
    }

    // ── Get score history for patient ───────────────────────────────────
    public List<GameScoreResponse> getScoreHistory(Long patientId) {
        Patient patient = patientService.findById(patientId);
        return gameScoreRepository
                .findByPatientIdOrderByPlayedAtDesc(patientId)
                .stream()
                .map(g -> mapToScoreResponse(g, patient))
                .collect(Collectors.toList());
    }

    // ── Get score history by game type ──────────────────────────────────
    public List<GameScoreResponse> getScoreHistoryByType(
            Long patientId, GameType gameType) {
        Patient patient = patientService.findById(patientId);
        return gameScoreRepository
                .findByPatientIdAndGameTypeOrderByPlayedAtDesc(patientId, gameType)
                .stream()
                .map(g -> mapToScoreResponse(g, patient))
                .collect(Collectors.toList());
    }

    // ── Get aggregate stats for patient ─────────────────────────────────
    public Map<String, Object> getGameStats(Long patientId) {
        patientService.findById(patientId); // validate patient exists
        Map<String, Object> stats = new LinkedHashMap<>();

        for (GameType type : GameType.values()) {
            Double avgPct = gameScoreRepository
                    .findAveragePercentageByPatientAndGame(patientId, type);
            Integer highScore = gameScoreRepository
                    .findHighScoreByPatientAndGame(patientId, type);

            Map<String, Object> typeStats = new LinkedHashMap<>();
            typeStats.put("averagePercentage",
                    avgPct != null ? Math.round(avgPct * 10.0) / 10.0 : 0.0);
            typeStats.put("highScore", highScore != null ? highScore : 0);

            stats.put(type.name(), typeStats);
        }

        stats.put("totalGamesPlayed",
                gameScoreRepository.countByPatientId(patientId));

        return stats;
    }

    // ── Get recent top scores ───────────────────────────────────────────
    public List<GameScoreResponse> getTopScores(Long patientId, int limit) {
        Patient patient = patientService.findById(patientId);
        return gameScoreRepository
                .findTopScoresByPatient(patientId, PageRequest.of(0, limit))
                .stream()
                .map(g -> mapToScoreResponse(g, patient))
                .collect(Collectors.toList());
    }

    // ── Delete score ────────────────────────────────────────────────────
    @Transactional
    public void deleteScore(Long scoreId) {
        GameScore score = gameScoreRepository.findById(scoreId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "GameScore", "id", scoreId));
        gameScoreRepository.delete(score);
    }

    // ── Mapper ──────────────────────────────────────────────────────────
    private GameScoreResponse mapToScoreResponse(GameScore g, Patient patient) {
        double pct = (g.getMaxScore() != null && g.getMaxScore() > 0)
                ? (g.getScore() * 100.0 / g.getMaxScore()) : 0.0;

        String grade = pct >= 90 ? "A+"
                : pct >= 80 ? "A"
                : pct >= 70 ? "B"
                : pct >= 60 ? "C"
                : pct >= 50 ? "D"
                : "F";

        return GameScoreResponse.builder()
                .id(g.getId())
                .gameType(g.getGameType())
                .score(g.getScore())
                .maxScore(g.getMaxScore())
                .difficultyLevel(g.getDifficultyLevel())
                .durationSeconds(g.getDurationSeconds())
                .patientId(patient.getId())
                .patientName(patient.getName())
                .playedAt(g.getPlayedAt())
                .percentageScore(Math.round(pct * 10.0) / 10.0)
                .grade(grade)
                .build();
    }
}