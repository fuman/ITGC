<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">위험 평가</h1>
          <p class="page-subtitle">식별된 위험에 대해 통제 전/후 위험 수준을 평가합니다</p>
        </div>
        <div class="d-flex gap-8">
          <DxButton text="평가 이력" icon="clock" type="normal" />
          <DxButton text="평가 저장" icon="save" type="default" @click="saveAssessment" />
        </div>
      </div>
    </div>

    <!-- Assessment Period -->
    <div class="card" style="margin-bottom: 20px">
      <div class="period-selector">
        <div class="period-item">
          <label class="filter-label">평가 연도</label>
          <DxSelectBox
            v-model:value="assessmentPeriod.year"
            :items="yearOptions"
            width="120"
          />
        </div>
        <div class="period-item">
          <label class="filter-label">평가 분기</label>
          <DxSelectBox
            v-model:value="assessmentPeriod.quarter"
            :items="['1분기', '2분기', '3분기', '4분기']"
            width="120"
          />
        </div>
        <div class="period-item">
          <label class="filter-label">평가자</label>
          <DxTextBox value="김감사" :read-only="true" width="120" />
        </div>
        <div class="period-item">
          <label class="filter-label">평가 상태</label>
          <span class="badge badge-info" style="padding: 7px 14px">진행중</span>
        </div>
      </div>
    </div>

    <!-- Assessment Summary -->
    <div class="stat-cards" style="margin-bottom: 20px">
      <div class="stat-card" v-for="s in assessSummary" :key="s.id">
        <div class="stat-icon" :class="`icon-${s.iconType}`">{{ s.icon }}</div>
        <div class="stat-info">
          <div class="stat-label">{{ s.label }}</div>
          <div class="stat-value">{{ s.value }}</div>
        </div>
      </div>
    </div>

    <!-- Assessment Table -->
    <div class="card" style="padding: 0">
      <DxDataGrid
        :data-source="assessmentData"
        :show-borders="false"
        :hover-state-enabled="true"
        :column-auto-width="true"
        :allow-column-resizing="true"
        :word-wrap-enabled="true"
        key-expr="id"
      >
        <DxEditing mode="cell" :allow-updating="true" />
        <DxToolbar>
          <DxItem location="before" template="titleTemplate" />
          <DxItem name="searchPanel" />
        </DxToolbar>
        <DxSearchPanel :visible="true" placeholder="위험 검색..." />
        <DxPaging :page-size="10" />
        <DxPager :show-info="true" />

        <DxColumn data-field="riskCode" caption="위험 코드" width="130" :allow-editing="false" />
        <DxColumn data-field="riskName" caption="위험명" min-width="180" :allow-editing="false" />
        <DxColumn data-field="category" caption="카테고리" width="110" :allow-editing="false" />

        <!-- 고유 위험 -->
        <DxColumn caption="고유 위험 (통제 전)" :allow-editing="false">
          <DxColumn data-field="inherentLikelihood" caption="발생가능성" width="95" alignment="center" />
          <DxColumn data-field="inherentImpact" caption="영향도" width="80" alignment="center" />
          <DxColumn data-field="inherentRisk" caption="위험수준" width="90" cell-template="riskLevelTemplate" :allow-editing="false" />
        </DxColumn>

        <!-- 잔여 위험 -->
        <DxColumn caption="잔여 위험 (통제 후)">
          <DxColumn
            data-field="residualLikelihood"
            caption="발생가능성"
            width="95"
            alignment="center"
            :editor-options="{ min: 1, max: 5 }"
          />
          <DxColumn
            data-field="residualImpact"
            caption="영향도"
            width="80"
            alignment="center"
            :editor-options="{ min: 1, max: 5 }"
          />
          <DxColumn data-field="residualRisk" caption="위험수준" width="90" cell-template="residualTemplate" :allow-editing="false" />
        </DxColumn>

        <DxColumn data-field="riskTrend" caption="위험 추이" width="90" cell-template="trendTemplate" :allow-editing="false" />
        <DxColumn data-field="assessmentComment" caption="평가 의견" min-width="180" />
        <DxColumn data-field="assessor" caption="평가자" width="90" :allow-editing="false" />

        <template #titleTemplate>
          <div style="font-weight: 600; font-size: 15px; color: #1a3a6b; padding: 4px 0">
            위험 평가 워크시트
          </div>
        </template>
        <template #riskLevelTemplate="{ data }">
          <span class="badge" :class="`badge-${getRiskClass(data.value)}`">{{ data.value }}</span>
        </template>
        <template #residualTemplate="{ data }">
          <span class="badge" :class="`badge-${getRiskClass(data.value)}`">{{ data.value }}</span>
        </template>
        <template #trendTemplate="{ data }">
          <span :class="`trend-${data.value}`">{{ getTrendIcon(data.value) }} {{ data.value }}</span>
        </template>
      </DxDataGrid>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxDataGrid, { DxColumn, DxEditing, DxPaging, DxPager, DxSearchPanel, DxToolbar, DxItem } from 'devextreme-vue/data-grid'
