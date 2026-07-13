package com.dement.controller;

import com.dement.dto.request.EmergencyContactRequest;
import com.dement.dto.response.ApiResponse;
import com.dement.dto.response.EmergencyContactResponse;
import com.dement.security.UserPrincipal;
import com.dement.service.EmergencyContactService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/emergency-contacts")
@RequiredArgsConstructor
public class EmergencyContactController {

    private final EmergencyContactService emergencyContactService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<EmergencyContactResponse>>> getContacts(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(
                emergencyContactService.getContacts(principal.getId()), "Contacts fetched"));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<EmergencyContactResponse>> addContact(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody EmergencyContactRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                emergencyContactService.addContact(principal.getId(), request), "Contact added"));
    }

    @PutMapping("/{contactId}")
    public ResponseEntity<ApiResponse<EmergencyContactResponse>> updateContact(
            @PathVariable Long contactId,
            @Valid @RequestBody EmergencyContactRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                emergencyContactService.updateContact(contactId, request), "Contact updated"));
    }

    @DeleteMapping("/{contactId}")
    public ResponseEntity<ApiResponse<String>> deleteContact(@PathVariable Long contactId) {
        emergencyContactService.deleteContact(contactId);
        return ResponseEntity.ok(ApiResponse.success("Contact deleted"));
    }
}