<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">위험 매트릭스</h1>
          <p class="page-subtitle">발생 가능성과 영향도 기준의 5×5 위험 매트릭스</p>
        </div>
        <div class="d-flex gap-8">
          <DxButton text="이미지 저장" icon="image" type="normal" />
          <DxButton text="보고서 출력" icon="print" type="default" />
        </div>
      </div>
    </div>

    <!-- Risk Matrix & Legend -->
    <div class="grid-2" style="margin-bottom: 24px">
      <!-- Matrix -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">위험 매트릭스 (5×5)</div>
          <div class="d-flex gap-8">
            <span class="badge badge-primary">고유 위험</span>
            <DxSelectBox
              v-model:value="matrixView"
              :items="['고유 위험', '잔여 위험']"
              width="120"
            />
          </div>
        </div>
        <div class="matrix-container">
          <div class="matrix-y-label">발생 가능성 →</div>
          <div class="matrix-grid">
            <!-- Header row: Impact labels -->
            <div class="matrix-header-cell corner">발생<br/>가능성 \ 영향도</div>
            <div v-for="imp in impacts" :key="imp.val" class="matrix-header-cell">
              {{ imp.label }}<br/><small>{{ imp.val }}</small>
            </div>

            <!-- Matrix rows -->
            <template v-for="lik in likelihoods" :key="lik.val">
              <div class="matrix-row-header">{{ lik.label }}<br/><small>{{ lik.val }}</small></div>
              <div
                v-for="imp in impacts"
                :key="`${lik.val}-${imp.val}`"
                class="matrix-cell"
                :class="getCellClass(lik.val, imp.val)"
                @click="selectCell(lik.val, imp.val)"
                :title="`발생가능성 ${lik.val} × 영향도 ${imp.val} = ${lik.val * imp.val}`"
              >
                <div class="cell-score">{{ lik.val * imp.val }}</div>
                <div class="cell-risks">
                  <span
                    v-for="risk in getRisksInCell(lik.val, imp.val)"
                    :key="risk.id"
                    class="risk-dot"
                    :title="risk.riskCode + ': ' + risk.riskName"
                  >●</span>
                </div>
              </div>
            </template>
          </div>

          <!-- Legend -->
          <div class="matrix-legend">
            <div v-for="leg in legendItems" :key="leg.label" class="legend-item">
              <div class="legend-color" :style="{ background: leg.color }"></div>
              <span>{{ leg.label }} ({{ leg.range }})</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Selected Cell Risks -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">
            {{ selectedCell ? `선택 셀: ${selectedCell.label}` : '위험 목록' }}
          </div>
          <span v-if="selectedCell" class="badge" :class="`badge-${selectedCell.riskClass}`">
            {{ selectedCell.riskLevel }}
          </span>
        </div>

        <div class="risk-matrix-list">
          <div
            v-for="risk in displayRisks"
            :key="risk.id"
            class="matrix-risk-item"
            :class="`risk-${getRiskClass(risk.inherentRisk)}`"
          >
            <div class="matrix-risk-header">
              <span class="badge" :class="`badge-${getRiskClass(risk.inherentRisk)}`">
                {{ risk.inherentRisk }}
              </span>
              <code>{{ risk.riskCode }}</code>
            </div>
            <div class="matrix-risk-name">{{ risk.riskName }}</div>
            <div class="matrix-risk-meta">
              <span>{{ risk.dept }}</span>
              <span>{{ risk.riskOwner }}</span>
            </div>
          </div>
        </div>

        <!-- Risk Summary by Level -->
        <div class="risk-summary">
          <div class="summary-title">위험 수준별 현황</div>
          <div v-for="item in riskSummary" :key="item.level" class="summary-item">
            <span class="badge" :class="`badge-${getRiskClass(item.level)}`">{{ item.level }}</span>
            <div class="summary-bar">
              <div class="progress-bar">
                <div
                  class="progress-fill"
                  :class="`fill-${getProgressClass(item.level)}`"
                  :style="{ width: `${(item.count / totalRisks) * 100}%` }"
                ></div>
              </div>
            </div>
            <span class="summary-count">{{ item.count }}건</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Scatter Chart -->
    <div class="card">
      <div class="card-header">
        <div class="card-title">위험 분포 산포도</div>
        <span class="text-muted" style="font-size: 12px">버블 크기: 관련 통제 수</span>
      </div>
      <DxChart :data-source="scatterData">
        <DxSeries
          type="bubble"
          argument-field="inherentLikelihood"
          value-field="inherentImpact"
          size-field="controlCount"
          tag-field="riskCode"
          name="위험 항목"
        >
          <DxLabel :visible="true" :customize-text="(d) => d.point.tag" />
        </DxSeries>
        <DxArgumentAxis :tick-interval="1" :value-range="{ min: 0, max: 6 }">
          <DxTitle text="발생 가능성" />
        </DxArgumentAxis>
        <DxValueAxis :tick-interval="1" :value-range="{ min: 0, max: 6 }">
          <DxTitle text="영향도" />
        </DxValueAxis>
        <DxLegend :visible="false" />
        <DxTooltip :enabled="true" :customize-tooltip="customizeTooltip" />
        <DxSize :height="300" />
      </DxChart>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxSelectBox from 'devextreme-vue/select-box'
