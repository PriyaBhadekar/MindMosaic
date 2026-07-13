package com.dement.controller;

import com.dement.dto.request.PatientProfileRequest;
import com.dement.dto.response.ApiResponse;
import com.dement.dto.response.PatientResponse;
import com.dement.security.UserPrincipal;
import com.dement.service.PatientService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import com.dement.dto.request.LinkPatientRequest;

import java.util.List;

@RestController
@RequestMapping("/api/patient")
@RequiredArgsConstructor
public class PatientController {

    private final PatientService patientService;

    @GetMapping("/caregiver/{caregiverId}")
    public ResponseEntity<ApiResponse<List<PatientResponse>>> getPatientsByCaregiver(
            @PathVariable Long caregiverId) {
        return ResponseEntity.ok(ApiResponse.success(
                patientService.getPatientsForCaregiver(caregiverId), "Patients fetched"));
    }

    // PatientController.java — add:
    @GetMapping("/{patientId}")
    public ResponseEntity<ApiResponse<PatientResponse>> getPatient(
            @PathVariable Long patientId) {
        return ResponseEntity.ok(ApiResponse.success(
                patientService.getPatientById(patientId),
                "Patient fetched"));
    }

    @PostMapping("/caregiver/{caregiverId}")
    public ResponseEntity<ApiResponse<PatientResponse>> createPatient(
            @PathVariable Long caregiverId,
            @Valid @RequestBody PatientProfileRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                patientService.createPatient(caregiverId, request), "Patient created"));
    }

    @PutMapping("/{patientId}")
    public ResponseEntity<ApiResponse<PatientResponse>> updatePatient(
            @PathVariable Long patientId,
            @Valid @RequestBody PatientProfileRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                patientService.updatePatient(patientId, request), "Patient updated"));
    }

    @PostMapping("/{patientId}/photo")
    public ResponseEntity<ApiResponse<PatientResponse>> uploadPhoto(
            @PathVariable Long patientId,
            @RequestParam("file") MultipartFile file) {
        return ResponseEntity.ok(ApiResponse.success(
                patientService.uploadPatientPhoto(patientId, file), "Photo uploaded"));
    }

    @PutMapping("/{patientId}/location")
    public ResponseEntity<ApiResponse<String>> updateLocation(
            @PathVariable Long patientId,
            @RequestParam Double latitude,
            @RequestParam Double longitude) {
        patientService.updatePatientLocation(patientId, latitude, longitude);
        return ResponseEntity.ok(ApiResponse.success("Location updated"));
    }

    @PostMapping("/link")
    public ResponseEntity<ApiResponse<String>> linkPatient(
            @RequestBody LinkPatientRequest request
    ) {

        patientService.linkPatientToCaregiver(
                request.getPatientCode(),
                request.getCaregiverCode()
        );

        return ResponseEntity.ok(
                ApiResponse.success("Patient linked successfully")
        );
    }

    @GetMapping("/link/{code}")
    public ResponseEntity<ApiResponse<PatientResponse>> getPatientByCode(
            @PathVariable String code
    ) {

        return ResponseEntity.ok(
                ApiResponse.success(
                        patientService.getPatientByLinkedCode(code),
                        "Patient fetched"
                )
        );
    }


}