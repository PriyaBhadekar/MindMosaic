package com.dement.service;

import com.dement.dto.request.MemoryRequest;
import com.dement.dto.response.MemoryResponse;
import com.dement.entity.Caregiver;
import com.dement.entity.Memory;
import com.dement.entity.Patient;
import com.dement.exception.ResourceNotFoundException;
import com.dement.repository.MemoryRepository;
import com.dement.repository.PatientRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MemoryService {

    private final MemoryRepository memoryRepository;
    private final CaregiverService caregiverService;
    private final FileStorageService fileStorageService;
    private final PatientRepository patientRepository;

    public List<MemoryResponse> getMemoriesForCaregiver(Long caregiverId) {
        return memoryRepository.findByCaregiverId(caregiverId)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    public List<MemoryResponse> getMemoriesByCategory(Long caregiverId, String category) {
        return memoryRepository.findByCaregiverIdAndCategory(caregiverId, category)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    public MemoryResponse getMemoryById(Long memoryId) {
        return mapToResponse(findById(memoryId));
    }

    @Transactional
    public MemoryResponse createMemory(Long caregiverId, MemoryRequest request, MultipartFile imageFile) {
        Caregiver caregiver = caregiverService.findById(caregiverId);
        String imagePath = null;
        if (imageFile != null && !imageFile.isEmpty()) {
            imagePath = fileStorageService.storeMemoryImage(imageFile);
        }

        Memory memory = Memory.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .imagePath(imagePath)
                .relationInfo(request.getRelationInfo())
                .category(request.getCategory())
                .tags(request.getTags())
                .caregiver(caregiver)
                .build();

        return mapToResponse(memoryRepository.save(memory));
    }

    @Transactional
    public MemoryResponse updateMemory(Long memoryId, MemoryRequest request, MultipartFile imageFile) {
        Memory memory = findById(memoryId);
        if (request.getTitle() != null) memory.setTitle(request.getTitle());
        if (request.getDescription() != null) memory.setDescription(request.getDescription());
        if (request.getRelationInfo() != null) memory.setRelationInfo(request.getRelationInfo());
        if (request.getCategory() != null) memory.setCategory(request.getCategory());
        if (request.getTags() != null) memory.setTags(request.getTags());

        if (imageFile != null && !imageFile.isEmpty()) {
            if (memory.getImagePath() != null) fileStorageService.deleteFile(memory.getImagePath());
            memory.setImagePath(fileStorageService.storeMemoryImage(imageFile));
        }

        return mapToResponse(memoryRepository.save(memory));
    }

    @Transactional
    public void deleteMemory(Long memoryId) {
        Memory memory = findById(memoryId);
        if (memory.getImagePath() != null) fileStorageService.deleteFile(memory.getImagePath());
        memoryRepository.delete(memory);
    }

    public Memory findById(Long id) {
        return memoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Memory", "id", id));
    }

    private static final String BASE_URL = "http://localhost:8080";

    private MemoryResponse mapToResponse(Memory memory) {
        String imageUrl = null;
        if (memory.getImagePath() != null && !memory.getImagePath().isBlank()) {
            imageUrl = BASE_URL + "/" + memory.getImagePath().replace("\\", "/");
        }
        return MemoryResponse.builder()
                .id(memory.getId())
                .title(memory.getTitle())
                .description(memory.getDescription())
                .imagePath(memory.getImagePath())
                .imageUrl(imageUrl)       // NEW
                .relationInfo(memory.getRelationInfo())
                .category(memory.getCategory())
                .tags(memory.getTags())
                .createdAt(memory.getCreatedAt())
                .build();
    }

    public MemoryResponse updateMemory(
            Long memoryId,
            MemoryRequest request
    ) {

        Memory memory = memoryRepository.findById(memoryId)
                .orElseThrow(() ->
                        new RuntimeException("Memory not found"));

        memory.setTitle(request.getTitle());
        memory.setDescription(request.getDescription());
        memory.setRelationInfo(request.getRelationInfo());

        Memory updatedMemory = memoryRepository.save(memory);

        return mapToResponse(updatedMemory);
    }
    public List<MemoryResponse> getMemoriesForPatient(Long patientId) {

        Patient patient = patientRepository.findById(patientId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Patient",
                                "id",
                                patientId
                        ));

        Long caregiverId = patient.getCaregiver().getId();

        return memoryRepository.findByCaregiverId(caregiverId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
}

