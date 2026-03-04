package com.itgc.portal.model;

import lombok.*;
import java.time.LocalDateTime;

/**
 * 조직 모델 (그룹사/부서)
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Organization {
    private Long id;
    private String orgCode;
    private String orgName;
    private String orgType;           // 그룹사, 본부, 팀
    private Long parentId;
    private String parentName;
    private Integer sortOrder;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
