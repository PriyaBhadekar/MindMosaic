package com.dement.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class PatientLinkRequest {

    @NotBlank(message = "Caregiver unique code is required")
    private String uniqueCode;
}