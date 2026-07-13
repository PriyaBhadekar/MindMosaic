package com.dement.service;

import com.dement.dto.request.AiChatRequest;
import com.dement.dto.response.AiChatResponse;
import com.dement.entity.Memory;
import com.dement.entity.Patient;
import com.dement.entity.Schedule;
import com.dement.repository.MemoryRepository;
import com.dement.repository.ScheduleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class VoiceAiService {

    private final PatientService patientService;
    private final MemoryRepository memoryRepository;
    private final ScheduleRepository scheduleRepository;

    private final GeminiService geminiService;
    private final VoicePromptContextBuilder promptBuilder;

    public AiChatResponse chat(
            AiChatRequest request
    ) {

        Patient patient =
                patientService.findById(
                        request.getPatientId()
                );

        Long caregiverId =
                patient.getCaregiver().getId();

        List<Memory> memories =
                memoryRepository.findByCaregiverId(
                        caregiverId
                );

        List<Schedule> schedules =
                scheduleRepository
                        .findByCaregiverIdAndActiveTrue(
                                caregiverId
                        );

        System.out.println("========== AI CHAT REQUEST ==========");
        System.out.println("PATIENT MESSAGE = " + request.getMessage());

        String prompt =
                promptBuilder.buildContext(
                        patient,
                        memories,
                        schedules,
                        request.getMessage()
                );

        System.out.println("========== FULL PROMPT ==========");
        System.out.println(prompt);

        return geminiService.analyze(prompt);
    }
}