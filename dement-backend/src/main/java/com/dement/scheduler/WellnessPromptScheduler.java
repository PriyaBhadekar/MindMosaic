package com.dement.scheduler;

import com.dement.entity.Patient;
import com.dement.repository.PatientRepository;
import com.dement.service.VoiceService;
import com.dement.utils.VoicePromptBuilder;
import com.dement.websocket.AlertWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class WellnessPromptScheduler {

    private final PatientRepository patientRepository;
    private final VoicePromptBuilder voicePromptBuilder;
    private final AlertWebSocketHandler alertWebSocketHandler;

    // Every 4 hours: 8 AM, 12 PM, 4 PM, 8 PM
    @Scheduled(cron = "0 0 8,12,16,20 * * *")
    public void sendWellnessPrompts() {
        log.info("Sending wellness prompts to all patients...");
        List<Patient> patients = patientRepository.findAll();

        for (Patient patient : patients) {
            String prompt = voicePromptBuilder.getWellnessPrompt();
            String message = String.format(
                    "{\"type\":\"WELLNESS_PROMPT\",\"patientId\":%d,\"patientName\":\"%s\",\"promptText\":\"%s\"}",
                    patient.getId(),
                    patient.getName().replace("\"", "'"),
                    prompt.replace("\"", "'")
            );

            alertWebSocketHandler.sendAlertToCaregiver(patient.getCaregiver().getId(), message);
            log.info("Wellness prompt sent for patient: {}", patient.getName());
        }
    }
}