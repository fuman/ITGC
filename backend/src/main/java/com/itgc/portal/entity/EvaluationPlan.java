package com.itgc.portal.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 운영평가 계획 엔티티
 */
@Entity
@Table(name = "itgc_eval_plan")
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EvaluationPlan {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Integer evalYear;

    @Column(nullable = false)
    private Integer evalQuarter;

    @Column(nullable = false, length = 50)
    private String controlCode;

    @Column(nullable = false, length = 200)
    private String controlName;

    @Column(length = 50)
    private String domain;

    @Column(length = 100)
    private String assignee;

    private LocalDate plannedStartDate;
    private LocalDate plannedEndDate;
    private LocalDate actualStartDate;
    private LocalDate actualEndDate;

    private Integer samplingCount;

    @Column(length = 30)
    private String samplingMethod;  // 전수, 확률적, 비통계적, 판단적

    @Column(length = 30)
    private String status;  // 예정, 진행중, 완료, 지연

    @CreatedDate
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;
}
