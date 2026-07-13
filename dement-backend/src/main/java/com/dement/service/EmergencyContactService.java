package com.dement.service;

import com.dement.dto.request.EmergencyContactRequest;
import com.dement.dto.response.EmergencyContactResponse;
import com.dement.entity.Caregiver;
import com.dement.entity.EmergencyContact;
import com.dement.exception.ResourceNotFoundException;
import com.dement.repository.EmergencyContactRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EmergencyContactService {

    private final EmergencyContactRepository emergencyContactRepository;
    private final CaregiverService caregiverService;

    public List<EmergencyContactResponse> getContacts(Long caregiverId) {
        return emergencyContactRepository.findByCaregiverId(caregiverId)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Transactional
    public EmergencyContactResponse addContact(Long caregiverId, EmergencyContactRequest request) {
        Caregiver caregiver = caregiverService.findById(caregiverId);

        EmergencyContact contact = EmergencyContact.builder()
                .name(request.getName())
                .phoneNumber(request.getPhoneNumber())
                .relationship(request.getRelationship())
                .primary(request.isPrimary())
                .caregiver(caregiver)
                .build();

        return mapToResponse(emergencyContactRepository.save(contact));
    }

    @Transactional
    public EmergencyContactResponse updateContact(Long contactId, EmergencyContactRequest request) {
        EmergencyContact contact = emergencyContactRepository.findById(contactId)
                .orElseThrow(() -> new ResourceNotFoundException("Contact", "id", contactId));
        contact.setName(request.getName());
        contact.setPhoneNumber(request.getPhoneNumber());
        contact.setRelationship(request.getRelationship());
        contact.setPrimary(request.isPrimary());
        return mapToResponse(emergencyContactRepository.save(contact));
    }

    @Transactional
    public void deleteContact(Long contactId) {
        emergencyContactRepository.deleteById(contactId);
    }

    private EmergencyContactResponse mapToResponse(EmergencyContact c) {
        return EmergencyContactResponse.builder()
                .id(c.getId())
                .name(c.getName())
                .phoneNumber(c.getPhoneNumber())
                .relationship(c.getRelationship())
                .primary(c.isPrimary())
                .build();
    }
}