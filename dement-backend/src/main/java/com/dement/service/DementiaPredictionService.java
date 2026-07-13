package com.dement.service;

import com.dement.dto.request.DementiaPredictionRequest;
import com.dement.dto.response.DementiaPredictionResponse;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class DementiaPredictionService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${app.ml.service.url:http://localhost:8001}")
    private String mlServiceUrl;

    public DementiaPredictionResponse predict(DementiaPredictionRequest request) {

        Map<String, Object> payload = new HashMap<>();

        payload.put("gender", request.getGender());
        payload.put("age", request.getAge());
        payload.put("educ", request.getEduc());
        payload.put("ses", request.getSes());
        payload.put("mmse", request.getMmse());

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> entity =
                new HttpEntity<>(payload, headers);

        try {

            ResponseEntity<String> response =
                    restTemplate.postForEntity(
                            mlServiceUrl + "/predict",
                            entity,
                            String.class
                    );

            JsonNode json =
                    objectMapper.readTree(response.getBody());

            return DementiaPredictionResponse.builder()

                    .hasDementia(
                            json.get("has_dementia").asBoolean()
                    )

                    .probability(
                            json.get("probability").asDouble()
                    )

                    .riskLevel(
                            json.get("risk_level").asText()
                    )

                    .stage(
                            json.get("stage").asText()
                    )

                    .recommendation(
                            json.get("recommendation").asText()
                    )

                    .emoji(
                            json.get("emoji").asText()
                    )

                    .build();

        }

        catch (Exception e) {

            log.error("Prediction Error", e);

            throw new RuntimeException(
                    "Unable to connect to AI Prediction Server."
            );

        }

    }

}