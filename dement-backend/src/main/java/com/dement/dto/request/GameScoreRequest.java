package com.dement.dto.request;

import com.dement.enums.DifficultyLevel;
import com.dement.enums.GameType;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class GameScoreRequest {

    @NotNull
    private Long patientId;

    @NotNull
    private GameType gameType;

    @NotNull
    private Integer score;

    private Integer maxScore;
    private DifficultyLevel difficultyLevel;
    private Integer durationSeconds;
}