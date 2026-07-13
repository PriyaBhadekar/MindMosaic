package com.dement.controller;

import com.dement.dto.response.ApiResponse;
import com.dement.dto.response.CaregiverResponse;
import com.dement.security.UserPrincipal;
import com.dement.service.CaregiverService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/caregiver")
@RequiredArgsConstructor
@PreAuthorize("hasRole('CAREGIVER')")
public class CaregiverController {

    private final CaregiverService caregiverService;

    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<CaregiverResponse>> getProfile(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(
                caregiverService.getProfile(principal.getId()), "Profile fetched"));
    }

    @PutMapping("/profile")
    public ResponseEntity<ApiResponse<CaregiverResponse>> updateProfile(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String phoneNumber) {
        return ResponseEntity.ok(ApiResponse.success(
                caregiverService.updateProfile(principal.getId(), name, phoneNumber), "Profile updated"));
    }

    @PostMapping("/profile/image")
    public ResponseEntity<ApiResponse<CaregiverResponse>> uploadProfileImage(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam("file") MultipartFile file) {
        return ResponseEntity.ok(ApiResponse.success(
                caregiverService.uploadProfileImage(principal.getId(), file), "Profile image uploaded"));
    }
}