package com.dement.dto.response;

import com.dement.enums.ReminderType;
import com.dement.enums.RepeatType;
import lombok.*;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ScheduleResponse {
    private Long id;
    private String title;
    private LocalTime scheduledTime;
    private String voiceDescription;
    private RepeatType repeatType;
    private ReminderType reminderType;
    private boolean active;
    private LocalDateTime lastTriggered;
    private LocalDateTime createdAt;
}