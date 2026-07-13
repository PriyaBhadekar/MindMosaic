package com.dement.controller;

import com.dement.dto.request.CaregiverRegisterRequest;
import com.dement.dto.request.LoginRequest;
import com.dement.dto.request.PatientLinkRequest;
import com.dement.dto.response.ApiResponse;
import com.dement.dto.response.AuthResponse;
import com.dement.dto.response.PatientResponse;
import com.dement.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/caregiver/register")
    public ResponseEntity<ApiResponse<AuthResponse>> registerCaregiver(
            @Valid @RequestBody CaregiverRegisterRequest request) {
        AuthResponse response = authService.registerCaregiver(request);
        return ResponseEntity.ok(ApiResponse.success(response, "Caregiver registered successfully"));
    }

    @PostMapping("/caregiver/login")
    public ResponseEntity<ApiResponse<AuthResponse>> loginCaregiver(
            @Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.loginCaregiver(request);
        return ResponseEntity.ok(ApiResponse.success(response, "Login successful"));
    }

    @PostMapping("/patient/link")
    public ResponseEntity<ApiResponse<PatientResponse>> linkPatient(
            @Valid @RequestBody PatientLinkRequest request) {
        PatientResponse response = authService.linkPatient(request);
        return ResponseEntity.ok(ApiResponse.success(response, "Patient linked to caregiver successfully"));
    }
}