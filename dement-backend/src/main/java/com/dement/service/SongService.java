package com.dement.service;

import com.dement.dto.request.SongRequest;
import com.dement.dto.response.SongResponse;
import com.dement.entity.Caregiver;
import com.dement.entity.Song;
import com.dement.enums.MoodType;
import com.dement.exception.ResourceNotFoundException;
import com.dement.repository.SongRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SongService {

    private final SongRepository songRepository;
    private final CaregiverService caregiverService;
    private final FileStorageService fileStorageService;

    public List<SongResponse> getSongs(Long caregiverId) {
        return songRepository.findByCaregiverId(caregiverId)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    public List<SongResponse> getSongsByMood(Long caregiverId, MoodType mood) {
        return songRepository.findByCaregiverIdAndMoodCategory(caregiverId, mood)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Transactional
    public SongResponse uploadSong(Long caregiverId, SongRequest request, MultipartFile audioFile) {
        Caregiver caregiver = caregiverService.findById(caregiverId);
        String audioPath = null;
        if (audioFile != null && !audioFile.isEmpty()) {
            audioPath = fileStorageService.storeSong(audioFile);
            System.out.println("AUDIO PATH = " + audioPath);
        }

        Song song = Song.builder()
                .title(request.getTitle())
                .artist(request.getArtist())
                .audioPath(audioPath)
                .moodCategory(request.getMoodCategory())
                .durationSeconds(request.getDurationSeconds())
                .caregiver(caregiver)
                .build();

        return mapToResponse(songRepository.save(song));
    }

    @Transactional
    public void deleteSong(Long songId) {
        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new ResourceNotFoundException("Song", "id", songId));
        if (song.getAudioPath() != null) fileStorageService.deleteFile(song.getAudioPath());
        songRepository.delete(song);
    }

    private SongResponse mapToResponse(Song song) {
        return SongResponse.builder()
                .id(song.getId())
                .title(song.getTitle())
                .artist(song.getArtist())
                .audioPath(song.getAudioPath())
                .moodCategory(song.getMoodCategory())
                .durationSeconds(song.getDurationSeconds())
                .createdAt(song.getCreatedAt())
                .build();
    }
}