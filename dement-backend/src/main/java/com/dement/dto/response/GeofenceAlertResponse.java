package com.dement.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class GeofenceAlertResponse {

    private Long id;

    private Long patientId;

    private String patientName;

    private Double distanceFromZone;

    private Double patientLatitude;

    private Double patientLongitude;

    private LocalDateTime triggeredAt;

    private boolean resolved;
    private LocalDateTime lastLocationUpdate;
}