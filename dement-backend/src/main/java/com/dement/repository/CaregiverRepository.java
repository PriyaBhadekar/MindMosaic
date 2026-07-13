package com.dement.repository;

import com.dement.entity.Caregiver;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CaregiverRepository extends JpaRepository<Caregiver, Long> {
    Optional<Caregiver> findByEmail(String email);
    Optional<Caregiver> findByUniqueCode(String uniqueCode);
    boolean existsByEmail(String email);
    boolean existsByUniqueCode(String uniqueCode);
}