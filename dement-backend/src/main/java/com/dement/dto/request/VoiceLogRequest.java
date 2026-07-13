package com.dement.dto.request;

import lombok.Data;

@Data
public class VoiceLogRequest {
    private Long patientId;
    private String promptText;
    private String patientResponse;
    private String responseType;
}