package com.itgc.portal.model;

import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 발견사항 모델 (COSO 모니터링 구성요소)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Finding {
    private Long id;
    private String findingNo;
    private String findingType;       // 운영평가, 내부감사, 외부감사, 자체점검
    private String title;
    private String description;
    private Long controlId;
    private Long riskId;
    private String severity;          // 심각, 높음, 중간, 낮음
    private String dept;
    private String owner;
    private String riskImpact;
    private String rootCause;
    private String recommendation;
    private LocalDate discoveryDate;
    private LocalDate dueDate;
    private LocalDate completionDate;
    private String status;            // 미결, 조치중, 조치완료, 기한초과, 수용
    private Integer remediationProgress;  // 0-100
    private String remediationPlan;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
    private String updatedBy;
}
