package com.dement.repository;

import com.dement.entity.Memory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MemoryRepository extends JpaRepository<Memory, Long> {
    List<Memory> findByCaregiverId(Long caregiverId);
    List<Memory> findByCaregiverIdAndCategory(Long caregiverId, String category);
}