package com.dement.dto.request;

import lombok.Data;

@Data
public class GeminiRequest {

    private Long patientId;

    private String message;
}