package com.dement.service;

import com.dement.dto.request.CaregiverRegisterRequest;
import com.dement.dto.request.LoginRequest;
import com.dement.dto.request.PatientLinkRequest;
import com.dement.dto.response.AuthResponse;
import com.dement.dto.response.PatientResponse;
import com.dement.entity.Caregiver;
import com.dement.entity.Patient;
import com.dement.exception.DuplicateResourceException;
import com.dement.exception.InvalidCodeException;
import com.dement.repository.CaregiverRepository;
import com.dement.repository.PatientRepository;
import com.dement.security.JwtTokenProvider;
import com.dement.security.UserPrincipal;
import com.dement.utils.UniqueCodeGenerator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.dement.enums.UserRole;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final CaregiverRepository caregiverRepository;
    private final PatientRepository patientRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final UniqueCodeGenerator uniqueCodeGenerator;

    @Transactional
    public AuthResponse registerCaregiver(CaregiverRegisterRequest request) {
        if (caregiverRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("Email already registered: " + request.getEmail());
        }

        String uniqueCode;
        do {
            uniqueCode = uniqueCodeGenerator.generateWithPrefix("DM");
        } while (caregiverRepository.existsByUniqueCode(uniqueCode));

        Caregiver caregiver = Caregiver.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .phoneNumber(request.getPhoneNumber())
                .uniqueCode(uniqueCode)
                .role(UserRole.CAREGIVER)
                .build();

        caregiver = caregiverRepository.save(caregiver);
        log.info("Caregiver registered successfully: {}", caregiver.getEmail());

        String token = jwtTokenProvider.generateTokenFromId(caregiver.getId(), caregiver.getRole().name());

        return AuthResponse.builder()
                .accessToken(token)
                .tokenType("Bearer")
                .role(caregiver.getRole())
                .userId(caregiver.getId())
                .name(caregiver.getName())
                .email(caregiver.getEmail())
                .phoneNumber(caregiver.getPhoneNumber())
                .uniqueCode(caregiver.getUniqueCode())
                .build();
    }

    @Transactional
    public AuthResponse loginCaregiver(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        String token = jwtTokenProvider.generateToken(authentication);

        Caregiver caregiver = caregiverRepository.findById(userPrincipal.getId())
                .orElseThrow();

        return AuthResponse.builder()
                .accessToken(token)
                .tokenType("Bearer")
                .role(caregiver.getRole())
                .userId(caregiver.getId())
                .name(caregiver.getName())
                .email(caregiver.getEmail())
                .phoneNumber(caregiver.getPhoneNumber())
                .uniqueCode(caregiver.getUniqueCode())
                .build();
    }

    @Transactional
    public PatientResponse linkPatient(PatientLinkRequest request) {
        Caregiver caregiver = caregiverRepository.findByUniqueCode(request.getUniqueCode())
                .orElseThrow(() -> new InvalidCodeException("Invalid caregiver code: " + request.getUniqueCode()));

        Patient patient = Patient.builder()
                .name("Patient")
                .linkedCode(request.getUniqueCode())
                .caregiver(caregiver)
                .build();

        patient = patientRepository.save(patient);
        log.info("Patient linked to caregiver: {}", caregiver.getEmail());

        return mapToPatientResponse(patient);
    }

    private PatientResponse mapToPatientResponse(Patient patient) {
        return PatientResponse.builder()
                .id(patient.getId())
                .name(patient.getName())
                .photoPath(patient.getPhotoPath())
                .age(patient.getAge())
                .address(patient.getAddress())
                .emergencyContactNumber(patient.getEmergencyContactNumber())
                .phoneNumber(patient.getPhoneNumber())
                .linkedCode(patient.getLinkedCode())
                .caregiverId(patient.getCaregiver().getId())          // ADD
                .caregiverName(patient.getCaregiver().getName())      // ADD
                .createdAt(patient.getCreatedAt())
                .build();
    }
}