import { DxChart, DxSeries, DxArgumentAxis, DxValueAxis, DxTitle, DxLabel, DxLegend, DxTooltip, DxSize } from 'devextreme-vue/chart'

const matrixView = ref('고유 위험')
const selectedCell = ref(null)

const likelihoods = [
  { val: 5, label: '거의 확실' },
  { val: 4, label: '높음' },
  { val: 3, label: '보통' },
  { val: 2, label: '낮음' },
  { val: 1, label: '드묾' }
]

const impacts = [
  { val: 1, label: '미미' },
  { val: 2, label: '낮음' },
  { val: 3, label: '보통' },
  { val: 4, label: '높음' },
  { val: 5, label: '심각' }
]

const legendItems = [
  { label: '심각', color: '#8b0000', range: '20-25' },
  { label: '높음', color: '#e74c3c', range: '12-19' },
  { label: '중간', color: '#f39c12', range: '6-11' },
  { label: '낮음', color: '#27ae60', range: '3-5' },
  { label: '미미', color: '#95a5a6', range: '1-2' }
]

const risks = ref([
  { id: 1, riskCode: 'IT-SEC-001', riskName: '권한 없는 시스템 접근', inherentLikelihood: 4, inherentImpact: 5, inherentRisk: '심각', dept: '정보보안팀', riskOwner: '이보안', controlCount: 3 },
  { id: 2, riskCode: 'IT-CHG-001', riskName: '미승인 시스템 변경', inherentLikelihood: 3, inherentImpact: 4, inherentRisk: '높음', dept: '개발팀', riskOwner: '김개발', controlCount: 2 },
  { id: 3, riskCode: 'IT-OPS-001', riskName: '배치 처리 실패 미탐지', inherentLikelihood: 3, inherentImpact: 4, inherentRisk: '높음', dept: 'IT운영팀', riskOwner: '박운영', controlCount: 2 },
  { id: 4, riskCode: 'IT-ACC-001', riskName: '퇴직자 계정 미삭제', inherentLikelihood: 4, inherentImpact: 3, inherentRisk: '높음', dept: 'HR시스템팀', riskOwner: '최시스템', controlCount: 1 },
  { id: 5, riskCode: 'IT-BCM-001', riskName: '재해복구 시스템 미검증', inherentLikelihood: 2, inherentImpact: 5, inherentRisk: '중간', dept: 'IT인프라팀', riskOwner: '정인프라', controlCount: 2 },
  { id: 6, riskCode: 'IT-DATA-001', riskName: '데이터 무결성 미검증', inherentLikelihood: 3, inherentImpact: 3, inherentRisk: '중간', dept: 'DBA팀', riskOwner: '김DBA', controlCount: 1 }
])

const scatterData = computed(() => risks.value)

function getCellClass(lik, imp) {
  const score = lik * imp
  if (score >= 20) return 'cell-critical'
  if (score >= 12) return 'cell-high'
  if (score >= 6) return 'cell-medium'
  if (score >= 3) return 'cell-low'
  return 'cell-minimal'
}

function getRisksInCell(lik, imp) {
  return risks.value.filter(r => r.inherentLikelihood === lik && r.inherentImpact === imp)
}

function selectCell(lik, imp) {
  const score = lik * imp
  let level = '미미'
  let riskClass = 'minimal'
  if (score >= 20) { level = '심각'; riskClass = 'critical' }
  else if (score >= 12) { level = '높음'; riskClass = 'high' }
  else if (score >= 6) { level = '중간'; riskClass = 'medium' }
  else if (score >= 3) { level = '낮음'; riskClass = 'low' }

  selectedCell.value = { lik, imp, score, riskLevel: level, riskClass, label: `L${lik} × I${imp} = ${score}` }
}

