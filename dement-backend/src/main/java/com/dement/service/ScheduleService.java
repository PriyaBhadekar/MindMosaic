package com.dement.service;

import com.dement.dto.request.ScheduleRequest;
import com.dement.dto.response.ScheduleResponse;
import com.dement.entity.Caregiver;
import com.dement.entity.Patient;
import com.dement.entity.Schedule;
import com.dement.exception.ResourceNotFoundException;
import com.dement.repository.PatientRepository;
import com.dement.repository.ScheduleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScheduleService {

    private final ScheduleRepository scheduleRepository;
    private final CaregiverService caregiverService;
    private final PatientRepository patientRepository;

    public List<ScheduleResponse> getSchedules(Long caregiverId) {
        return scheduleRepository.findByCaregiverId(caregiverId)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    public List<ScheduleResponse> getActiveSchedules(Long caregiverId) {
        return scheduleRepository.findByCaregiverIdAndActiveTrue(caregiverId)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Transactional
    public ScheduleResponse createSchedule(Long caregiverId, ScheduleRequest request) {
        Caregiver caregiver = caregiverService.findById(caregiverId);

        Schedule schedule = Schedule.builder()
                .title(request.getTitle())
                .scheduledTime(request.getScheduledTime())
                .voiceDescription(request.getVoiceDescription())
                .repeatType(request.getRepeatType())
                .reminderType(request.getReminderType())
                .caregiver(caregiver)
                .build();

        return mapToResponse(scheduleRepository.save(schedule));
    }

    @Transactional
    public ScheduleResponse updateSchedule(Long scheduleId, ScheduleRequest request) {
        Schedule schedule = findById(scheduleId);
        if (request.getTitle() != null) schedule.setTitle(request.getTitle());
        if (request.getScheduledTime() != null) schedule.setScheduledTime(request.getScheduledTime());
        if (request.getVoiceDescription() != null) schedule.setVoiceDescription(request.getVoiceDescription());
        if (request.getRepeatType() != null) schedule.setRepeatType(request.getRepeatType());
        if (request.getReminderType() != null) schedule.setReminderType(request.getReminderType());
        return mapToResponse(scheduleRepository.save(schedule));
    }

    @Transactional
    public void toggleSchedule(Long scheduleId) {

        Schedule schedule = scheduleRepository
                .findById(scheduleId)
                .orElseThrow(() ->
                        new RuntimeException("Schedule not found"));

        schedule.setActive(!schedule.isActive());

        scheduleRepository.save(schedule);
    }

    @Transactional
    public void deleteSchedule(Long scheduleId) {
        scheduleRepository.delete(findById(scheduleId));
    }

    public Schedule findById(Long id) {
        return scheduleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Schedule", "id", id));
    }

    private ScheduleResponse mapToResponse(Schedule schedule) {
        return ScheduleResponse.builder()
                .id(schedule.getId())
                .title(schedule.getTitle())
                .scheduledTime(schedule.getScheduledTime())
                .voiceDescription(schedule.getVoiceDescription())
                .repeatType(schedule.getRepeatType())
                .reminderType(schedule.getReminderType())
                .active(schedule.isActive())
                .lastTriggered(schedule.getLastTriggered())
                .createdAt(schedule.getCreatedAt())
                .build();
    }

    // ADD to ScheduleService.java
    public List<ScheduleResponse> getSchedulesForPatient(Long patientId) {
        Patient patient = patientRepository.findById(patientId)
                .orElseThrow(() -> new ResourceNotFoundException("Patient", "id", patientId));
        return scheduleRepository
                .findByCaregiverIdOrderByScheduledTimeAsc(patient.getCaregiver().getId())
                .stream()
                .filter(Schedule::isActive)
                .map(this::mapToResponse)
                .collect(java.util.stream.Collectors.toList());
    }
}