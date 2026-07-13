package com.dement.dto.request;

import lombok.Data;

@Data
public class LinkPatientRequest {

    private String patientCode;

    private String caregiverCode;
}