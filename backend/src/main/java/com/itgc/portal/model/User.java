package com.itgc.portal.model;

import lombok.*;
import java.time.LocalDateTime;

/**
 * 사용자 모델
 */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class User {
    private Long id;
    private String userId;
    private String username;
    private String password;
    private String email;
    private String phone;
    private Long orgId;
    private String orgName;
    private String role;              // ADMIN, MANAGER, EVALUATOR, VIEWER
    private Boolean isActive;
    private LocalDateTime lastLoginAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
