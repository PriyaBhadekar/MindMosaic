package com.dement.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class MemoryRequest {

    @NotBlank(message = "Title is required")
    private String title;

    private String description;
    private String relationInfo;
    private String category;
    private String tags;
}