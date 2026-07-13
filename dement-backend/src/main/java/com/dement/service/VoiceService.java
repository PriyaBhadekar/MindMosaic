// REPLACE src/main/java/com/dement/service/VoiceService.java
package com.dement.service;

import com.dement.dto.request.MoodRequest;
import com.dement.dto.request.SosAlertRequest;
import com.dement.dto.request.VoiceLogRequest;
import com.dement.dto.response.MoodLogResponse;
import com.dement.dto.response.SosAlertResponse;
import com.dement.dto.response.VoiceLogResponse;
import com.dement.dto.response.VoicePromptResponse;
import com.dement.entity.MoodLog;
import com.dement.entity.Patient;
import com.dement.entity.SosAlert;
import com.dement.entity.VoiceLog;
import com.dement.enums.MoodType;
import com.dement.exception.ResourceNotFoundException;
import com.dement.repository.MoodLogRepository;
import com.dement.repository.SosAlertRepository;
import com.dement.repository.VoiceLogRepository;
import com.dement.utils.VoicePromptBuilder;
import com.dement.websocket.AlertWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class VoiceService {

    private final VoiceLogRepository voiceLogRepository;
    private final MoodLogRepository moodLogRepository;
    private final SosAlertRepository sosAlertRepository;
    private final PatientService patientService;
    private final AlertWebSocketHandler alertWebSocketHandler;
    private final VoicePromptBuilder voicePromptBuilder;

    // ── Distress keywords ───────────────────────────────────────────────
    private static final List<String> DISTRESS_KEYWORDS = Arrays.asList(
            "pain", "hurt", "hurting", "help", "scared", "afraid",
            "emergency", "fall", "fell", "cannot breathe", "chest",
            "dizzy", "bleeding", "cannot move", "alone", "lost",
            "confused", "danger", "sos", "please help", "accident"
    );

    // ── Get wellness prompt ─────────────────────────────────────────────
    public VoicePromptResponse getWellnessPrompt(Long patientId) {
        Patient patient = patientService.findById(patientId);
        String prompt = voicePromptBuilder.getWellnessPrompt();
        log.info("Wellness prompt generated for patient: {}", patient.getName());
        return VoicePromptResponse.builder()
                .promptText(prompt)
                .promptType("WELLNESS")
                .requiresResponse(true)
                .build();
    }

    // ── Log voice response ──────────────────────────────────────────────
    @Transactional
    public VoiceLogResponse logVoiceResponse(VoiceLogRequest request) {
        Patient patient = patientService.findById(request.getPatientId());

        // Detect silent/no-response as SOS trigger
        boolean isSos = request.getPatientResponse() == null
                || request.getPatientResponse().trim().isEmpty();

        // Detect distress keywords in patient response
        boolean isDistress = false;
        String distressKeyword = null;
        if (!isSos && request.getPatientResponse() != null) {
            String lowerResponse = request.getPatientResponse().toLowerCase();
            for (String keyword : DISTRESS_KEYWORDS) {
                if (lowerResponse.contains(keyword)) {
                    isDistress = true;
                    distressKeyword = keyword;
                    break;
                }
            }
        }

        VoiceLog voiceLog = VoiceLog.builder()
                .promptText(request.getPromptText())
                .patientResponse(request.getPatientResponse())
                .responseType(request.getResponseType() != null
                        ? request.getResponseType() : "SPOKEN")
                .sosTriggered(isSos)
                .distressDetected(isDistress)
                .distressKeyword(distressKeyword)
                .patient(patient)
                .build();

        VoiceLog saved = voiceLogRepository.save(voiceLog);

        // Trigger SOS if no response
        if (isSos) {
            log.warn("SOS triggered — no response from patient: {}", patient.getName());
            triggerSosAlert(patient, "VOICE_NO_RESPONSE",
                    "Patient did not respond to voice prompt: " + request.getPromptText());
        }

        // Alert caregiver if distress detected
        if (isDistress) {
            log.warn("Distress keyword '{}' detected in response from patient: {}",
                    distressKeyword, patient.getName());
            alertWebSocketHandler.sendAlertToCaregiver(
                    patient.getCaregiver().getId(),
                    String.format(
                            "{\"type\":\"DISTRESS_DETECTED\",\"message\":\"Distress keyword detected in %s's response: '%s'\",\"patientId\":%d}",
                            patient.getName(), distressKeyword, patient.getId()
                    )
            );
        }

        return mapToVoiceLogResponse(saved, patient);
    }

    // ── Log mood & get suggestion ───────────────────────────────────────
    @Transactional
    public VoicePromptResponse logMoodAndGetSuggestion(MoodRequest request) {
        Patient patient = patientService.findById(request.getPatientId());
        String suggestion = voicePromptBuilder.getMoodBasedSuggestion(request.getMood());

        MoodLog moodLog = MoodLog.builder()
                .mood(request.getMood())
                .notes(request.getNotes())
                .suggestionGiven(suggestion)
                .patient(patient)
                .build();

        moodLogRepository.save(moodLog);
        log.info("Mood logged: {} for patient: {}", request.getMood(), patient.getName());

        // Alert caregiver for negative moods
        if (request.getMood() == MoodType.SAD
                || request.getMood() == MoodType.AGITATED
                || request.getMood() == MoodType.ANXIOUS) {
            alertWebSocketHandler.sendAlertToCaregiver(
                    patient.getCaregiver().getId(),
                    String.format(
                            "{\"type\":\"MOOD_ALERT\",\"message\":\"Patient %s is feeling %s. Please check on them.\",\"patientId\":%d,\"mood\":\"%s\"}",
                            patient.getName(),
                            request.getMood().name().toLowerCase(),
                            patient.getId(),
                            request.getMood().name()
                    )
            );
        }

        return VoicePromptResponse.builder()
                .promptText("Thank you for sharing how you feel.")
                .promptType("MOOD_RESPONSE")
                .suggestion(suggestion)
                .requiresResponse(false)
                .build();
    }

    // ── Manual SOS trigger (from patient device) ────────────────────────
    @Transactional
    public SosAlertResponse triggerManualSos(SosAlertRequest request) {
        Patient patient = patientService.findById(request.getPatientId());

        SosAlert alert = SosAlert.builder()
                .alertType(request.getAlertType() != null
                        ? request.getAlertType() : "MANUAL_SOS")
                .alertMessage(request.getAlertMessage() != null
                        ? request.getAlertMessage()
                        : "Patient pressed SOS button")
                .patientLatitude(request.getPatientLatitude())
                .patientLongitude(request.getPatientLongitude())
                .patient(patient)
                .build();

        SosAlert saved = sosAlertRepository.save(alert);
        log.warn("Manual SOS triggered by patient: {}", patient.getName());

        alertWebSocketHandler.sendAlertToCaregiver(
                patient.getCaregiver().getId(),
                String.format(
                        "{\"type\":\"MANUAL_SOS\",\"message\":\"URGENT: %s pressed the SOS button!\",\"patientId\":%d}",
                        patient.getName(), patient.getId()
                )
        );

        return mapToSosResponse(saved, patient);
    }

    // ── Internal SOS trigger ────────────────────────────────────────────
    @Transactional
    public void triggerSosAlert(Patient patient, String alertType, String message) {
        SosAlert alert = SosAlert.builder()
                .alertType(alertType)
                .alertMessage(message)
                .patient(patient)
                .patientLatitude(patient.getLastKnownLatitude())
                .patientLongitude(patient.getLastKnownLongitude())
                .build();

        sosAlertRepository.save(alert);

        alertWebSocketHandler.sendAlertToCaregiver(
                patient.getCaregiver().getId(),
                String.format(
                        "{\"type\":\"SOS_ALERT\",\"message\":\"SOS: %s — %s\",\"patientId\":%d}",
                        patient.getName(), message, patient.getId()
                )
        );
    }

    // ── Fetch all voice logs for patient ────────────────────────────────
    public List<VoiceLogResponse> getVoiceLogs(Long patientId) {
        Patient patient = patientService.findById(patientId);
        return voiceLogRepository
                .findByPatientIdOrderByLoggedAtDesc(patientId)
                .stream()
                .map(v -> mapToVoiceLogResponse(v, patient))
                .collect(Collectors.toList());
    }

    // ── Fetch distress logs for caregiver ───────────────────────────────
    public List<VoiceLogResponse> getDistressLogs(Long caregiverId) {
        return voiceLogRepository
                .findDistressLogsByCaregiverId(caregiverId)
                .stream()
                .map(v -> mapToVoiceLogResponse(v, v.getPatient()))
                .collect(Collectors.toList());
    }

    // ── Fetch SOS voice logs for caregiver ──────────────────────────────
    public List<VoiceLogResponse> getSosVoiceLogs(Long caregiverId) {
        return voiceLogRepository
                .findSosLogsByCaregiverId(caregiverId)
                .stream()
                .map(v -> mapToVoiceLogResponse(v, v.getPatient()))
                .collect(Collectors.toList());
    }

    // ── Fetch mood logs for patient ─────────────────────────────────────
    public List<MoodLogResponse> getMoodLogs(Long patientId) {
        Patient patient = patientService.findById(patientId);
        return moodLogRepository
                .findByPatientIdOrderByLoggedAtDesc(patientId)
                .stream()
                .map(m -> mapToMoodLogResponse(m, patient))
                .collect(Collectors.toList());
    }

    // ── Mood distribution stats ─────────────────────────────────────────
    public Map<String, Long> getMoodStats(Long patientId) {
        List<Object[]> raw = moodLogRepository.getMoodDistributionByPatientId(patientId);
        return raw.stream().collect(Collectors.toMap(
                row -> row[0].toString(),
                row -> (Long) row[1]
        ));
    }

    // ── Delete voice log ────────────────────────────────────────────────
    @Transactional
    public void deleteVoiceLog(Long logId) {
        VoiceLog log = voiceLogRepository.findById(logId)
                .orElseThrow(() -> new ResourceNotFoundException("VoiceLog", "id", logId));
        voiceLogRepository.delete(log);
    }

    // ── Get SOS alerts for caregiver ────────────────────────────────────
    public List<SosAlertResponse> getSosAlerts(Long caregiverId) {
        return sosAlertRepository
                .findByPatient_CaregiverIdOrderByTriggeredAtDesc(caregiverId)
                .stream()
                .map(s -> mapToSosResponse(s, s.getPatient()))
                .collect(Collectors.toList());
    }

    // ── Resolve SOS alert ───────────────────────────────────────────────
    @Transactional
    public SosAlertResponse resolveSosAlert(Long alertId) {
        SosAlert alert = sosAlertRepository.findById(alertId)
                .orElseThrow(() -> new ResourceNotFoundException("SosAlert", "id", alertId));
        alert.setResolved(true);
        alert.setResolvedAt(LocalDateTime.now());
        return mapToSosResponse(sosAlertRepository.save(alert), alert.getPatient());
    }

    // ── Mappers ─────────────────────────────────────────────────────────
    private VoiceLogResponse mapToVoiceLogResponse(VoiceLog v, Patient patient) {
        return VoiceLogResponse.builder()
                .id(v.getId())
                .promptText(v.getPromptText())
                .patientResponse(v.getPatientResponse())
                .responseType(v.getResponseType())
                .sosTriggered(v.isSosTriggered())
                .distressDetected(v.isDistressDetected())
                .distressKeyword(v.getDistressKeyword())
                .patientId(patient.getId())
                .patientName(patient.getName())
                .loggedAt(v.getLoggedAt())
                .build();
    }

    private MoodLogResponse mapToMoodLogResponse(MoodLog m, Patient patient) {
        return MoodLogResponse.builder()
                .id(m.getId())
                .mood(m.getMood())
                .notes(m.getNotes())
                .suggestionGiven(m.getSuggestionGiven())
                .patientId(patient.getId())
                .patientName(patient.getName())
                .loggedAt(m.getLoggedAt())
                .build();
    }

    private SosAlertResponse mapToSosResponse(SosAlert s, Patient patient) {
        return SosAlertResponse.builder()
                .id(s.getId())
                .alertType(s.getAlertType())
                .alertMessage(s.getAlertMessage())
                .resolved(s.isResolved())
                .patientLatitude(s.getPatientLatitude())
                .patientLongitude(s.getPatientLongitude())
                .patientId(patient.getId())
                .patientName(patient.getName())
                .triggeredAt(s.getTriggeredAt())
                .resolvedAt(s.getResolvedAt())
                .build();
    }
}