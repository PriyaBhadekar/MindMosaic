// CREATE src/main/java/com/dement/dto/response/FlashcardQuestionResponse.java
package com.dement.dto.response;

import lombok.*;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FlashcardQuestionResponse {
    private Long memoryId;
    private String imagePath;
    private String imageUrl;     // fully resolved URL for frontend
    private String question;
    private String description;
    private List<String> options;
    private String correctAnswer;
    private String category;
    private String relationInfo;
}