package com.dement.controller;

import com.dement.dto.response.ApiResponse;
import com.dement.dto.response.MriResultResponse;
import com.dement.security.UserPrincipal;
import com.dement.service.MriService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/mri")
@RequiredArgsConstructor
public class MriController {

    private final MriService mriService;

    @PostMapping("/analyze")
    public ResponseEntity<ApiResponse<MriResultResponse>> analyzeMri(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam(value = "patientId", required = false) Long patientId,
            @RequestParam("file") MultipartFile file) {
        return ResponseEntity.ok(ApiResponse.success(
                mriService.analyzeMriScan(principal.getId(), patientId, file),
                "MRI analysis completed"));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<MriResultResponse>>> getMriScans(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(
                mriService.getScansForCaregiver(principal.getId()), "MRI scans fetched"));
    }

    @GetMapping("/{scanId}")
    public ResponseEntity<ApiResponse<MriResultResponse>> getScan(@PathVariable Long scanId) {
        return ResponseEntity.ok(ApiResponse.success(
                mriService.getScanById(scanId), "Scan fetched"));
    }
}