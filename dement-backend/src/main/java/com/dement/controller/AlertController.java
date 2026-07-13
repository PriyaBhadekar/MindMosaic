package com.dement.controller;

import com.dement.dto.response.ApiResponse;
import com.dement.entity.SosAlert;
import com.dement.security.UserPrincipal;
import com.dement.service.AlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/alerts")
@RequiredArgsConstructor
public class AlertController {

    private final AlertService alertService;

    @GetMapping("/unresolved")
    public ResponseEntity<ApiResponse<List<SosAlert>>> getUnresolved(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(
                alertService.getUnresolvedAlerts(principal.getId()), "Unresolved alerts fetched"));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<SosAlert>>> getAllAlerts(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(
                alertService.getAllAlerts(principal.getId()), "All alerts fetched"));
    }

    @PatchMapping("/{alertId}/resolve")
    public ResponseEntity<ApiResponse<SosAlert>> resolveAlert(@PathVariable Long alertId) {
        return ResponseEntity.ok(ApiResponse.success(
                alertService.resolveAlert(alertId), "Alert resolved"));
    }
}