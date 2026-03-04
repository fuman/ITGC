package com.itgc.portal.service;

import com.itgc.portal.entity.Control;
import com.itgc.portal.repository.ControlRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ControlService {

    private final ControlRepository controlRepository;

    public List<Control> findAll(String domain, String type, String automation, String effectiveness) {
        return controlRepository.findWithFilters(domain, type, automation, effectiveness);
    }

    public Control findById(Long id) {
        return controlRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("통제를 찾을 수 없습니다: " + id));
    }

    @Transactional
    public Control create(Control control) {
        return controlRepository.save(control);
    }

    @Transactional
    public Control update(Long id, Control control) {
        Control existing = findById(id);
        existing.setDomain(control.getDomain());
        existing.setControlName(control.getControlName());
        existing.setControlObjective(control.getControlObjective());
        existing.setControlDescription(control.getControlDescription());
        existing.setControlType(control.getControlType());
        existing.setAutomation(control.getAutomation());
        existing.setFrequency(control.getFrequency());
        existing.setControlOwner(control.getControlOwner());
        existing.setDept(control.getDept());
        return controlRepository.save(existing);
    }

    @Transactional
    public void delete(Long id) {
        controlRepository.deleteById(id);
    }

    public List<Map<String, Object>> getMapping() {
        return controlRepository.findControlRiskMapping();
    }

    @Transactional
    public void saveDesignEvaluation(List<Map<String, Object>> evaluations) {
        for (Map<String, Object> eval : evaluations) {
            Long controlId = Long.parseLong(eval.get("id").toString());
            Control control = findById(controlId);
            if (eval.containsKey("designAdequacy")) {
                control.setDesignAdequacy(eval.get("designAdequacy").toString());
            }
            controlRepository.save(control);
        }
    }

    public List<Map<String, Object>> getDomainSummary() {
        return controlRepository.findDomainSummary();
    }
}