import DxSelectBox from 'devextreme-vue/select-box'
import DxTextBox from 'devextreme-vue/text-box'

const assessmentPeriod = ref({ year: 2026, quarter: '1분기' })
const yearOptions = [2024, 2025, 2026]

const assessSummary = ref([
  { id: 1, icon: '📋', iconType: 'primary', label: '평가 대상', value: '111건' },
  { id: 2, icon: '✓', iconType: 'success', label: '평가 완료', value: '89건' },
  { id: 3, icon: '⏳', iconType: 'warning', label: '평가 중', value: '15건' },
  { id: 4, icon: '○', iconType: 'info', label: '미평가', value: '7건' }
])

function getRiskClass(level) {
  const map = { '심각': 'critical', '높음': 'high', '중간': 'medium', '낮음': 'low', '미미': 'minimal' }
  return map[level] || 'minimal'
}

function getTrendIcon(trend) {
  return { '상승': '▲', '유지': '─', '하락': '▼' }[trend] || '─'
}

function calculateLevel(l, i) {
  const s = l * i
  if (s >= 20) return '심각'
  if (s >= 12) return '높음'
  if (s >= 6) return '중간'
  if (s >= 3) return '낮음'
  return '미미'
}

const assessmentData = ref([
  {
    id: 1, riskCode: 'IT-SEC-001', riskName: '권한 없는 시스템 접근', category: 'IT-SEC',
    inherentLikelihood: 4, inherentImpact: 5, inherentRisk: '심각',
    residualLikelihood: 2, residualImpact: 5, residualRisk: '높음',
    riskTrend: '하락', assessmentComment: '접근통제 강화로 위험 감소', assessor: '김감사'
  },
  {
    id: 2, riskCode: 'IT-CHG-001', riskName: '미승인 시스템 변경', category: 'IT-CHG',
    inherentLikelihood: 3, inherentImpact: 4, inherentRisk: '높음',
    residualLikelihood: 2, residualImpact: 4, residualRisk: '중간',
    riskTrend: '하락', assessmentComment: '변경관리 프로세스 개선 필요', assessor: '김감사'
  },
  {
    id: 3, riskCode: 'IT-OPS-001', riskName: '배치 처리 실패 미탐지', category: 'IT-OPS',
    inherentLikelihood: 3, inherentImpact: 4, inherentRisk: '높음',
    residualLikelihood: 3, residualImpact: 4, residualRisk: '높음',
    riskTrend: '유지', assessmentComment: '모니터링 도구 미비로 잔여 위험 높음', assessor: '김감사'
  },
  {
    id: 4, riskCode: 'IT-ACC-001', riskName: '퇴직자 계정 미삭제', category: 'IT-ACC',
    inherentLikelihood: 4, inherentImpact: 3, inherentRisk: '높음',
    residualLikelihood: 3, residualImpact: 3, residualRisk: '중간',
    riskTrend: '유지', assessmentComment: '계정관리 절차 강화 검토 중', assessor: '김감사'
  },
  {
    id: 5, riskCode: 'IT-BCM-001', riskName: '재해복구 시스템 미검증', category: 'IT-BCM',
    inherentLikelihood: 2, inherentImpact: 5, inherentRisk: '중간',
    residualLikelihood: 2, residualImpact: 5, residualRisk: '중간',
    riskTrend: '유지', assessmentComment: 'DR 테스트 일정 수립 필요', assessor: '박검토'
  }
])

function saveAssessment() {
  console.log('Saving assessment...')
}
</script>

<style lang="scss" scoped>
.period-selector {
  display: flex;
  align-items: flex-end;
  gap: 20px;
  flex-wrap: wrap;
}

.period-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.filter-label {
  font-size: 12px;
  font-weight: 500;
  color: #495057;
}

.trend-상승 { color: #e74c3c; font-weight: 600; }
.trend-유지 { color: #868e96; font-weight: 600; }
.trend-하락 { color: #27ae60; font-weight: 600; }
</style>
