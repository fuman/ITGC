package com.itgc.portal.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 발견사항 엔티티
 * COSO 모니터링(Monitoring Activities) 구성요소
 */
@Entity
@Table(name = "itgc_finding")
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Finding {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String findingNo;

    @Column(nullable = false, length = 50)
    private String findingType;  // 운영평가, 내부감사, 외부감사, 자체점검

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(length = 50)
    private String relatedControl;  // 관련 통제 코드

    @Column(length = 50)
    private String relatedRisk;     // 관련 위험 코드

    @Column(nullable = false, length = 20)
    private String severity;  // 심각, 높음, 중간, 낮음

    @Column(length = 100)
    private String dept;

    @Column(length = 100)
    private String owner;

    @Column(columnDefinition = "TEXT")
    private String riskImpact;

    @Column(columnDefinition = "TEXT")
    private String rootCause;

    @Column(columnDefinition = "TEXT")
    private String recommendation;

    private LocalDate discoveryDate;
    private LocalDate dueDate;
    private LocalDate completionDate;

    @Column(length = 30)
    private String status;  // 미결, 조치중, 조치완료, 기한초과, 수용

    private Integer remediationProgress;  // 0-100

    @Column(columnDefinition = "TEXT")
    private String remediationPlan;

    @CreatedDate
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @Column(length = 100)
    private String createdBy;
}
