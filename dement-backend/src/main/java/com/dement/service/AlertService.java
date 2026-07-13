package com.dement.service;

import com.dement.entity.SosAlert;
import com.dement.repository.SosAlertRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class AlertService {

    private final SosAlertRepository sosAlertRepository;

    public List<SosAlert> getUnresolvedAlerts(Long caregiverId) {
        return sosAlertRepository.findByPatient_CaregiverIdAndResolvedFalse(caregiverId);
    }

    public List<SosAlert> getAllAlerts(Long caregiverId) {
        return sosAlertRepository.findByPatient_CaregiverId(caregiverId);
    }

    @Transactional
    public SosAlert resolveAlert(Long alertId) {
        SosAlert alert = sosAlertRepository.findById(alertId)
                .orElseThrow(() -> new RuntimeException("Alert not found"));
        alert.setResolved(true);
        alert.setResolvedAt(LocalDateTime.now());
        return sosAlertRepository.save(alert);
    }
}