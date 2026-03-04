<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">위험-통제 매핑</h1>
          <p class="page-subtitle">위험과 통제 활동 간의 연관 관계를 관리합니다</p>
        </div>
        <div class="d-flex gap-8">
          <DxButton text="매핑 추가" icon="plus" type="default" @click="showDialog = true" />
        </div>
      </div>
    </div>

    <!-- Coverage Stats -->
    <div class="stat-cards" style="margin-bottom: 20px">
      <div class="stat-card">
        <div class="stat-icon icon-primary">🔗</div>
        <div class="stat-info">
          <div class="stat-label">총 매핑 건수</div>
          <div class="stat-value">186</div>
          <div class="stat-change neutral">위험-통제 연결</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon icon-success">✓</div>
        <div class="stat-info">
          <div class="stat-label">통제 적용 위험</div>
          <div class="stat-value">98</div>
          <div class="stat-change neutral">88.3% 커버리지</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon icon-danger">⚠</div>
        <div class="stat-info">
          <div class="stat-label">미통제 위험</div>
          <div class="stat-value">13</div>
          <div class="stat-change up">조치 필요</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon icon-warning">🔍</div>
        <div class="stat-info">
          <div class="stat-label">평균 통제 수/위험</div>
          <div class="stat-value">1.9</div>
          <div class="stat-change neutral">개/위험</div>
        </div>
      </div>
    </div>

    <!-- Mapping Grid -->
    <div class="card" style="padding: 0">
      <DxDataGrid
        :data-source="mappingData"
        :show-borders="false"
        :hover-state-enabled="true"
        :column-auto-width="true"
        :allow-column-resizing="true"
        :row-alternation-enabled="true"
      >
        <DxToolbar>
          <DxItem location="before" template="titleTemplate" />
          <DxItem name="searchPanel" />
        </DxToolbar>
        <DxSearchPanel :visible="true" placeholder="검색..." />
        <DxPaging :page-size="15" />
        <DxPager :show-info="true" />

        <DxColumn data-field="riskCode" caption="위험 코드" width="130" />
        <DxColumn data-field="riskName" caption="위험명" min-width="180" />
        <DxColumn data-field="riskLevel" caption="위험 수준" width="100" cell-template="riskTemplate" />
        <DxColumn data-field="controlCode" caption="통제 코드" width="130" />
        <DxColumn data-field="controlName" caption="통제명" min-width="180" />
        <DxColumn data-field="mappingType" caption="매핑 유형" width="100" cell-template="mappingTemplate" />
        <DxColumn data-field="coverageRatio" caption="위험 경감율" width="110" alignment="center" cell-template="coverageTemplate" />
        <DxColumn data-field="isKeyMapping" caption="핵심 매핑" width="90" alignment="center" cell-template="keyTemplate" />

        <template #titleTemplate>
          <div style="font-weight: 600; font-size: 15px; color: #1a3a6b; padding: 4px 0">
            위험-통제 매핑 현황
          </div>
        </template>
        <template #riskTemplate="{ data }">
          <span class="badge" :class="`badge-${getRiskClass(data.value)}`">{{ data.value }}</span>
        </template>
        <template #mappingTemplate="{ data }">
          <span class="badge badge-info">{{ data.value }}</span>
        </template>
        <template #coverageTemplate="{ data }">
          <div style="display: flex; align-items: center; gap: 6px">
            <div class="progress-bar" style="flex: 1">
              <div class="progress-fill fill-primary" :style="{ width: data.value + '%' }"></div>
            </div>
            <span style="font-size: 12px; min-width: 35px">{{ data.value }}%</span>
          </div>
        </template>
        <template #keyTemplate="{ data }">
          <span :style="{ color: data.value ? '#27ae60' : '#adb5bd', fontWeight: '600' }">
            {{ data.value ? '★ 핵심' : '-' }}
          </span>
        </template>
      </DxDataGrid>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxDataGrid, { DxColumn, DxPaging, DxPager, DxSearchPanel, DxToolbar, DxItem } from 'devextreme-vue/data-grid'

const showDialog = ref(false)

const mappingData = ref([
  { id: 1, riskCode: 'IT-SEC-001', riskName: '권한 없는 시스템 접근', riskLevel: '심각', controlCode: 'CTRL-ACC-001', controlName: '사용자 계정 등록/변경/삭제 승인', mappingType: '직접', coverageRatio: 70, isKeyMapping: true },
  { id: 2, riskCode: 'IT-SEC-001', riskName: '권한 없는 시스템 접근', riskLevel: '심각', controlCode: 'CTRL-ACC-002', controlName: '특권 계정 반기 재검토', mappingType: '직접', coverageRatio: 20, isKeyMapping: false },
  { id: 3, riskCode: 'IT-CHG-001', riskName: '미승인 시스템 변경', riskLevel: '높음', controlCode: 'CTRL-CHG-001', controlName: '변경 요청 및 승인 관리', mappingType: '직접', coverageRatio: 80, isKeyMapping: true },
  { id: 4, riskCode: 'IT-CHG-001', riskName: '미승인 시스템 변경', riskLevel: '높음', controlCode: 'CTRL-CHG-002', controlName: '변경 후 테스트 및 검증', mappingType: '지원', coverageRatio: 40, isKeyMapping: false },
  { id: 5, riskCode: 'IT-OPS-001', riskName: '배치 처리 실패 미탐지', riskLevel: '높음', controlCode: 'CTRL-OPS-001', controlName: '배치 작업 모니터링', mappingType: '직접', coverageRatio: 85, isKeyMapping: true },
  { id: 6, riskCode: 'IT-BCM-001', riskName: '재해복구 시스템 미검증', riskLevel: '중간', controlCode: 'CTRL-BCM-001', controlName: 'DR 테스트 실시', mappingType: '직접', coverageRatio: 90, isKeyMapping: true }
])

function getRiskClass(level) {
  const map = { '심각': 'critical', '높음': 'high', '중간': 'medium', '낮음': 'low', '미미': 'minimal' }
  return map[level] || 'minimal'
}
</script>
