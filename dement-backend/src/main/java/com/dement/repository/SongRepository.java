package com.dement.repository;

import com.dement.entity.Song;
import com.dement.enums.MoodType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SongRepository extends JpaRepository<Song, Long> {
    List<Song> findByCaregiverId(Long caregiverId);
    List<Song> findByCaregiverIdAndMoodCategory(Long caregiverId, MoodType moodCategory);
}