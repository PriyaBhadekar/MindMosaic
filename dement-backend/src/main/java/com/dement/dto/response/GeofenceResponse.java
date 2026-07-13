package com.dement.dto.response;

import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class GeofenceResponse {
    private Long id;
    private Double latitude;
    private Double longitude;
    private Double radius;
    private String address;
    private boolean active;
}