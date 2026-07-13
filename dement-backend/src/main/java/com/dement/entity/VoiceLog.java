// REPLACE src/main/java/com/dement/entity/VoiceLog.java
package com.dement.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "voice_logs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VoiceLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "prompt_text", columnDefinition = "TEXT")
    private String promptText;

    @Column(name = "patient_response", columnDefinition = "TEXT")
    private String patientResponse;

    @Column(name = "response_type")
    private String responseType;   // SPOKEN, SILENT, MOOD_TAP

    @Column(name = "is_sos_triggered")
    private boolean sosTriggered = false;

    @Column(name = "is_distress_detected")
    private boolean distressDetected = false;

    @Column(name = "distress_keyword")
    private String distressKeyword;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @CreationTimestamp
    @Column(name = "logged_at", updatable = false)
    private LocalDateTime loggedAt;
}