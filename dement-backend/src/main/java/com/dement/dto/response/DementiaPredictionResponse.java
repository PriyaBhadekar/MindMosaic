package com.dement.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DementiaPredictionResponse {

    // Overall prediction
    private Boolean hasDementia;

    // Probability (0-100)
    private Double probability;

    // Risk Level
    // Very Low Risk
    // Low Risk
    // Moderate Risk
    // High Risk
    // Very High Risk
    private String riskLevel;

    // Dementia Stage
    // Normal
    // Very Mild
    // Mild
    // Moderate-Severe
    private String stage;

    // Recommendation shown to caregiver
    private String recommendation;

    // Emoji for UI
    private String emoji;
}