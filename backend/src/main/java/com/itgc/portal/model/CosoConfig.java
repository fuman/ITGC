package com.itgc.portal.model;

import lombok.*;
import java.time.LocalDateTime;

/**
 * COSO 설정 모델
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class CosoConfig {
    private Long id;
    private String component;         // CE, RA, CA, IC, MA
    private String componentName;
    private Integer weight;           // 가중치 (합계 100)
    private Integer scoreGreen;       // 양호 기준점수
    private Integer scoreYellow;      // 보통 기준점수
    private Integer scoreRed;         // 미흡 기준점수
    private String description;
    private LocalDateTime updatedAt;
    private String updatedBy;
}
