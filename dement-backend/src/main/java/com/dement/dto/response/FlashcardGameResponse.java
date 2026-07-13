// CREATE src/main/java/com/dement/dto/response/FlashcardGameResponse.java
package com.dement.dto.response;

import lombok.*;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FlashcardGameResponse {
    private String gameType;
    private String difficulty;
    private int totalQuestions;
    private List<FlashcardQuestionResponse> questions;
}