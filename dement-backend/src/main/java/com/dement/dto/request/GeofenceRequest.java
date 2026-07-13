package com.dement.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class GeofenceRequest {

    @NotNull(message = "Latitude is required")
    private Double latitude;

    @NotNull(message = "Longitude is required")
    private Double longitude;

    @NotNull(message = "Radius is required")
    private Double radius;

    private String address;
}