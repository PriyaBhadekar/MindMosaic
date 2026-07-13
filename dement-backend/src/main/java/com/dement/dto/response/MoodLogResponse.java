// CREATE src/main/java/com/dement/dto/response/MoodLogResponse.java
package com.dement.dto.response;

import com.dement.enums.MoodType;
import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MoodLogResponse {
    private Long id;
    private MoodType mood;
    private String notes;
    private String suggestionGiven;
    private Long patientId;
    private String patientName;
    private LocalDateTime loggedAt;
}