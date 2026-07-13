// REPLACE src/main/java/com/dement/repository/SosAlertRepository.java
package com.dement.repository;

import com.dement.entity.SosAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SosAlertRepository extends JpaRepository<SosAlert, Long> {

    List<SosAlert> findByPatientIdOrderByTriggeredAtDesc(Long patientId);

    List<SosAlert> findByPatient_CaregiverIdAndResolvedFalseOrderByTriggeredAtDesc(Long caregiverId);
    List<SosAlert> findByPatient_CaregiverId(Long caregiverId);
    List<SosAlert> findByPatient_CaregiverIdOrderByTriggeredAtDesc(Long caregiverId);
    List<SosAlert> findByPatient_CaregiverIdAndResolvedFalse(Long caregiverId);
    @Query("SELECT COUNT(s) FROM SosAlert s WHERE s.patient.id = :patientId " +
            "AND s.resolved = false")
    Long countUnresolvedByPatientId(Long patientId);
}