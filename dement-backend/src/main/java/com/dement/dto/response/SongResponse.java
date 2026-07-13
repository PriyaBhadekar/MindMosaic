package com.dement.dto.response;

import com.dement.enums.MoodType;
import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class SongResponse {
    private Long id;
    private String title;
    private String artist;
    private String audioPath;
    private MoodType moodCategory;
    private Integer durationSeconds;
    private LocalDateTime createdAt;
}