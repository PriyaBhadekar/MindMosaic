package com.dement.service;

import com.dement.dto.response.CaregiverResponse;
import com.dement.entity.Caregiver;
import com.dement.exception.ResourceNotFoundException;
import com.dement.repository.CaregiverRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
@Slf4j
public class CaregiverService {

    private final CaregiverRepository caregiverRepository;
    private final FileStorageService fileStorageService;

    public CaregiverResponse getProfile(Long caregiverId) {
        Caregiver caregiver = findById(caregiverId);
        return mapToResponse(caregiver);
    }

    @Transactional
    public CaregiverResponse updateProfile(Long caregiverId, String name, String phoneNumber) {
        Caregiver caregiver = findById(caregiverId);
        if (name != null) caregiver.setName(name);
        if (phoneNumber != null) caregiver.setPhoneNumber(phoneNumber);
        return mapToResponse(caregiverRepository.save(caregiver));
    }

    @Transactional
    public CaregiverResponse uploadProfileImage(Long caregiverId, MultipartFile file) {
        Caregiver caregiver = findById(caregiverId);
        if (caregiver.getProfileImagePath() != null) {
            fileStorageService.deleteFile(caregiver.getProfileImagePath());
        }
        String path = fileStorageService.storeProfileImage(file);
        caregiver.setProfileImagePath(path);
        return mapToResponse(caregiverRepository.save(caregiver));
    }

    public Caregiver findById(Long id) {
        return caregiverRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Caregiver", "id", id));
    }

    private CaregiverResponse mapToResponse(Caregiver caregiver) {
        return CaregiverResponse.builder()
                .id(caregiver.getId())
                .name(caregiver.getName())
                .email(caregiver.getEmail())
                .phoneNumber(caregiver.getPhoneNumber())
                .profileImagePath(caregiver.getProfileImagePath())
                .uniqueCode(caregiver.getUniqueCode())
                .createdAt(caregiver.getCreatedAt())
                .build();
    }

    public Caregiver findByUniqueCode(String uniqueCode) {

        return caregiverRepository
                .findByUniqueCode(uniqueCode)
                .orElseThrow(() ->
                        new RuntimeException("Caregiver not found"));
    }
}