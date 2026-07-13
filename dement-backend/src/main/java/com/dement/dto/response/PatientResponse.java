// UPDATE src/main/java/com/dement/dto/response/PatientResponse.java
package com.dement.dto.response;

import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PatientResponse {
    private Long id;
    private String name;
    private String photoPath;
    private String imageUrl;
    private Integer age;
    private String address;
    private String emergencyContactNumber;
    private String phoneNumber;
    private String linkedCode;
    private Long caregiverId;          // ADD THIS
    private String caregiverName;      // ADD THIS
    private LocalDateTime createdAt;
}