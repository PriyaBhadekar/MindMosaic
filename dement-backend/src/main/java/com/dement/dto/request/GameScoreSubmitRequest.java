// CREATE src/main/java/com/dement/dto/request/GameScoreSubmitRequest.java
package com.dement.dto.request;

import com.dement.enums.DifficultyLevel;
import com.dement.enums.GameType;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class GameScoreSubmitRequest {

    @NotNull(message = "Patient ID is required")
    private Long patientId;

    @NotNull(message = "Game type is required")
    private GameType gameType;

    @NotNull(message = "Score is required")
    private Integer score;

    @NotNull(message = "Max score is required")
    private Integer maxScore;

    private DifficultyLevel difficultyLevel;
    private Integer durationSeconds;
}