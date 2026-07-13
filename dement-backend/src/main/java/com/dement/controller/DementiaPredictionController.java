package com.dement.controller;

import com.dement.dto.request.DementiaPredictionRequest;
import com.dement.dto.response.ApiResponse;
import com.dement.dto.response.DementiaPredictionResponse;
import com.dement.service.DementiaPredictionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dementia")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DementiaPredictionController {

    private final DementiaPredictionService dementiaPredictionService;

    @PostMapping("/predict")
    public ResponseEntity<ApiResponse<DementiaPredictionResponse>> predict(
            @Valid @RequestBody DementiaPredictionRequest request) {

        DementiaPredictionResponse response =
                dementiaPredictionService.predict(request);

        return ResponseEntity.ok(
                ApiResponse.success(
                        response,
                        "Prediction completed successfully."
                )
        );
    }

}