package com.dement.scheduler;

import com.dement.entity.Schedule;
import com.dement.repository.PatientRepository;
import com.dement.repository.ScheduleRepository;
import com.dement.websocket.AlertWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalTime;
import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class ScheduleReminderJob {

    private final ScheduleRepository scheduleRepository;
    private final PatientRepository patientRepository;
    private final AlertWebSocketHandler alertWebSocketHandler;

    @Scheduled(fixedRate = 60000) // Every minute
    public void checkAndTriggerSchedules() {
        LocalTime now = LocalTime.now();
        LocalTime windowStart = now.minusSeconds(30);
        LocalTime windowEnd = now.plusSeconds(30);

        List<Schedule> dueSchedules = scheduleRepository
                .findByActiveTrueAndScheduledTimeBetween(windowStart, windowEnd);

        for (Schedule schedule : dueSchedules) {
            triggerScheduleReminder(schedule);
        }
    }

    private void triggerScheduleReminder(Schedule schedule) {
        Long caregiverId = schedule.getCaregiver().getId();
        List<com.dement.entity.Patient> patients = patientRepository.findByCaregiverId(caregiverId);

        String voiceDescription = schedule.getVoiceDescription() != null
                ? schedule.getVoiceDescription()
                : schedule.getTitle();

        String message = String.format(
                "{\"type\":\"SCHEDULE_REMINDER\",\"title\":\"%s\",\"voiceText\":\"%s\",\"reminderType\":\"%s\"}",
                schedule.getTitle().replace("\"", "'"),
                voiceDescription.replace("\"", "'"),
                schedule.getReminderType()
        );

        for (com.dement.entity.Patient patient : patients) {
            alertWebSocketHandler.sendAlertToCaregiver(caregiverId, message);
        }

        schedule.setLastTriggered(java.time.LocalDateTime.now());
        scheduleRepository.save(schedule);
        log.info("Schedule reminder triggered: {} for caregiver {}", schedule.getTitle(), caregiverId);
    }
}