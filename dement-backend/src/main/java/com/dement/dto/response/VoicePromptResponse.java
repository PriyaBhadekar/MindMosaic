package com.dement.dto.response;

import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class VoicePromptResponse {
    private String promptText;
    private String promptType;
    private String suggestion;
    private boolean requiresResponse;
}