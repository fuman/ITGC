package com.itgc.portal.controller;

import com.itgc.portal.common.ApiResponse;
import com.itgc.portal.mapper.CosoConfigMapper;
import com.itgc.portal.model.CosoConfig;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * COSO 설정 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/v1/coso-config")
@RequiredArgsConstructor
@CrossOrigin(origins = "${cors.allowed-origins}")
public class CosoConfigController {

    private final CosoConfigMapper cosoConfigMapper;

    @GetMapping
    public ResponseEntity<ApiResponse<List<CosoConfig>>> getCosoConfig() {
        return ResponseEntity.ok(ApiResponse.success(cosoConfigMapper.findAll()));
    }

    @PutMapping("/{component}")
    @Transactional
    public ResponseEntity<ApiResponse<CosoConfig>> updateCosoConfig(
            @PathVariable String component, @RequestBody CosoConfig config
    ) {
        config.setComponent(component);
        cosoConfigMapper.update(config);
        return ResponseEntity.ok(ApiResponse.success(cosoConfigMapper.findByComponent(component)));
    }
}
