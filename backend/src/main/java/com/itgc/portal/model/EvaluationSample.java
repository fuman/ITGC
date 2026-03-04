package com.itgc.portal.model;

import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 평가 샘플 모델
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class EvaluationSample {
    private Long id;
    private Long evalPlanId;
    private String sampleNo;
    private String transactionId;
    private LocalDate transactionDate;
    private String description;
    private String evidenceFile;
    private String testResult;        // 통과, 예외, 미적용
    private String exceptionReason;
    private String tester;
    private LocalDate testDate;
    private String remarks;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
