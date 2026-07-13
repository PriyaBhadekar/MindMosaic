package com.dement.service;

import com.dement.dto.response.MriResultResponse;
import com.dement.entity.Caregiver;
import com.dement.entity.MriScan;
import com.dement.entity.Patient;
import com.dement.enums.DementiaStage;
import com.dement.exception.MlServiceException;
import com.dement.exception.ResourceNotFoundException;
import com.dement.repository.MriScanRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MriService {

    private final MriScanRepository mriScanRepository;
    private final CaregiverService caregiverService;
    private final PatientService patientService;
    private final FileStorageService fileStorageService;
    private final RestTemplate restTemplate;

    @Value("${app.ml.service.url}")
    private String mlServiceUrl;

    @Value("${app.ml.service.mri-endpoint}")
    private String mriEndpoint;

    @Transactional
    public MriResultResponse analyzeMriScan(Long caregiverId, Long patientId, MultipartFile file) {
        Caregiver caregiver = caregiverService.findById(caregiverId);
        Patient patient = patientId != null ? patientService.findById(patientId) : null;

        String imagePath = fileStorageService.storeMriImage(file);

        MriScan scan = MriScan.builder()
                .imagePath(imagePath)
                .caregiver(caregiver)
                .patient(patient)
                .processingStatus("PROCESSING")
                .build();

        scan = mriScanRepository.save(scan);

        try {
            Map<String, Object> mlResult = callMlService(imagePath);

            Boolean dementiaDetected = (Boolean) mlResult.getOrDefault("dementia_detected", false);
            String stage = (String) mlResult.getOrDefault("stage", "NON_DEMENTED");
            Double confidence = ((Number) mlResult.getOrDefault("confidence", 0.0)).doubleValue();

            scan.setDementiaDetected(dementiaDetected);
            scan.setDementiaStage(DementiaStage.valueOf(stage.toUpperCase().replace(" ", "_")));
            scan.setConfidenceScore(confidence);
            scan.setMlRawResponse(mlResult.toString());
            scan.setProcessingStatus("COMPLETED");

        } catch (Exception e) {
            log.error("ML service call failed: {}", e.getMessage());
            scan.setProcessingStatus("ML_UNAVAILABLE");
            scan.setDementiaDetected(null);
            scan.setMlRawResponse("ML service unavailable: " + e.getMessage());
        }

        scan = mriScanRepository.save(scan);
        return mapToResponse(scan);
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> callMlService(String imagePath) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            File imageFile = new File(imagePath);
            body.add("file", new FileSystemResource(imageFile));

            HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);
            String url = mlServiceUrl + mriEndpoint;

            ResponseEntity<Map> response = restTemplate.postForEntity(url, requestEntity, Map.class);

            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                return response.getBody();
            }
            throw new MlServiceException("ML service returned empty response");
        } catch (Exception e) {
            throw new MlServiceException("Failed to communicate with ML service: " + e.getMessage(), e);
        }
    }

    public List<MriResultResponse> getScansForCaregiver(Long caregiverId) {
        return mriScanRepository.findByCaregiverIdOrderByCreatedAtDesc(caregiverId)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    public MriResultResponse getScanById(Long scanId) {
        return mapToResponse(mriScanRepository.findById(scanId)
                .orElseThrow(() -> new ResourceNotFoundException("MRI Scan", "id", scanId)));
    }

    private MriResultResponse mapToResponse(MriScan scan) {
        return MriResultResponse.builder()
                .id(scan.getId())
                .imagePath(scan.getImagePath())
                .dementiaDetected(scan.getDementiaDetected())
                .dementiaStage(scan.getDementiaStage())
                .confidenceScore(scan.getConfidenceScore())
                .processingStatus(scan.getProcessingStatus())
                .createdAt(scan.getCreatedAt())
                .build();
    }
}