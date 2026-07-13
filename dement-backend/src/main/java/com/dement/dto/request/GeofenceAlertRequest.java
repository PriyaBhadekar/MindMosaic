package com.dement.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class GeofenceAlertRequest {

    @NotNull
    private Long patientId;

    @NotNull
    private Double currentLatitude;

    @NotNull
    private Double currentLongitude;
}