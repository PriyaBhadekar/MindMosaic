package com.dement.repository;

import com.dement.entity.MriScan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MriScanRepository extends JpaRepository<MriScan, Long> {
    List<MriScan> findByCaregiverIdOrderByCreatedAtDesc(Long caregiverId);
    List<MriScan> findByPatientIdOrderByCreatedAtDesc(Long patientId);
}