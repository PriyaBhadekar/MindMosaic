package com.dement.service;

import com.dement.dto.request.GeofenceAlertRequest;
import com.dement.dto.request.GeofenceRequest;
import com.dement.dto.response.GeofenceAlertResponse;
import com.dement.dto.response.GeofenceResponse;
import com.dement.entity.Caregiver;
import com.dement.entity.Geofence;
import com.dement.entity.GeofenceAlert;
import com.dement.entity.Patient;
import com.dement.exception.ResourceNotFoundException;
import com.dement.repository.GeofenceAlertRepository;
import com.dement.repository.GeofenceRepository;
import com.dement.utils.GeofenceUtils;
import com.dement.websocket.AlertWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class GeofenceService {

    private final GeofenceRepository geofenceRepository;
    private final GeofenceAlertRepository geofenceAlertRepository;
    private final CaregiverService caregiverService;
    private final PatientService patientService;
    private final GeofenceUtils geofenceUtils;
    private final AlertWebSocketHandler alertWebSocketHandler;

    public GeofenceResponse getGeofence(Long caregiverId) {
        Geofence geofence = geofenceRepository.findByCaregiverId(caregiverId)
                .orElseThrow(() -> new ResourceNotFoundException("Geofence not set for this caregiver"));
        return mapToResponse(geofence);
    }

    @Transactional
    public GeofenceResponse setGeofence(Long caregiverId, GeofenceRequest request) {
        Caregiver caregiver = caregiverService.findById(caregiverId);

        Geofence geofence = geofenceRepository.findByCaregiverId(caregiverId)
                .orElse(Geofence.builder().caregiver(caregiver).build());

        geofence.setLatitude(request.getLatitude());
        geofence.setLongitude(request.getLongitude());
        geofence.setRadius(request.getRadius());
        geofence.setAddress(request.getAddress());
        geofence.setActive(true);

        return mapToResponse(geofenceRepository.save(geofence));
    }

    @Transactional
    public boolean checkPatientLocation(GeofenceAlertRequest request) {
        Patient patient = patientService.findById(request.getPatientId());
        patientService.updatePatientLocation(request.getPatientId(),
                request.getCurrentLatitude(), request.getCurrentLongitude());

        Geofence geofence = geofenceRepository.findByCaregiverId(patient.getCaregiver().getId())
                .orElse(null);

        if (geofence == null || !geofence.isActive()) {
            return false;
        }

        boolean isOutside = geofenceUtils.isOutsideZone(
                geofence.getLatitude(), geofence.getLongitude(), geofence.getRadius(),
                request.getCurrentLatitude(), request.getCurrentLongitude()
        );

        if (isOutside) {

            double distance =
                    geofenceUtils.calculateDistance(
                            geofence.getLatitude(),
                            geofence.getLongitude(),
                            request.getCurrentLatitude(),
                            request.getCurrentLongitude()
                    );

            GeofenceAlert existingAlert =
                    geofenceAlertRepository
                            .findFirstByPatientIdAndResolvedFalse(patient.getId())
                            .orElse(null);

            // FIRST TIME OUTSIDE
            if (existingAlert == null) {

                GeofenceAlert alert = GeofenceAlert.builder()
                        .patient(patient)
                        .patientLatitude(request.getCurrentLatitude())
                        .patientLongitude(request.getCurrentLongitude())
                        .distanceFromZone(distance)
                        .active(true)
                        .resolved(false)
                        .lastLocationUpdate(LocalDateTime.now())
                        .build();

                geofenceAlertRepository.save(alert);

                alertWebSocketHandler.sendAlertToCaregiver(
                        patient.getCaregiver().getId(),
                        "SAFE ZONE BREACH: " + patient.getName()
                );

                System.out.println("NEW GEOFENCE ALERT CREATED");
            }

            // ALREADY OUTSIDE
            else {

                if (existingAlert.getLastLocationUpdate() == null ||
                        existingAlert.getLastLocationUpdate()
                                .isBefore(LocalDateTime.now().minusMinutes(2))) {

                    existingAlert.setPatientLatitude(
                            request.getCurrentLatitude());

                    existingAlert.setPatientLongitude(
                            request.getCurrentLongitude());

                    existingAlert.setDistanceFromZone(distance);

                    existingAlert.setLastLocationUpdate(
                            LocalDateTime.now());

                    geofenceAlertRepository.save(existingAlert);

                    alertWebSocketHandler.sendAlertToCaregiver(
                            patient.getCaregiver().getId(),
                            "LOCATION UPDATE: " + patient.getName()
                    );

                    System.out.println("LOCATION UPDATE SENT");
                }
            }

            return true;
        }

        System.out.println("PATIENT ID = " + patient.getId());

        System.out.println(
                "UNRESOLVED ALERTS = " +
                        geofenceAlertRepository
                                .findByPatientIdAndResolvedFalse(patient.getId())
                                .size()
        );

        GeofenceAlert existingAlert =
                geofenceAlertRepository
                        .findFirstByPatientIdAndResolvedFalse(patient.getId())
                        .orElse(null);

        System.out.println(
                "EXISTING ALERT = " +
                        (existingAlert == null ? "NULL" : existingAlert.getId())
        );

        if (existingAlert != null) {

            existingAlert.setResolved(true);

            existingAlert.setActive(false);

            existingAlert.setResolvedAt(
                    LocalDateTime.now());

            geofenceAlertRepository.save(existingAlert);

            alertWebSocketHandler.sendAlertToCaregiver(
                    patient.getCaregiver().getId(),
                    "SAFE ZONE RESTORED: " + patient.getName()
            );

            System.out.println("PATIENT RETURNED TO SAFE ZONE");
        }

        return false;
    }

    public List<GeofenceAlertResponse> getAlertsForCaregiver(Long caregiverId) {

        return geofenceAlertRepository
                .findByPatient_CaregiverId(caregiverId)
                .stream()
                .map(alert -> GeofenceAlertResponse.builder()
                        .id(alert.getId())
                        .patientId(alert.getPatient().getId())
                        .patientName(alert.getPatient().getName())
                        .distanceFromZone(alert.getDistanceFromZone())
                        .patientLatitude(alert.getPatientLatitude())
                        .patientLongitude(alert.getPatientLongitude())
                        .triggeredAt(alert.getTriggeredAt())
                        .resolved(alert.isResolved())
                        .lastLocationUpdate(
                                alert.getLastLocationUpdate()
                        )
                        .build())
                .toList();
    }

    private GeofenceResponse mapToResponse(Geofence g) {
        return GeofenceResponse.builder()
                .id(g.getId())
                .latitude(g.getLatitude())
                .longitude(g.getLongitude())
                .radius(g.getRadius())
                .address(g.getAddress())
                .active(g.isActive())
                .build();
    }
}