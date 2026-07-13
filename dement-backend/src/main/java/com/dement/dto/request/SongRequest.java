package com.dement.dto.request;

import com.dement.enums.MoodType;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class SongRequest {

    @NotBlank(message = "Song title is required")
    private String title;

    private String artist;
    private MoodType moodCategory;
    private Integer durationSeconds;
}