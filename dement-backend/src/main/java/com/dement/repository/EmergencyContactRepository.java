package com.dement.repository;

import com.dement.entity.EmergencyContact;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EmergencyContactRepository extends JpaRepository<EmergencyContact, Long> {
    List<EmergencyContact> findByCaregiverId(Long caregiverId);
    List<EmergencyContact> findByCaregiverIdAndPrimaryTrue(Long caregiverId);
}