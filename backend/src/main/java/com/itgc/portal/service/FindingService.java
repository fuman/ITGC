package com.itgc.portal.service;

import com.itgc.portal.mapper.FindingMapper;
import com.itgc.portal.model.Finding;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FindingService {

    private final FindingMapper findingMapper;

    public List<Finding> findAll(String severity, String status, String dept, String type) {
        return findingMapper.findAll(severity, status, dept, type);
    }

    public Finding findById(Long id) {
        Finding finding = findingMapper.findById(id);
        if (finding == null) throw new NoSuchElementException("발견사항을 찾을 수 없습니다: " + id);
        return finding;
    }

    @Transactional
    public Finding create(Finding finding) {
        if (finding.getFindingNo() == null) {
            finding.setFindingNo(generateFindingNo());
        }
        findingMapper.insert(finding);
        return findingMapper.findById(finding.getId());
    }

    @Transactional
    public Finding update(Long id, Finding finding) {
        findById(id);
        finding.setId(id);
        findingMapper.update(finding);
        return findingMapper.findById(id);
    }

    @Transactional
    public void delete(Long id) {
        findById(id);
        findingMapper.delete(id);
    }

    public Map<String, Object> getSummary() {
        Map<String, Object> summary = new HashMap<>();
        summary.put("total", findingMapper.count());
        summary.put("open", findingMapper.countByStatus("미결"));
        summary.put("inProgress", findingMapper.countByStatus("조치중"));
        summary.put("completed", findingMapper.countByStatus("조치완료"));
        summary.put("overdue", findingMapper.countOverdue(LocalDate.now()));
        summary.put("bySeverity", findingMapper.getSummaryBySeverity());
        return summary;
    }

    public List<Finding> findOverdue() {
        return findingMapper.findOverdue(LocalDate.now());
    }

    @Transactional
    public Finding updateRemediation(Long id, Map<String, Object> data) {
        findById(id);
        String status = data.containsKey("status") ? data.get("status").toString() : null;
        Integer progress = data.containsKey("remediationProgress")
                ? Integer.parseInt(data.get("remediationProgress").toString()) : null;
        String plan = data.containsKey("remediationPlan") ? data.get("remediationPlan").toString() : null;
        findingMapper.updateRemediation(id, status, progress, plan);
        return findingMapper.findById(id);
    }

    private String generateFindingNo() {
        int year = LocalDate.now().getYear();
        long count = findingMapper.count() + 1;
        return String.format("FND-%d-%03d", year, count);
    }
}
