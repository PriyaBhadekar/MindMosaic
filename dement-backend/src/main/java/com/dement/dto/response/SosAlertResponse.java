// CREATE src/main/java/com/dement/dto/response/SosAlertResponse.java
package com.dement.dto.response;

import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SosAlertResponse {
    private Long id;
    private String alertType;
    private String alertMessage;
    private boolean resolved;
    private Double patientLatitude;
    private Double patientLongitude;
    private Long patientId;
    private String patientName;
    private LocalDateTime triggeredAt;
    private LocalDateTime resolvedAt;
}