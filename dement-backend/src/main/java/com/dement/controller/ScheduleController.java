package com.dement.controller;

import com.dement.dto.request.ScheduleRequest;
import com.dement.dto.response.ApiResponse;
import com.dement.dto.response.ScheduleResponse;
import com.dement.security.UserPrincipal;
import com.dement.service.ScheduleService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/schedules")
@RequiredArgsConstructor
public class ScheduleController {

    private final ScheduleService scheduleService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ScheduleResponse>>> getSchedules(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(
                scheduleService.getSchedules(principal.getId()), "Schedules fetched"));
    }

    @GetMapping("/active")
    public ResponseEntity<ApiResponse<List<ScheduleResponse>>> getActiveSchedules(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(
                scheduleService.getActiveSchedules(principal.getId()), "Active schedules fetched"));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ScheduleResponse>> createSchedule(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody ScheduleRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                scheduleService.createSchedule(principal.getId(), request), "Schedule created"));
    }

    @PutMapping("/{scheduleId}")
    public ResponseEntity<ApiResponse<ScheduleResponse>> updateSchedule(
            @PathVariable Long scheduleId,
            @Valid @RequestBody ScheduleRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                scheduleService.updateSchedule(scheduleId, request), "Schedule updated"));
    }

    @PatchMapping("/{scheduleId}/toggle")
    public ResponseEntity<ApiResponse<String>> toggleSchedule(@PathVariable Long scheduleId) {
        scheduleService.toggleSchedule(scheduleId);
        return ResponseEntity.ok(ApiResponse.success("Schedule toggled"));
    }

    @DeleteMapping("/{scheduleId}")
    public ResponseEntity<ApiResponse<String>> deleteSchedule(@PathVariable Long scheduleId) {
        scheduleService.deleteSchedule(scheduleId);
        return ResponseEntity.ok(ApiResponse.success("Schedule deleted"));
    }

    // ADD to ScheduleController.java
    @GetMapping("/patient/{patientId}")
    public ResponseEntity<ApiResponse<List<ScheduleResponse>>> getSchedulesForPatient(
            @PathVariable Long patientId) {
        return ResponseEntity.ok(ApiResponse.success(
                scheduleService.getSchedulesForPatient(patientId),
                "Schedules fetched"));
    }
}