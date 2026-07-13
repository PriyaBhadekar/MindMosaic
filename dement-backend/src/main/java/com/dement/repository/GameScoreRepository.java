// REPLACE src/main/java/com/dement/repository/GameScoreRepository.java
package com.dement.repository;

import com.dement.entity.GameScore;
import com.dement.enums.GameType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GameScoreRepository extends JpaRepository<GameScore, Long> {

    List<GameScore> findByPatientIdOrderByPlayedAtDesc(Long patientId);

    List<GameScore> findByPatientIdAndGameTypeOrderByPlayedAtDesc(
            Long patientId, GameType gameType);

    @Query("SELECT AVG(g.score * 1.0 / g.maxScore * 100) FROM GameScore g " +
            "WHERE g.patient.id = :patientId AND g.gameType = :gameType " +
            "AND g.maxScore > 0")
    Double findAveragePercentageByPatientAndGame(Long patientId, GameType gameType);

    @Query("SELECT MAX(g.score) FROM GameScore g " +
            "WHERE g.patient.id = :patientId AND g.gameType = :gameType")
    Integer findHighScoreByPatientAndGame(Long patientId, GameType gameType);

    @Query("SELECT COUNT(g) FROM GameScore g WHERE g.patient.id = :patientId")
    Long countByPatientId(Long patientId);

    @Query("SELECT g FROM GameScore g WHERE g.patient.caregiver.id = :caregiverId " +
            "ORDER BY g.playedAt DESC")
    List<GameScore> findByCaregiverId(Long caregiverId);

    @Query("SELECT g FROM GameScore g WHERE g.patient.id = :patientId " +
            "ORDER BY g.playedAt DESC")
    List<GameScore> findTopScoresByPatient(Long patientId,
                                           org.springframework.data.domain.Pageable pageable);
}