package com.itgc.portal.service;

import com.itgc.portal.entity.Risk;
import com.itgc.portal.repository.RiskRepository;
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

    private final RiskRepository riskRepository;

    public List<Risk> findAll(String category, String level, String dept, String status) {
        return riskRepository.findWithFilters(category, level, dept, status);
    }

    public Risk findById(Long id) {
        return riskRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("위험을 찾을 수 없습니다: " + id));
    }

    @Transactional
    public Risk create(Risk risk) {
        if (riskRepository.existsByRiskCode(risk.getRiskCode())) {
            throw new IllegalArgumentException("이미 사용 중인 위험 코드입니다: " + risk.getRiskCode());
        }
        return riskRepository.save(risk);
    }

    @Transactional
    public Risk update(Long id, Risk risk) {
        Risk existing = findById(id);
        existing.setCategory(risk.getCategory());
        existing.setRiskName(risk.getRiskName());
        existing.setRiskDescription(risk.getRiskDescription());
        existing.setInherentLikelihood(risk.getInherentLikelihood());
        existing.setInherentImpact(risk.getInherentImpact());
        existing.setResidualLikelihood(risk.getResidualLikelihood());
        existing.setResidualImpact(risk.getResidualImpact());
        existing.setRiskOwner(risk.getRiskOwner());
        existing.setDept(risk.getDept());
        existing.setStatus(risk.getStatus());
        return riskRepository.save(existing);
    }

    @Transactional
    public void delete(Long id) {
        riskRepository.deleteById(id);
    }

    public List<Risk> findForMatrix(String type) {
        return riskRepository.findAll();
    }

    public Map<String, Object> getSummary() {
        Map<String, Object> summary = new HashMap<>();
        summary.put("total", riskRepository.count());
        summary.put("critical", riskRepository.countByInherentRisk("심각"));
        summary.put("high", riskRepository.countByInherentRisk("높음"));
        summary.put("medium", riskRepository.countByInherentRisk("중간"));
        summary.put("low", riskRepository.countByInherentRisk("낮음"));
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
            riskRepository.save(risk);
        }
    }
}
