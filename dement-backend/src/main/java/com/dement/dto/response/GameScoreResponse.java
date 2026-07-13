// CREATE src/main/java/com/dement/dto/response/GameScoreResponse.java
package com.dement.dto.response;

import com.dement.enums.DifficultyLevel;
import com.dement.enums.GameType;
import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GameScoreResponse {
    private Long id;
    private GameType gameType;
    private Integer score;
    private Integer maxScore;
    private DifficultyLevel difficultyLevel;
    private Integer durationSeconds;
    private Long patientId;
    private String patientName;
    private LocalDateTime playedAt;
    // Derived
    private Double percentageScore;
    private String grade;
}