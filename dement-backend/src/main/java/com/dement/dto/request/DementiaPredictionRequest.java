package com.dement.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DementiaPredictionRequest {

    @NotNull(message = "Gender is required")
    @Min(0)
    @Max(1)
    private Integer gender;

    @NotNull(message = "Age is required")
    @DecimalMin("18.0")
    @DecimalMax("120.0")
    private Double age;

    @NotNull(message = "Education is required")
    @DecimalMin("0.0")
    private Double educ;

    @NotNull(message = "SES is required")
    @DecimalMin("1.0")
    @DecimalMax("5.0")
    private Double ses;

    @NotNull(message = "MMSE is required")
    @DecimalMin("0.0")
    @DecimalMax("30.0")
    private Double mmse;

}