package com.dement.service;

import com.dement.dto.response.AiChatResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class GeminiService {

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.model}")
    private String model;

    private final WebClient.Builder webClientBuilder;

    private final ObjectMapper objectMapper = new ObjectMapper();

    public AiChatResponse analyze(String prompt) {

        System.out.println("========== GEMINI ANALYZE CALLED ==========");
        System.out.println("========== GEMINI CONFIG ==========");
        System.out.println("MODEL = " + model);
        System.out.println("KEY PREFIX = " + apiKey.substring(0, 10));
        System.out.println("==================================");

        try {

            String url =
                    "https://generativelanguage.googleapis.com/v1beta/models/"
                            + model
                            + ":generateContent?key="
                            + apiKey;

            Map<String, Object> requestBody =
                    Map.of(
                            "contents",
                            List.of(
                                    Map.of(
                                            "parts",
                                            List.of(
                                                    Map.of(
                                                            "text",
                                                            prompt
                                                    )
                                            )
                                    )
                            )
                    );

            String rawResponse =
                    webClientBuilder.build()
                            .post()
                            .uri(url)
                            .contentType(MediaType.APPLICATION_JSON)
                            .bodyValue(requestBody)
                            .retrieve()
                            .bodyToMono(String.class)
                            .block();

            System.out.println("========== GEMINI RAW RESPONSE ==========");
            System.out.println(rawResponse);

            Map response =
                    objectMapper.readValue(rawResponse, Map.class);

            List<Map<String, Object>> candidates =
                    (List<Map<String, Object>>) response.get("candidates");

            Map<String, Object> candidate =
                    candidates.get(0);

            Map<String, Object> content =
                    (Map<String, Object>) candidate.get("content");

            List<Map<String, Object>> parts =
                    (List<Map<String, Object>>) content.get("parts");

            String text =
                    (String) parts.get(0).get("text");

            text = text
                    .replace("```json", "")
                    .replace("```", "")
                    .trim();

            System.out.println("========== GEMINI TEXT ==========");
            System.out.println(text);

            return objectMapper.readValue(
                    text,
                    AiChatResponse.class
            );

        } catch (Exception e) {

            System.out.println("========== GEMINI ERROR ==========");

            if (e instanceof org.springframework.web.reactive.function.client.WebClientResponseException ex) {

                System.out.println("STATUS = " + ex.getStatusCode());

                System.out.println("RESPONSE BODY = ");
                System.out.println(ex.getResponseBodyAsString());
            }

            e.printStackTrace();

            System.out.println("========== GEMINI ERROR ==========");
            e.printStackTrace();

            return AiChatResponse.builder()
                    .response(
                            "I'm sorry, I'm having a little trouble thinking right now. Could you please tell me that again?"
                    )
                    .intent("GENERAL")
                    .emotion("NEUTRAL")
                    .action("NONE")
                    .caregiverAlert(false)
                    .build();
        }
    }
}