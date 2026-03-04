package com.itgc.portal.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 통제 엔티티
 * COSO 통제활동(Control Activities) 구성요소
 */
@Entity
@Table(name = "itgc_control")
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Control {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String controlCode;

    @Column(nullable = false, length = 50)
    private String domain;  // 접근통제, 변경관리, IT운영, 업무연속성, 정보보안

    @Column(nullable = false, length = 200)
    private String controlName;

    @Column(columnDefinition = "TEXT")
    private String controlObjective;

    @Column(columnDefinition = "TEXT")
    private String controlDescription;

    @Column(length = 30)
    private String controlType;  // 예방통제, 탐지통제, 교정통제

    @Column(length = 20)
    private String automation;  // 자동, 수동, 반자동

    @Column(length = 20)
    private String frequency;  // 상시, 일일, 주간, 월간, 분기, 반기, 연간

    @Column(length = 100)
    private String controlOwner;

    @Column(length = 100)
    private String dept;

    private Boolean isKeyControl;    // 핵심 통제 여부
    private Boolean isItdmControl;   // ITDM 통제 여부

    @Column(length = 30)
    private String effectiveness;  // 효과적, 부분효과적, 비효과적, 미평가

    @Column(length = 30)
    private String designAdequacy; // 설계 적합성

    private LocalDate lastTestDate;

    @CreatedDate
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;
}
