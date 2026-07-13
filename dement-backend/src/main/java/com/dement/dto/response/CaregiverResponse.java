package com.dement.dto.response;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CaregiverResponse {
    private Long id;
    private String name;
    private String email;
    private String phoneNumber;
    private String profileImagePath;
    private String uniqueCode;
    private LocalDateTime createdAt;
}