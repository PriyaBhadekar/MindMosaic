package com.dement.repository;

import com.dement.entity.GeofenceAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GeofenceAlertRepository extends JpaRepository<GeofenceAlert, Long> {
    List<GeofenceAlert> findByPatientId(Long patientId);

    List<GeofenceAlert> findByPatientIdAndResolvedFalse(Long patientId);

    List<GeofenceAlert> findByPatient_CaregiverId(Long caregiverId);

    Optional<GeofenceAlert> findFirstByPatientIdAndResolvedFalse(Long patientId);

}