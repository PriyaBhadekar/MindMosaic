// REPLACE src/main/java/com/dement/repository/VoiceLogRepository.java
package com.dement.repository;

import com.dement.entity.VoiceLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface VoiceLogRepository extends JpaRepository<VoiceLog, Long> {

    List<VoiceLog> findByPatientIdOrderByLoggedAtDesc(Long patientId);

    List<VoiceLog> findByPatientIdAndSosTriggeredTrueOrderByLoggedAtDesc(Long patientId);

    List<VoiceLog> findByPatientIdAndDistressDetectedTrueOrderByLoggedAtDesc(Long patientId);

    @Query("SELECT v FROM VoiceLog v WHERE v.patient.caregiver.id = :caregiverId " +
            "ORDER BY v.loggedAt DESC")
    List<VoiceLog> findByCaregiverId(Long caregiverId);

    @Query("SELECT v FROM VoiceLog v WHERE v.patient.caregiver.id = :caregiverId " +
            "AND v.distressDetected = true ORDER BY v.loggedAt DESC")
    List<VoiceLog> findDistressLogsByCaregiverId(Long caregiverId);

    @Query("SELECT v FROM VoiceLog v WHERE v.patient.caregiver.id = :caregiverId " +
            "AND v.sosTriggered = true ORDER BY v.loggedAt DESC")
    List<VoiceLog> findSosLogsByCaregiverId(Long caregiverId);

    @Query("SELECT COUNT(v) FROM VoiceLog v WHERE v.patient.id = :patientId " +
            "AND v.loggedAt >= :since")
    Long countRecentByPatientId(Long patientId, LocalDateTime since);
}