package com.dement.repository;

import com.dement.entity.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalTime;
import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {
    List<Schedule> findByCaregiverId(Long caregiverId);
    List<Schedule> findByCaregiverIdOrderByScheduledTimeAsc(Long caregiverId);
    List<Schedule> findByCaregiverIdAndActiveTrue(Long caregiverId);
    List<Schedule> findByActiveTrueAndScheduledTimeBetween(LocalTime start, LocalTime end);

}