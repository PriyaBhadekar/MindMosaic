package com.dement.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AiChatResponse {

    private String response;

    private String intent;

    private String emotion;

    private String action;

    private boolean caregiverAlert;
}