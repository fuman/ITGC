package com.itgc.portal.model;

import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 평가 결과 모델
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class EvaluationResult {
    private Long id;
    private Long evalPlanId;
    private Integer totalSamples;
    private Integer passCount;
    private Integer exceptionCount;
    private Integer notApplicableCount;
    private String conclusion;        // 효과적, 부분효과적, 비효과적
    private String evaluatorOpinion;
    private String reviewerOpinion;
    private String reviewedBy;
    private LocalDate reviewedAt;
    private String approvedBy;
    private LocalDate approvedAt;
    private String status;            // 작성중, 검토중, 승인완료
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
}
