package com.itgc.portal.service;

import com.itgc.portal.entity.Finding;
import com.itgc.portal.repository.FindingRepository;
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

    private final FindingRepository findingRepository;

    public List<Finding> findAll(String severity, String status, String dept, String type) {
        return findingRepository.findWithFilters(severity, status, dept, type);
    }

    public Finding findById(Long id) {
        return findingRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("발견사항을 찾을 수 없습니다: " + id));
    }

    @Transactional
    public Finding create(Finding finding) {
        if (finding.getFindingNo() == null) {
            finding.setFindingNo(generateFindingNo());
        }
        return findingRepository.save(finding);
    }

    @Transactional
    public Finding update(Long id, Finding finding) {
        Finding existing = findById(id);
        existing.setTitle(finding.getTitle());
        existing.setDescription(finding.getDescription());
        existing.setSeverity(finding.getSeverity());
        existing.setOwner(finding.getOwner());
        existing.setDueDate(finding.getDueDate());
        existing.setStatus(finding.getStatus());
        existing.setRemediationPlan(finding.getRemediationPlan());
        existing.setRemediationProgress(finding.getRemediationProgress());
        return findingRepository.save(existing);
    }

    @Transactional
    public void delete(Long id) {
        findingRepository.deleteById(id);
    }

    public Map<String, Object> getSummary() {
        Map<String, Object> summary = new HashMap<>();
        summary.put("total", findingRepository.count());
        summary.put("open", findingRepository.countByStatus("미결"));
        summary.put("inProgress", findingRepository.countByStatus("조치중"));
        summary.put("completed", findingRepository.countByStatus("조치완료"));
        summary.put("overdue", findingRepository.countByStatusAndDueDateBefore("미결", LocalDate.now()));
        return summary;
    }

    public List<Finding> findOverdue() {
        return findingRepository.findOverdue(LocalDate.now());
    }

    @Transactional
    public Finding updateRemediation(Long id, Map<String, Object> data) {
        Finding finding = findById(id);
        if (data.containsKey("remediationProgress")) {
            finding.setRemediationProgress(Integer.parseInt(data.get("remediationProgress").toString()));
        }
        if (data.containsKey("status")) {
            finding.setStatus(data.get("status").toString());
        }
        if (data.containsKey("remediationPlan")) {
            finding.setRemediationPlan(data.get("remediationPlan").toString());
        }
        return findingRepository.save(finding);
    }

    private String generateFindingNo() {
        int year = LocalDate.now().getYear();
        long count = findingRepository.count() + 1;
        return String.format("FND-%d-%03d", year, count);
    }
}
