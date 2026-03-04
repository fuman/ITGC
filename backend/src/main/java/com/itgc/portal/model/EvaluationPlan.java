package com.itgc.portal.model;

import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 운영평가 계획 모델
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class EvaluationPlan {
    private Long id;
    private Integer evalYear;
    private Integer evalQuarter;
    private Long controlId;
    private String controlCode;
    private String controlName;
    private String domain;
    private String assignee;
    private LocalDate plannedStartDate;
    private LocalDate plannedEndDate;
    private LocalDate actualStartDate;
    private LocalDate actualEndDate;
    private Integer samplingCount;
    private String samplingMethod;    // 전수, 확률적, 비통계적, 판단적
    private String status;            // 예정, 진행중, 완료, 지연
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
}
