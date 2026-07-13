package com.dement.dto.response;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MemoryResponse {
    private Long id;
    private String title;
    private String description;
    private String imagePath;
    private String relationInfo;
    private String category;
    private String tags;
    private LocalDateTime createdAt;
    private String imageUrl;   // ADD if missing
}