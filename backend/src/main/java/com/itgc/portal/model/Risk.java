package com.itgc.portal.model;

import lombok.*;
import java.time.LocalDateTime;

/**
 * 위험 모델 (COSO 위험평가 구성요소)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Risk {
    private Long id;
    private String riskCode;
    private String category;          // IT-OPS, IT-SEC, IT-CHG, IT-ACC, IT-BCM, IT-DATA
    private String riskName;
    private String riskDescription;
    private Integer inherentLikelihood;  // 1-5
    private Integer inherentImpact;      // 1-5
    private Integer inherentScore;       // DB generated (likelihood*impact)
    private String inherentRisk;         // 심각/높음/중간/낮음/미미
    private Integer residualLikelihood;
    private Integer residualImpact;
    private Integer residualScore;
    private String residualRisk;
    private String riskOwner;
    private String dept;
    private String status;               // 활성/모니터링/수용/완화
    private String relatedProcess;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
    private String updatedBy;
}
