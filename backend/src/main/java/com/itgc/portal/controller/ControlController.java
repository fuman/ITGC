package com.itgc.portal.controller;

import com.itgc.portal.common.ApiResponse;
import com.itgc.portal.entity.Control;
import com.itgc.portal.service.ControlService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 통제 활동 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/v1/controls")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "${cors.allowed-origins}")
public class ControlController {

    private final ControlService controlService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<Control>>> getControls(
            @RequestParam(required = false) String domain,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String automation,
            @RequestParam(required = false) String effectiveness
    ) {
        List<Control> controls = controlService.findAll(domain, type, automation, effectiveness);
        return ResponseEntity.ok(ApiResponse.success(controls, controls.size()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Control>> getControl(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(controlService.findById(id)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Control>> createControl(@RequestBody Control control) {
        return ResponseEntity.ok(ApiResponse.success(controlService.create(control)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Control>> updateControl(@PathVariable Long id, @RequestBody Control control) {
        return ResponseEntity.ok(ApiResponse.success(controlService.update(id, control)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteControl(@PathVariable Long id) {
        controlService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    /**
     * 위험-통제 매핑 조회
     */
    @GetMapping("/mapping")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getControlMapping() {
        return ResponseEntity.ok(ApiResponse.success(controlService.getMapping()));
    }

    /**
     * 통제 설계 평가 저장
     */
    @PostMapping("/design-evaluation")
    public ResponseEntity<ApiResponse<Void>> saveDesignEvaluation(
            @RequestBody List<Map<String, Object>> evaluations
    ) {
        controlService.saveDesignEvaluation(evaluations);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    /**
     * 도메인별 통제 현황 요약
     */
    @GetMapping("/summary/domain")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getDomainSummary() {
        return ResponseEntity.ok(ApiResponse.success(controlService.getDomainSummary()));
    }
}
