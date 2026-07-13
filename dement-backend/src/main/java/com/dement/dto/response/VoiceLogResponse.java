// CREATE src/main/java/com/dement/dto/response/VoiceLogResponse.java
package com.dement.dto.response;

import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VoiceLogResponse {
    private Long id;
    private String promptText;
    private String patientResponse;
    private String responseType;
    private boolean sosTriggered;
    private boolean distressDetected;
    private String distressKeyword;
    private Long patientId;
    private String patientName;
    private LocalDateTime loggedAt;
}