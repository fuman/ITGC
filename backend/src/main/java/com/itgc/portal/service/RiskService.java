package com.itgc.portal.service;

import com.itgc.portal.mapper.RiskMapper;
import com.itgc.portal.model.Risk;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class RiskService {

    private final RiskMapper riskMapper;

    public List<Risk> findAll(String category, String level, String dept, String status) {
        return riskMapper.findAll(category, level, dept, status);
    }

    public Risk findById(Long id) {
        Risk risk = riskMapper.findById(id);
        if (risk == null) throw new NoSuchElementException("위험을 찾을 수 없습니다: " + id);
        return risk;
    }

    @Transactional
    public Risk create(Risk risk) {
        if (riskMapper.countByRiskCode(risk.getRiskCode()) > 0) {
            throw new IllegalArgumentException("이미 사용 중인 위험 코드입니다: " + risk.getRiskCode());
        }
        riskMapper.insert(risk);
        return riskMapper.findById(risk.getId());
    }

    @Transactional
    public Risk update(Long id, Risk risk) {
        findById(id);
        risk.setId(id);
        riskMapper.update(risk);
        return riskMapper.findById(id);
    }

    @Transactional
    public void delete(Long id) {
        findById(id);
        riskMapper.delete(id);
    }

    public List<Risk> findForMatrix(String type) {
        return riskMapper.findForMatrix(type);
    }

    public Map<String, Object> getSummary() {
        Map<String, Object> summary = new HashMap<>();
        summary.put("total", riskMapper.count());
        summary.put("critical", riskMapper.countByInherentRisk("심각"));
        summary.put("high", riskMapper.countByInherentRisk("높음"));
        summary.put("medium", riskMapper.countByInherentRisk("중간"));
        summary.put("low", riskMapper.countByInherentRisk("낮음"));
        summary.put("byCategory", riskMapper.getSummaryByCategory());
        return summary;
    }

    @Transactional
    public void saveAssessment(List<Map<String, Object>> assessments) {
        for (Map<String, Object> assessment : assessments) {
            Long riskId = Long.parseLong(assessment.get("id").toString());
            Risk risk = findById(riskId);
            if (assessment.containsKey("residualLikelihood")) {
                risk.setResidualLikelihood(Integer.parseInt(assessment.get("residualLikelihood").toString()));
            }
            if (assessment.containsKey("residualImpact")) {
                risk.setResidualImpact(Integer.parseInt(assessment.get("residualImpact").toString()));
            }
            riskMapper.update(risk);
        }
    }
}
