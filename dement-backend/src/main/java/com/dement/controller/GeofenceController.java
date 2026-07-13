package com.dement.controller;

import com.dement.dto.request.GeofenceAlertRequest;
import com.dement.dto.request.GeofenceRequest;
import com.dement.dto.response.ApiResponse;
import com.dement.dto.response.GeofenceAlertResponse;
import com.dement.dto.response.GeofenceResponse;
import com.dement.entity.GeofenceAlert;
import com.dement.security.UserPrincipal;
import com.dement.service.GeofenceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/geofence")
@RequiredArgsConstructor
public class GeofenceController {

    private final GeofenceService geofenceService;

    @GetMapping
    public ResponseEntity<ApiResponse<GeofenceResponse>> getGeofence(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(
                geofenceService.getGeofence(principal.getId()), "Geofence fetched"));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<GeofenceResponse>> setGeofence(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody GeofenceRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                geofenceService.setGeofence(principal.getId(), request), "Geofence set"));
    }

    @PostMapping("/check-location")
    public ResponseEntity<ApiResponse<Boolean>> checkPatientLocation(
            @Valid @RequestBody GeofenceAlertRequest request) {
        boolean isOutside = geofenceService.checkPatientLocation(request);
        String message = isOutside ? "Patient is OUTSIDE safe zone! Alert triggered." : "Patient is within safe zone.";
        return ResponseEntity.ok(ApiResponse.success(isOutside, message));
    }

    @GetMapping("/alerts")
    public ResponseEntity<ApiResponse<List<GeofenceAlertResponse>>> getAlerts(
            @AuthenticationPrincipal UserPrincipal principal) {

        System.out.println("========== GEOFENCE ALERTS ==========");
        System.out.println("CAREGIVER ID = " + principal.getId());

        return ResponseEntity.ok(
                ApiResponse.success(
                        geofenceService.getAlertsForCaregiver(principal.getId()),
                        "Alerts fetched"
                )
        );
    }
}