package com.dement.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class PatientProfileRequest {

    @NotBlank(message = "Patient name is required")
    private String name;

    private Integer age;
    private String address;
    private String emergencyContactNumber;
    private String phoneNumber;
}