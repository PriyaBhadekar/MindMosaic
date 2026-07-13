package com.dement.dto.response;

import com.dement.enums.DementiaStage;
import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MriResultResponse {
    private Long id;
    private String imagePath;
    private Boolean dementiaDetected;
    private DementiaStage dementiaStage;
    private Double confidenceScore;
    private String processingStatus;
    private LocalDateTime createdAt;
}