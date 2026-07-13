package com.dement.dto.response;

import com.dement.enums.UserRole;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuthResponse {
    private String accessToken;
    private String tokenType = "Bearer";
    private UserRole role;
    private Long userId;
    private String name;
    private String uniqueCode;
    private String email;
    private String phoneNumber;
}