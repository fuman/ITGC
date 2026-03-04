package com.itgc.portal.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

/**
 * 위험 엔티티
 * COSO 위험평가(Risk Assessment) 구성요소
 */
@Entity
@Table(name = "itgc_risk")
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Risk {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String riskCode;

    @Column(nullable = false, length = 50)
    private String category;  // IT-OPS, IT-SEC, IT-CHG, IT-ACC, IT-BCM, IT-DATA

    @Column(nullable = false, length = 200)
    private String riskName;

    @Column(columnDefinition = "TEXT")
    private String riskDescription;

    @Column(nullable = false)
    private Integer inherentLikelihood;  // 1-5

    @Column(nullable = false)
    private Integer inherentImpact;       // 1-5

    @Column(nullable = false, length = 20)
    private String inherentRisk;          // 심각/높음/중간/낮음/미미

    private Integer residualLikelihood;
    private Integer residualImpact;

    @Column(length = 20)
    private String residualRisk;

    @Column(length = 100)
    private String riskOwner;

    @Column(length = 100)
    private String dept;

    @Column(length = 30)
    private String status;  // 활성/모니터링/수용/완화

    @Column(length = 200)
    private String relatedProcess;

    @CreatedDate
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @Column(length = 100)
    private String createdBy;

    @Column(length = 100)
    private String updatedBy;

    /**
     * 위험 수준 자동 계산
     */
    @PrePersist
    @PreUpdate
    public void calculateRiskLevel() {
        this.inherentRisk = calculateLevel(inherentLikelihood, inherentImpact);
        if (residualLikelihood != null && residualImpact != null) {
            this.residualRisk = calculateLevel(residualLikelihood, residualImpact);
        }
    }

    private String calculateLevel(int likelihood, int impact) {
        int score = likelihood * impact;
        if (score >= 20) return "심각";
        if (score >= 12) return "높음";
        if (score >= 6) return "중간";
        if (score >= 3) return "낮음";
        return "미미";
    }
}