const displayRisks = computed(() => {
  if (selectedCell.value) {
    return risks.value.filter(r =>
      r.inherentLikelihood === selectedCell.value.lik &&
      r.inherentImpact === selectedCell.value.imp
    )
  }
  return risks.value
})

const riskSummary = computed(() => {
  const levels = ['심각', '높음', '중간', '낮음', '미미']
  return levels.map(level => ({
    level,
    count: risks.value.filter(r => r.inherentRisk === level).length
  }))
})

const totalRisks = computed(() => risks.value.length)

function getRiskClass(level) {
  const map = { '심각': 'critical', '높음': 'high', '중간': 'medium', '낮음': 'low', '미미': 'minimal' }
  return map[level] || 'minimal'
}

function getProgressClass(level) {
  const map = { '심각': 'danger', '높음': 'danger', '중간': 'warning', '낮음': 'success', '미미': 'info' }
  return map[level] || 'info'
}

function customizeTooltip(arg) {
  const risk = risks.value.find(r => r.riskCode === arg.point.tag)
  if (!risk) return { text: '' }
  return {
    text: `${risk.riskCode}\n${risk.riskName}\n위험수준: ${risk.inherentRisk}`
  }
}
</script>

<style lang="scss" scoped>
.matrix-container {
  position: relative;
}

.matrix-y-label {
  font-size: 11px;
  color: #868e96;
  text-align: center;
  margin-bottom: 8px;
}

.matrix-grid {
  display: grid;
  grid-template-columns: 90px repeat(5, 1fr);
  gap: 3px;
}

.matrix-header-cell {
  background: #1a3a6b;
  color: white;
  text-align: center;
  padding: 8px 4px;
  font-size: 11px;
  font-weight: 600;
  border-radius: 4px;

  &.corner {
    background: #0f2448;
    font-size: 10px;
  }

  small { opacity: 0.7; }
}

.matrix-row-header {
  background: #2d5aa0;
  color: white;
  text-align: center;
  padding: 8px 4px;
  font-size: 11px;
  font-weight: 600;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;

  small { opacity: 0.7; }
}

.matrix-cell {
  border-radius: 4px;
  padding: 6px;
  min-height: 60px;
  cursor: pointer;
  transition: all 0.15s;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: space-between;

  &:hover { opacity: 0.85; transform: scale(1.02); }

  &.cell-critical { background: rgba(139, 0, 0, 0.75); color: white; }
  &.cell-high { background: rgba(231, 76, 60, 0.65); color: white; }
  &.cell-medium { background: rgba(243, 156, 18, 0.6); color: #333; }
  &.cell-low { background: rgba(39, 174, 96, 0.5); color: #1a5e2e; }
  &.cell-minimal { background: rgba(149, 165, 166, 0.35); color: #555; }
}

.cell-score {
  font-size: 16px;
  font-weight: 700;
}

.cell-risks {
  display: flex;
  flex-wrap: wrap;
  gap: 2px;
  justify-content: center;
}

.risk-dot {
  font-size: 8px;
  cursor: help;
  opacity: 0.9;
}

.matrix-legend {
  display: flex;
  gap: 16px;
  margin-top: 12px;
  flex-wrap: wrap;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #495057;
}

.legend-color {
  width: 14px;
  height: 14px;
  border-radius: 3px;
}

.risk-matrix-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 20px;
  max-height: 280px;
  overflow-y: auto;
}

.matrix-risk-item {
  padding: 10px;
  border-radius: 6px;
  border: 1px solid #e9ecef;
  background: #f8f9fa;

  &.risk-critical { border-left: 3px solid #8b0000; }
  &.risk-high { border-left: 3px solid #e74c3c; }
  &.risk-medium { border-left: 3px solid #f39c12; }
  &.risk-low { border-left: 3px solid #27ae60; }
}

.matrix-risk-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.matrix-risk-header code {
  font-size: 11px;
  color: #868e96;
}

.matrix-risk-name {
  font-size: 13px;
  font-weight: 500;
  color: #343a40;
  margin-bottom: 4px;
}

.matrix-risk-meta {
  display: flex;
  gap: 12px;
  font-size: 11px;
  color: #868e96;
}

.risk-summary {
  border-top: 1px solid #e9ecef;
  padding-top: 16px;

  .summary-title {
    font-size: 13px;
    font-weight: 600;
    color: #495057;
    margin-bottom: 12px;
  }
}

.summary-item {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;

  .badge { min-width: 50px; justify-content: center; }
  .summary-bar { flex: 1; }
  .summary-count { font-size: 12px; color: #495057; font-weight: 500; min-width: 30px; text-align: right; }
}
</style>
