package com.dement.entity;

import com.dement.enums.DementiaStage;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "mri_scans")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MriScan {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "image_path", nullable = false)
    private String imagePath;

    @Column(name = "dementia_detected")
    private Boolean dementiaDetected;

    @Enumerated(EnumType.STRING)
    @Column(name = "dementia_stage")
    private DementiaStage dementiaStage;

    @Column(name = "confidence_score")
    private Double confidenceScore;

    @Column(name = "ml_raw_response", columnDefinition = "TEXT")
    private String mlRawResponse;

    @Column(name = "processing_status")
    private String processingStatus = "PENDING";

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "caregiver_id", nullable = false)
    private Caregiver caregiver;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id")
    private Patient patient;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}