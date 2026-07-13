// REPLACE src/main/java/com/dement/repository/MoodLogRepository.java
package com.dement.repository;

import com.dement.entity.MoodLog;
import com.dement.enums.MoodType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MoodLogRepository extends JpaRepository<MoodLog, Long> {

    List<MoodLog> findByPatientIdOrderByLoggedAtDesc(Long patientId);

    List<MoodLog> findByPatientIdAndMoodOrderByLoggedAtDesc(Long patientId, MoodType mood);

    @Query("SELECT m FROM MoodLog m WHERE m.patient.caregiver.id = :caregiverId " +
            "ORDER BY m.loggedAt DESC")
    List<MoodLog> findByCaregiverId(Long caregiverId);

    @Query("SELECT m FROM MoodLog m WHERE m.patient.caregiver.id = :caregiverId " +
            "AND (m.mood = 'SAD' OR m.mood = 'ANXIOUS' OR m.mood = 'AGITATED') " +
            "ORDER BY m.loggedAt DESC")
    List<MoodLog> findNegativeMoodsByCaregiverId(Long caregiverId);

    @Query("SELECT m.mood, COUNT(m) FROM MoodLog m WHERE m.patient.id = :patientId " +
            "GROUP BY m.mood")
    List<Object[]> getMoodDistributionByPatientId(Long patientId);
}