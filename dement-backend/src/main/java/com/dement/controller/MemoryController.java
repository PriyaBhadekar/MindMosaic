package com.dement.controller;

import com.dement.dto.request.MemoryRequest;
import com.dement.dto.response.ApiResponse;
import com.dement.dto.response.MemoryResponse;
import com.dement.entity.Memory;
import com.dement.security.UserPrincipal;
import com.dement.service.MemoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;

@RestController
@RequestMapping("/api/memories")
@RequiredArgsConstructor
public class MemoryController {

    private final MemoryService memoryService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<MemoryResponse>>> getMemories(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(
                memoryService.getMemoriesForCaregiver(principal.getId()), "Memories fetched"));
    }

    @GetMapping("/category/{category}")
    public ResponseEntity<ApiResponse<List<MemoryResponse>>> getByCategory(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable String category) {
        return ResponseEntity.ok(ApiResponse.success(
                memoryService.getMemoriesByCategory(principal.getId(), category), "Memories fetched"));
    }

    @GetMapping("/{memoryId}")
    public ResponseEntity<ApiResponse<MemoryResponse>> getMemory(@PathVariable Long memoryId) {
        return ResponseEntity.ok(ApiResponse.success(
                memoryService.getMemoryById(memoryId), "Memory fetched"));
    }

    @PostMapping(consumes = {"multipart/form-data"})
    public ResponseEntity<ApiResponse<MemoryResponse>> createMemory(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestPart("data") String data,
            @RequestPart(value = "image", required = false) MultipartFile image) {

        try {

            ObjectMapper mapper = new ObjectMapper();

            MemoryRequest request =
                    mapper.readValue(data, MemoryRequest.class);

            return ResponseEntity.ok(
                    ApiResponse.success(
                            memoryService.createMemory(
                                    principal.getId(),
                                    request,
                                    image
                            ),
                            "Memory created"
                    )
            );

        } catch (Exception e) {

            e.printStackTrace();

            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error(
                            "MEMORY_CREATION_FAILED",
                            "Failed to create memory: " + e.getMessage()
                    ));
        }
    }

    @PutMapping("/{memoryId}")
    public ResponseEntity<ApiResponse<MemoryResponse>> updateMemory(

            @PathVariable Long memoryId,

            @RequestBody MemoryRequest request) {

        MemoryResponse response =
                memoryService.updateMemory(
                        memoryId,
                        request
                );

        return ResponseEntity.ok(
                ApiResponse.success(
                        response,
                        "Memory updated successfully"
                )
        );
    }

    @DeleteMapping("/{memoryId}")
    public ResponseEntity<ApiResponse<String>> deleteMemory(@PathVariable Long memoryId) {
        memoryService.deleteMemory(memoryId);
        return ResponseEntity.ok(ApiResponse.success("Memory deleted"));
    }

    @GetMapping("/patient/{patientId}")
    public ResponseEntity<ApiResponse<List<MemoryResponse>>> getPatientMemories(
            @PathVariable Long patientId
    ) {

        return ResponseEntity.ok(
                ApiResponse.success(
                        memoryService.getMemoriesForPatient(patientId),
                        "Patient memories fetched"
                )
        );
    }
}