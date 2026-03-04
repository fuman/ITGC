package com.itgc.portal.model;

import lombok.*;
import java.time.LocalDateTime;

/**
 * 위험-통제 매핑 모델
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class RiskControlMapping {
    private Long id;
    private Long riskId;
    private String riskCode;
    private String riskName;
    private Long controlId;
    private String controlCode;
    private String controlName;
    private String mappingType;       // 주요, 보완
    private String remarks;
    private LocalDateTime createdAt;
    private String createdBy;
}
