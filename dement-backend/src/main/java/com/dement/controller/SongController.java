package com.dement.controller;

import com.dement.dto.request.SongRequest;
import com.dement.dto.response.ApiResponse;
import com.dement.dto.response.SongResponse;
import com.dement.enums.MoodType;
import com.dement.security.UserPrincipal;
import com.dement.service.SongService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/songs")
@RequiredArgsConstructor
public class SongController {

    private final SongService songService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<SongResponse>>> getSongs(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(
                songService.getSongs(principal.getId()), "Songs fetched"));
    }

    @GetMapping("/mood/{mood}")
    public ResponseEntity<ApiResponse<List<SongResponse>>> getSongsByMood(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable MoodType mood) {
        return ResponseEntity.ok(ApiResponse.success(
                songService.getSongsByMood(principal.getId(), mood), "Songs fetched by mood"));
    }

    @PostMapping(consumes = {"multipart/form-data"})
    public ResponseEntity<ApiResponse<SongResponse>> uploadSong(

            @AuthenticationPrincipal UserPrincipal principal,

            @RequestPart("data") String data,

            @RequestPart(value = "audio", required = false)
            MultipartFile audioFile) {

        try {

            com.fasterxml.jackson.databind.ObjectMapper mapper =
                    new com.fasterxml.jackson.databind.ObjectMapper();

            SongRequest request =
                    mapper.readValue(data, SongRequest.class);

            return ResponseEntity.ok(
                    ApiResponse.success(
                            songService.uploadSong(
                                    principal.getId(),
                                    request,
                                    audioFile
                            ),
                            "Song uploaded"
                    )
            );

        } catch (Exception e) {

            e.printStackTrace();

            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error(
                            "SONG_UPLOAD_FAILED",
                            "Failed to upload song: " + e.getMessage()
                    ));
        }
    }

    @DeleteMapping("/{songId}")
    public ResponseEntity<ApiResponse<String>> deleteSong(@PathVariable Long songId) {
        songService.deleteSong(songId);
        return ResponseEntity.ok(ApiResponse.success("Song deleted"));
    }
}