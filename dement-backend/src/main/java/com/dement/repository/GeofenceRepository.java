package com.dement.repository;

import com.dement.entity.Geofence;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GeofenceRepository extends JpaRepository<Geofence, Long> {
    Optional<Geofence> findByCaregiverId(Long caregiverId);
    boolean existsByCaregiverId(Long caregiverId);
}