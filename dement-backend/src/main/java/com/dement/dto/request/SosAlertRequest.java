// CREATE src/main/java/com/dement/dto/request/SosAlertRequest.java
package com.dement.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class SosAlertRequest {

    @NotNull(message = "Patient ID is required")
    private Long patientId;

    private String alertType;   // VOICE_NO_RESPONSE, MANUAL_SOS, DISTRESS_DETECTED
    private String alertMessage;
    private Double patientLatitude;
    private Double patientLongitude;
}