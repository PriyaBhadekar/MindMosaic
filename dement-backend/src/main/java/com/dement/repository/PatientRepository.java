package com.dement.repository;

import com.dement.entity.Patient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PatientRepository extends JpaRepository<Patient, Long> {
    List<Patient> findByCaregiverId(Long caregiverId);
    Optional<Patient> findByLinkedCode(String linkedCode);
    boolean existsByLinkedCode(String linkedCode);


}