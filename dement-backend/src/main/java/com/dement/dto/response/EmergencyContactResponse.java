package com.dement.dto.response;

import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class EmergencyContactResponse {
    private Long id;
    private String name;
    private String phoneNumber;
    private String relationship;
    private boolean primary;
}