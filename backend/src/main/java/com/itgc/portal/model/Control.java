package com.itgc.portal.model;

import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 통제 모델 (COSO 통제활동 구성요소)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Control {
    private Long id;
    private String controlCode;
    private String domain;            // 접근통제, 변경관리, IT운영, 업무연속성, 정보보안
    private String controlName;
    private String controlObjective;
    private String controlDescription;
    private String controlType;       // 예방통제, 탐지통제, 교정통제
    private String automation;        // 자동, 수동, 반자동
    private String frequency;         // 상시, 일일, 주간, 월간, 분기, 반기, 연간
    private String controlOwner;
    private String dept;
    private Boolean isKeyControl;
    private Boolean isItdmControl;
    private String effectiveness;     // 효과적, 부분효과적, 비효과적, 미평가
    private String designAdequacy;    // 적합, 미흡, 미평가
    private LocalDate lastTestDate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
    private String updatedBy;
}
