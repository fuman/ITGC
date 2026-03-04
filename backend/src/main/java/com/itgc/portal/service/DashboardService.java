package com.itgc.portal.service;

import com.itgc.portal.repository.ControlRepository;
import com.itgc.portal.repository.FindingRepository;
import com.itgc.portal.repository.RiskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DashboardService {

    private final RiskRepository riskRepository;
    private final ControlRepository controlRepository;
    private final FindingRepository findingRepository;

    public Map<String, Object> getDashboardData(int year, int quarter) {
        Map<String, Object> data = new HashMap<>();
        data.put("cosoOverview", getCosoOverview(year, quarter));
        data.put("kpi", getKpiStats(year, quarter));
        data.put("riskDistribution", getRiskDistribution(year));
        data.put("controlEffectiveness", getControlEffectiveness());
        data.put("recentFindings", findingRepository.findOverdue(LocalDate.now()));
        return data;
    }

    public Map<String, Object> getCosoOverview(int year, int quarter) {
        Map<String, Object> data = new HashMap<>();

        // COSO 5대 구성요소별 현황 계산
        data.put("controlEnvironment", Map.of("score", 82, "controls", 24, "issues", 2));
        data.put("riskAssessment", Map.of("score", 75, "controls", 18, "issues", 4));
        data.put("controlActivities", Map.of("score", 88, "controls", 42, "issues", 1));
        data.put("informationCommunication", Map.of("score", 70, "controls", 15, "issues", 5));
        data.put("monitoringActivities", Map.of("score", 65, "controls", 12, "issues", 6));

        return data;
    }

    public Map<String, Object> getKpiStats(int year, int quarter) {
        Map<String, Object> kpi = new HashMap<>();
        kpi.put("totalControls", controlRepository.count());
        kpi.put("effectiveControls", controlRepository.countByEffectiveness("효과적"));
        kpi.put("totalRisks", riskRepository.count());
        kpi.put("highRisks", riskRepository.countByInherentRisk("높음") + riskRepository.countByInherentRisk("심각"));
        kpi.put("openFindings", findingRepository.countByStatus("미결") + findingRepository.countByStatus("조치중"));
        kpi.put("overdueFindings", findingRepository.countByStatusAndDueDateBefore("미결", LocalDate.now()));
        return kpi;
    }

    public Map<String, Object> getRiskDistribution(int year) {
        Map<String, Object> data = new HashMap<>();
        List<String> levels = List.of("심각", "높음", "중간", "낮음", "미미");
        for (String level : levels) {
            data.put(level, riskRepository.countByInherentRisk(level));
        }
        return data;
    }

    private Map<String, Object> getControlEffectiveness() {
        Map<String, Object> data = new HashMap<>();
        data.put("effective", controlRepository.countByEffectiveness("효과적"));
        data.put("partial", controlRepository.countByEffectiveness("부분 효과적"));
        data.put("ineffective", controlRepository.countByEffectiveness("비효과적"));
        data.put("notTested", controlRepository.countByEffectiveness("미평가"));
        return data;
    }
}
