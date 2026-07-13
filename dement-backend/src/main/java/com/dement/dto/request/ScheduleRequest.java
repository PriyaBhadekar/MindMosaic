package com.dement.dto.request;

import com.dement.enums.ReminderType;
import com.dement.enums.RepeatType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalTime;

@Data
public class ScheduleRequest {

    @NotBlank(message = "Title is required")
    private String title;

    @NotNull(message = "Scheduled time is required")
    private LocalTime scheduledTime;

    private String voiceDescription;
    private RepeatType repeatType = RepeatType.DAILY;
    private ReminderType reminderType = ReminderType.VOICE;
}