package com.dement.service;

import com.dement.dto.request.PatientProfileRequest;
import com.dement.dto.response.PatientResponse;
import com.dement.entity.Caregiver;
import com.dement.entity.Patient;
import com.dement.exception.ResourceNotFoundException;
import com.dement.repository.CaregiverRepository;
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
public class PatientService {

    private final PatientRepository patientRepository;
    private final CaregiverService caregiverService;
    private final FileStorageService fileStorageService;

    public List<PatientResponse> getPatientsForCaregiver(Long caregiverId) {
        return patientRepository.findByCaregiverId(caregiverId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public PatientResponse getPatientById(Long patientId) {
        Patient p = patientRepository.findById(patientId)
                .orElseThrow(() -> new ResourceNotFoundException("Patient", "id", patientId));
        return mapToPatientResponse(p);
    }

    @Transactional
    public PatientResponse createPatient(Long caregiverId, PatientProfileRequest request) {
        Caregiver caregiver = caregiverService.findById(caregiverId);

        Patient patient = Patient.builder()
                .name(request.getName())
                .age(request.getAge())
                .address(request.getAddress())
                .emergencyContactNumber(request.getEmergencyContactNumber())
                .phoneNumber(request.getPhoneNumber())
                .linkedCode("PAT-" + System.currentTimeMillis())
                .caregiver(caregiver)
                .build();

        return mapToResponse(patientRepository.save(patient));
    }

    @Transactional
    public PatientResponse updatePatient(Long patientId, PatientProfileRequest request) {
        Patient patient = findById(patientId);
        if (request.getName() != null) patient.setName(request.getName());
        if (request.getAge() != null) patient.setAge(request.getAge());
        if (request.getAddress() != null) patient.setAddress(request.getAddress());
        if (request.getEmergencyContactNumber() != null) patient.setEmergencyContactNumber(request.getEmergencyContactNumber());
        if (request.getPhoneNumber() != null) patient.setPhoneNumber(request.getPhoneNumber());
        return mapToResponse(patientRepository.save(patient));
    }

    @Transactional
    public PatientResponse uploadPatientPhoto(Long patientId, MultipartFile file) {
        Patient patient = findById(patientId);
        if (patient.getPhotoPath() != null) {
            fileStorageService.deleteFile(patient.getPhotoPath());
        }
        String path = fileStorageService.storeProfileImage(file);
        patient.setPhotoPath(path);
        return mapToResponse(patientRepository.save(patient));
    }

    @Transactional
    public void updatePatientLocation(Long patientId, Double latitude, Double longitude) {
        Patient patient = findById(patientId);
        patient.setLastKnownLatitude(latitude);
        patient.setLastKnownLongitude(longitude);
        patientRepository.save(patient);
    }

    public Patient findById(Long id) {
        return patientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Patient", "id", id));
    }

    // REPLACE the mapToResponse method in PatientService.java:
    private PatientResponse mapToResponse(Patient patient) {
        return PatientResponse.builder()
                .id(patient.getId())
                .name(patient.getName())
                .photoPath(patient.getPhotoPath())
                .age(patient.getAge())
                .address(patient.getAddress())
                .emergencyContactNumber(patient.getEmergencyContactNumber())
                .phoneNumber(patient.getPhoneNumber())
                .linkedCode(patient.getLinkedCode())
                .caregiverId(patient.getCaregiver() != null ? patient.getCaregiver().getId() : null)
                .caregiverName(patient.getCaregiver() != null ? patient.getCaregiver().getName() : null)
                .createdAt(patient.getCreatedAt())
                .build();
    }

    // ADD this method — same as mapToResponse, just an alias
    private PatientResponse mapToPatientResponse(Patient patient) {
        return mapToResponse(patient);
    }

    @Transactional
    public void linkPatientToCaregiver(
            String patientCode,
            String caregiverCode

    ) {

        System.out.println("==============");
        System.out.println("PATIENT CODE = " + patientCode);
        System.out.println("CAREGIVER CODE = " + caregiverCode);
        System.out.println("==============");

        Patient patient = patientRepository
                .findByLinkedCode(patientCode)
                .orElseThrow(() ->
                        new RuntimeException("Patient not found"));

        Caregiver caregiver = caregiverService
                .findByUniqueCode(caregiverCode);

        patient.setCaregiver(caregiver);

        patientRepository.save(patient);
    }

    public PatientResponse getPatientByLinkedCode(String code) {

        Patient patient = patientRepository
                .findByLinkedCode(code)
                .orElseThrow(() ->
                        new RuntimeException("Invalid patient code"));

        return mapToResponse(patient);
    }
}