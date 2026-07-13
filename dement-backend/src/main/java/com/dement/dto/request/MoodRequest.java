package com.dement.dto.request;

import com.dement.enums.MoodType;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class MoodRequest {

    @NotNull(message = "Patient ID is required")
    private Long patientId;

    @NotNull(message = "Mood is required")
    private MoodType mood;

    private String notes;
}