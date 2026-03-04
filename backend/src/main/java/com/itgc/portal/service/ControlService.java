package com.itgc.portal.service;

import com.itgc.portal.mapper.ControlMapper;
import com.itgc.portal.model.Control;
import com.itgc.portal.model.RiskControlMapping;
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

    private final ControlMapper controlMapper;

    public List<Control> findAll(String domain, String type, String automation, String effectiveness) {
        return controlMapper.findAll(domain, type, automation, effectiveness);
    }

    public Control findById(Long id) {
        Control control = controlMapper.findById(id);
        if (control == null) throw new NoSuchElementException("통제를 찾을 수 없습니다: " + id);
        return control;
    }

    @Transactional
    public Control create(Control control) {
        controlMapper.insert(control);
        return controlMapper.findById(control.getId());
    }

    @Transactional
    public Control update(Long id, Control control) {
        findById(id);
        control.setId(id);
        controlMapper.update(control);
        return controlMapper.findById(id);
    }

    @Transactional
    public void delete(Long id) {
        findById(id);
        controlMapper.delete(id);
    }

    public List<RiskControlMapping> getMapping() {
        return controlMapper.findControlRiskMapping();
    }

    @Transactional
    public void addMapping(RiskControlMapping mapping) {
        controlMapper.insertMapping(mapping);
    }

    @Transactional
    public void deleteMapping(Long id) {
        controlMapper.deleteMapping(id);
    }

    @Transactional
    public void saveDesignEvaluation(List<Map<String, Object>> evaluations) {
        for (Map<String, Object> eval : evaluations) {
            Long controlId = Long.parseLong(eval.get("id").toString());
            String designAdequacy = eval.get("designAdequacy").toString();
            controlMapper.updateDesignAdequacy(controlId, designAdequacy);
        }
    }

    public List<Map<String, Object>> getDomainSummary() {
        return controlMapper.getDomainSummary();
    }
}
