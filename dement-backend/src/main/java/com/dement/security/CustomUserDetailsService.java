package com.dement.security;

import com.dement.entity.Caregiver;
import com.dement.entity.Patient;
import com.dement.enums.UserRole;
import com.dement.exception.ResourceNotFoundException;
import com.dement.repository.CaregiverRepository;
import com.dement.repository.PatientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final CaregiverRepository caregiverRepository;
    private final PatientRepository patientRepository;

    @Override
    @Transactional
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Caregiver caregiver = caregiverRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));
        return UserPrincipal.create(caregiver);
    }

    @Transactional
    public UserDetails loadUserByIdAndRole(Long id, String role) {
        if (UserRole.CAREGIVER.name().equals(role)) {
            Caregiver caregiver = caregiverRepository.findById(id)
                    .orElseThrow(() -> new ResourceNotFoundException("Caregiver not found with id: " + id));
            return UserPrincipal.create(caregiver);
        } else {
            Patient patient = patientRepository.findById(id)
                    .orElseThrow(() -> new ResourceNotFoundException("Patient not found with id: " + id));
            return new UserPrincipal(patient.getId(), "patient_" + patient.getId(), "", patient.getRole());
        }
    }
}