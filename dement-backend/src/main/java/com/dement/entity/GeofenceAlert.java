package com.dement.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "geofence_alerts")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GeofenceAlert {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    @JsonIgnore
    private Patient patient;

    @Column(name = "patient_latitude")
    private Double patientLatitude;

    @Column(name = "patient_longitude")
    private Double patientLongitude;

    @Column(name = "distance_from_zone")
    private Double distanceFromZone;

    @Column(name = "is_resolved")
    private boolean resolved = false;

    @CreationTimestamp
    @Column(name = "triggered_at", updatable = false)
    private LocalDateTime triggeredAt;

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;

    @Column(name = "last_location_update")
    private LocalDateTime lastLocationUpdate;

    @Builder.Default
    @Column(name = "is_active", nullable = false)
    private Boolean active = true;
}