// REPLACE src/main/java/com/dement/controller/VoiceController.java
package com.dement.controller;

import com.dement.dto.request.AiChatRequest;
import com.dement.dto.request.MoodRequest;
import com.dement.dto.request.SosAlertRequest;
import com.dement.dto.request.VoiceLogRequest;
import com.dement.dto.response.*;
import com.dement.security.UserPrincipal;
import com.dement.service.VoiceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import com.dement.dto.request.AiChatRequest;
import com.dement.dto.response.AiChatResponse;
import com.dement.service.VoiceAiService;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/voice")
@RequiredArgsConstructor
public class VoiceController {

    private final VoiceService voiceService;
    private final VoiceAiService voiceAiService;
    // ── GET /api/voice/prompt/{patientId}
    // Returns a wellness prompt for the patient
    // Response: { promptText, promptType, requiresResponse }
    @GetMapping("/prompt/{patientId}")
    public ResponseEntity<ApiResponse<VoicePromptResponse>> getWellnessPrompt(
            @PathVariable Long patientId) {
        return ResponseEntity.ok(ApiResponse.success(
                voiceService.getWellnessPrompt(patientId),
                "Prompt generated"));
    }

    // ── POST /api/voice/log
    // Saves a voice interaction; triggers SOS/distress detection automatically
    // Request: { patientId, promptText, patientResponse, responseType }
    // Response: VoiceLogResponse with sosTriggered, distressDetected fields
    @PostMapping("/log")
    public ResponseEntity<ApiResponse<VoiceLogResponse>> logVoiceResponse(
            @RequestBody VoiceLogRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                voiceService.logVoiceResponse(request),
                "Voice log saved"));
    }

    // ── POST /api/voice/mood
    // Logs mood; triggers caregiver alert for negative moods
    // Request: { patientId, mood, notes }
    // Response: { promptText, promptType, suggestion }
    @PostMapping("/mood")
    public ResponseEntity<ApiResponse<VoicePromptResponse>> logMood(
            @Valid @RequestBody MoodRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                voiceService.logMoodAndGetSuggestion(request),
                "Mood logged"));
    }

    // ── POST /api/voice/sos
    // Patient manually triggers SOS alert
    // Request: { patientId, alertType, alertMessage, patientLatitude, patientLongitude }
    // Response: SosAlertResponse
    @PostMapping("/sos")
    public ResponseEntity<ApiResponse<SosAlertResponse>> triggerSos(
            @Valid @RequestBody SosAlertRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                voiceService.triggerManualSos(request),
                "SOS alert triggered"));
    }

    // ── GET /api/voice/logs/{patientId}
    // Returns all voice logs for a patient (newest first)
    @GetMapping("/logs/{patientId}")
    public ResponseEntity<ApiResponse<List<VoiceLogResponse>>> getVoiceLogs(
            @PathVariable Long patientId) {
        return ResponseEntity.ok(ApiResponse.success(
                voiceService.getVoiceLogs(patientId),
                "Voice logs fetched"));
    }

    // ── GET /api/voice/distress
    // Returns all distress-detected logs for caregiver's patients
    @GetMapping("/distress")
    public ResponseEntity<ApiResponse<List<VoiceLogResponse>>> getDistressLogs(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(
                voiceService.getDistressLogs(principal.getId()),
                "Distress logs fetched"));
    }

    // ── GET /api/voice/sos-logs
    // Returns all SOS-triggered voice logs for caregiver's patients
    @GetMapping("/sos-logs")
    public ResponseEntity<ApiResponse<List<VoiceLogResponse>>> getSosVoiceLogs(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(
                voiceService.getSosVoiceLogs(principal.getId()),
                "SOS voice logs fetched"));
    }

    // ── GET /api/voice/mood-logs/{patientId}
    // Returns all mood logs for a patient
    @GetMapping("/mood-logs/{patientId}")
    public ResponseEntity<ApiResponse<List<MoodLogResponse>>> getMoodLogs(
            @PathVariable Long patientId) {
        return ResponseEntity.ok(ApiResponse.success(
                voiceService.getMoodLogs(patientId),
                "Mood logs fetched"));
    }

    // ── GET /api/voice/mood-stats/{patientId}
    // Returns mood distribution count map: { HAPPY: 5, SAD: 2, ... }
    @GetMapping("/mood-stats/{patientId}")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getMoodStats(
            @PathVariable Long patientId) {
        return ResponseEntity.ok(ApiResponse.success(
                voiceService.getMoodStats(patientId),
                "Mood stats fetched"));
    }

    // ── DELETE /api/voice/log/{logId}
    // Deletes a single voice log entry
    @DeleteMapping("/log/{logId}")
    public ResponseEntity<ApiResponse<String>> deleteVoiceLog(
            @PathVariable Long logId) {
        voiceService.deleteVoiceLog(logId);
        return ResponseEntity.ok(ApiResponse.success("Voice log deleted"));
    }

    // ── GET /api/voice/sos-alerts
    // Returns all SOS alerts for caregiver (sorted newest first)
    @GetMapping("/sos-alerts")
    public ResponseEntity<ApiResponse<List<SosAlertResponse>>> getSosAlerts(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(
                voiceService.getSosAlerts(principal.getId()),
                "SOS alerts fetched"));
    }

    // ── PATCH /api/voice/sos-alerts/{alertId}/resolve
    // Marks a SOS alert as resolved
    @PatchMapping("/sos-alerts/{alertId}/resolve")
    public ResponseEntity<ApiResponse<SosAlertResponse>> resolveSosAlert(
            @PathVariable Long alertId) {
        return ResponseEntity.ok(ApiResponse.success(
                voiceService.resolveSosAlert(alertId),
                "Alert resolved"));
    }

    @PostMapping("/ai-chat")
    public ResponseEntity<ApiResponse<AiChatResponse>> aiChat(
            @RequestBody AiChatRequest request
    ) {

        return ResponseEntity.ok(
                ApiResponse.success(
                        voiceAiService.chat(request),
                        "AI response generated"
                )
        );
    }
}