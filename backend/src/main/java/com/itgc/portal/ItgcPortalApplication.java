package com.itgc.portal;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

/**
 * ITGC 포털 - 그룹사 IT 일반통제 관리 시스템
 * COSO 2013 Framework 기반 위험관리 및 운영평가 플랫폼
 */
@SpringBootApplication
@EnableJpaAuditing
public class ItgcPortalApplication {
    public static void main(String[] args) {
        SpringApplication.run(ItgcPortalApplication.class, args);
    }
}
