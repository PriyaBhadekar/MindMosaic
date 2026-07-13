package com.dement.dto.request;

import lombok.Data;

@Data
public class AiChatRequest {

    private Long patientId;

    private String message;
}