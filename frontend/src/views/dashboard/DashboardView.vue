<template>
  <div>
    <!-- Page Header -->
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">ITGC 포털 대시보드</h1>
          <p class="page-subtitle">{{ evalStore.periodLabel }} | 최종 업데이트: {{ today }}</p>
        </div>
        <div class="d-flex gap-8">
          <DxButton text="보고서 출력" icon="print" type="normal" />
          <DxButton text="데이터 갱신" icon="refresh" type="default" @click="refreshData" />
        </div>
      </div>
    </div>

    <!-- COSO Framework Overview -->
    <div class="section">
      <div class="section-header">
        <div class="section-title">COSO 프레임워크 현황</div>
      </div>
      <div class="coso-overview">
        <div
          v-for="comp in cosoComponents"
          :key="comp.id"
          class="coso-component"
          :class="`coso-${comp.type}`"
        >
          <div class="coso-comp-header">
            <span class="coso-comp-icon">{{ comp.icon }}</span>
            <div class="coso-comp-info">
              <div class="coso-comp-name">{{ comp.name }}</div>
              <div class="coso-comp-en">{{ comp.nameEn }}</div>
            </div>
            <div class="coso-comp-score" :class="`score-${comp.status}`">
              {{ comp.score }}점
            </div>
          </div>
          <div class="progress-bar" style="margin: 10px 0 6px">
            <div
              class="progress-fill"
              :class="`fill-${comp.fillClass}`"
              :style="{ width: comp.score + '%' }"
            ></div>
          </div>
          <div class="coso-comp-stats">
            <span>통제 {{ comp.controls }}개</span>
            <span>·</span>
            <span class="text-danger">미비점 {{ comp.issues }}개</span>
          </div>
        </div>
      </div>
    </div>

    <!-- KPI Stats -->
    <div class="stat-cards">
      <div v-for="stat in kpiStats" :key="stat.id" class="stat-card">
        <div class="stat-icon" :class="`icon-${stat.iconType}`">
          {{ stat.icon }}
        </div>
        <div class="stat-info">
          <div class="stat-label">{{ stat.label }}</div>
          <div class="stat-value">{{ stat.value }}</div>
          <div class="stat-change" :class="stat.changeType">{{ stat.change }}</div>
        </div>
      </div>
    </div>

    <!-- Charts & Tables Row -->
    <div class="grid-2" style="margin-bottom: 24px">
      <!-- 위험 분포 차트 -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">위험 수준 분포</div>
          <span class="badge badge-primary">{{ currentYear }}년</span>
        </div>
        <DxChart
          :data-source="riskDistribution"
          :customize-point="customizeRiskPoint"
        >
          <DxSeries
            argument-field="level"
            value-field="count"
            type="bar"
            name="위험 건수"
          >
            <DxLabel :visible="true" />
          </DxSeries>
          <DxArgumentAxis>
            <DxLabel :word-wrap="'none'" />
          </DxArgumentAxis>
          <DxValueAxis>
            <DxTitle text="건수" />
          </DxValueAxis>
          <DxLegend :visible="false" />
          <DxTooltip :enabled="true" />
        </DxChart>
      </div>

      <!-- 통제 효과성 현황 -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">통제 효과성 현황</div>
          <span class="badge badge-info">운영평가 기준</span>
        </div>
        <DxPieChart
          :data-source="controlEffectiveness"
          type="doughnut"
        >
          <DxSeries
            argument-field="status"
            value-field="count"
          >
            <DxLabel :visible="true" :customize-text="pieLabel" />
          </DxSeries>
          <DxLegend
            horizontal-alignment="center"
            vertical-alignment="bottom"
            orientation="horizontal"
          />
          <DxTooltip :enabled="true" />
        </DxPieChart>
      </div>
    </div>

    <!-- 위험 상위 목록 & 평가 일정 -->
    <div class="grid-2" style="margin-bottom: 24px">
      <!-- 고위험 항목 -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">고위험 통제 항목</div>
          <router-link to="/risk/assessment" class="view-all">전체 보기 ›</router-link>
        </div>
        <div class="risk-list">
          <div
            v-for="risk in highRisks"
            :key="risk.id"
            class="risk-item"
          >
            <div class="risk-item-header">
              <span class="badge" :class="`badge-${risk.levelClass}`">{{ risk.level }}</span>
              <span class="risk-code">{{ risk.code }}</span>
              <span class="risk-dept">{{ risk.dept }}</span>
            </div>
            <div class="risk-name">{{ risk.name }}</div>
            <div class="risk-footer">
              <span class="text-muted" style="font-size: 12px">담당: {{ risk.owner }}</span>
              <span class="badge" :class="`badge-${risk.controlStatus}`">{{ risk.controlStatusText }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 평가 일정 -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">운영평가 일정</div>
          <router-link to="/evaluation/plan" class="view-all">전체 보기 ›</router-link>
        </div>
        <div class="eval-schedule">
          <div
            v-for="sched in evalSchedule"
            :key="sched.id"
            class="sched-item"
          >
            <div class="sched-date">
              <div class="sched-month">{{ sched.month }}</div>
              <div class="sched-day">{{ sched.day }}</div>
            </div>
            <div class="sched-info">
              <div class="sched-title">{{ sched.title }}</div>
              <div class="sched-meta">
                <span>{{ sched.dept }}</span>
                <span class="badge" :class="`badge-${sched.statusClass}`">{{ sched.status }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 최근 발견사항 -->
    <div class="section">
      <div class="section-header">
        <div class="section-title">최근 발견사항 현황</div>
        <router-link to="/findings/list" class="view-all">전체 보기 ›</router-link>
      </div>
      <div class="card" style="padding: 0">
        <DxDataGrid
          :data-source="recentFindings"
          :show-borders="false"
          :column-auto-width="true"
          :hover-state-enabled="true"
          :paging="{ pageSize: 5 }"
        >
          <DxColumn data-field="findingNo" caption="발견사항 번호" width="140" />
          <DxColumn data-field="riskId" caption="관련 위험" width="130" />
          <DxColumn data-field="title" caption="발견사항명" />
          <DxColumn data-field="severity" caption="심각도" width="90" cell-template="severityTemplate" />
          <DxColumn data-field="dept" caption="담당부서" width="120" />
          <DxColumn data-field="dueDate" caption="조치 기한" width="110" />
          <DxColumn data-field="status" caption="상태" width="100" cell-template="statusTemplate" />

          <template #severityTemplate="{ data }">
            <span class="badge" :class="`badge-${getSeverityClass(data.value)}`">
              {{ data.value }}
            </span>
          </template>
          <template #statusTemplate="{ data }">
            <span class="badge" :class="`badge-${getStatusClass(data.value)}`">
              {{ data.value }}
            </span>
          </template>
        </DxDataGrid>
      </div>
    </div>

    <!-- 미결 개선조치 현황 -->
    <div class="grid-3" style="margin-bottom: 24px">
      <div class="card card-danger">
        <div class="d-flex align-center gap-16">
          <div class="stat-icon icon-danger">⚠</div>
          <div>
            <div class="text-muted" style="font-size: 12px">기한 초과 개선조치</div>
            <div style="font-size: 28px; font-weight: 700; color: #e74c3c">{{ overdueCount }}</div>
            <div style="font-size: 11px; color: #e74c3c">즉시 조치 필요</div>
          </div>
        </div>
      </div>

      <div class="card card-warning">
        <div class="d-flex align-center gap-16">
          <div class="stat-icon icon-warning">⏰</div>
          <div>
            <div class="text-muted" style="font-size: 12px">7일 내 기한 도래</div>
            <div style="font-size: 28px; font-weight: 700; color: #f39c12">{{ dueSoonCount }}</div>
            <div style="font-size: 11px; color: #f39c12">신속 조치 필요</div>
          </div>
        </div>
      </div>

      <div class="card card-success">
        <div class="d-flex align-center gap-16">
          <div class="stat-icon icon-success">✓</div>
          <div>
            <div class="text-muted" style="font-size: 12px">이번 분기 완료</div>
            <div style="font-size: 28px; font-weight: 700; color: #27ae60">{{ completedCount }}</div>
            <div style="font-size: 11px; color: #27ae60">개선 완료</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import dayjs from 'dayjs'
import { useEvaluationStore } from '@/store'

// DevExtreme Components
import DxButton from 'devextreme-vue/button'
import { DxChart, DxSeries, DxArgumentAxis, DxValueAxis, DxTitle, DxLabel, DxLegend, DxTooltip } from 'devextreme-vue/chart'
import { DxPieChart, DxSeries as DxPieSeries, DxLabel as DxPieLabel } from 'devextreme-vue/pie-chart'
import DxDataGrid, { DxColumn } from 'devextreme-vue/data-grid'

const evalStore = useEvaluationStore()
const today = dayjs().format('YYYY년 MM월 DD일')
const currentYear = new Date().getFullYear()

function refreshData() {
  // API 연동 시 데이터 갱신
  console.log('Refreshing data...')
}

// COSO Components
const cosoComponents = ref([
  {
    id: 1, type: 'env', icon: '🏛', name: '통제 환경',
    nameEn: 'Control Environment', score: 82, controls: 24, issues: 2,
    status: 'good', fillClass: 'primary'
  },
  {
    id: 2, type: 'risk', icon: '⚠', name: '위험 평가',
    nameEn: 'Risk Assessment', score: 75, controls: 18, issues: 4,
    status: 'warn', fillClass: 'warning'
  },
  {
    id: 3, type: 'ctrl', icon: '⚙', name: '통제 활동',
    nameEn: 'Control Activities', score: 88, controls: 42, issues: 1,
    status: 'good', fillClass: 'success'
  },
  {
    id: 4, type: 'info', icon: '📡', name: '정보 및 의사소통',
    nameEn: 'Information & Communication', score: 70, controls: 15, issues: 5,
    status: 'warn', fillClass: 'info'
  },
  {
    id: 5, type: 'mon', icon: '📊', name: '모니터링',
    nameEn: 'Monitoring Activities', score: 65, controls: 12, issues: 6,
    status: 'bad', fillClass: 'danger'
  }
])

// KPI Stats
const kpiStats = ref([
  { id: 1, icon: '🎯', iconType: 'primary', label: '전체 통제 수', value: '111', change: '전 분기 대비 +5', changeType: 'neutral' },
  { id: 2, icon: '⚠', iconType: 'danger', label: '고위험 항목', value: '18', change: '▲ 3건 증가', changeType: 'up' },
  { id: 3, icon: '✓', iconType: 'success', label: '효과적 통제', value: '89', change: '▲ 8% 향상', changeType: 'down' },
  { id: 4, icon: '🔍', iconType: 'warning', label: '미결 발견사항', value: '24', change: '▼ 5건 감소', changeType: 'down' },
  { id: 5, icon: '📋', iconType: 'info', label: '평가 진행률', value: '67%', change: '목표: 100%', changeType: 'neutral' },
  { id: 6, icon: '⏰', iconType: 'purple', label: '기한 초과', value: '7', change: '즉시 조치 필요', changeType: 'up' }
])

// Risk Distribution Chart
const riskDistribution = ref([
  { level: '심각', count: 3 },
  { level: '높음', count: 15 },
  { level: '중간', count: 28 },
  { level: '낮음', count: 42 },
  { level: '미미', count: 23 }
])

function customizeRiskPoint(point) {
  const colors = {
    '심각': '#8b0000',
    '높음': '#e74c3c',
    '중간': '#f39c12',
    '낮음': '#27ae60',
    '미미': '#95a5a6'
  }
  point.color = colors[point.argument] || '#3498db'
}

// Control Effectiveness Pie
const controlEffectiveness = ref([
  { status: '효과적', count: 89 },
  { status: '부분 효과적', count: 15 },
  { status: '비효과적', count: 5 },
  { status: '미평가', count: 2 }
])

function pieLabel(data) {
  return `${data.argumentText}: ${data.valueText}건`
}

// High Risks
const highRisks = ref([
  {
    id: 1, code: 'IT-SEC-001', level: '심각', levelClass: 'critical',
    name: '권한 없는 시스템 접근에 대한 통제 미흡',
    dept: '정보보안팀', owner: '이보안', controlStatus: 'ineffective', controlStatusText: '비효과적'
  },
  {
    id: 2, code: 'IT-OPS-004', level: '높음', levelClass: 'high',
    name: '배치 처리 오류에 대한 모니터링 부재',
    dept: 'IT운영팀', owner: '박운영', controlStatus: 'partial', controlStatusText: '부분 효과적'
  },
  {
    id: 3, code: 'IT-CHG-002', level: '높음', levelClass: 'high',
    name: '변경관리 절차 미준수',
    dept: '개발팀', owner: '김개발', controlStatus: 'partial', controlStatusText: '부분 효과적'
  },
  {
    id: 4, code: 'IT-ACC-007', level: '높음', levelClass: 'high',
    name: '퇴직자 계정 미삭제',
    dept: 'HR시스템팀', owner: '최시스템', controlStatus: 'not-tested', controlStatusText: '미평가'
  }
])

// Eval Schedule
const evalSchedule = ref([
  { id: 1, month: 'MAR', day: '10', title: 'ERP 접근통제 운영평가', dept: 'IT운영팀', status: '진행중', statusClass: 'info' },
  { id: 2, month: 'MAR', day: '15', title: '변경관리 통제 평가', dept: '개발팀', status: '예정', statusClass: 'not-tested' },
  { id: 3, month: 'MAR', day: '20', title: '백업 및 복구 통제 평가', dept: 'IT인프라팀', status: '예정', statusClass: 'not-tested' },
  { id: 4, month: 'MAR', day: '28', title: '정보보안 통제 평가', dept: '정보보안팀', status: '예정', statusClass: 'not-tested' },
  { id: 5, month: 'APR', day: '05', title: '분기 평가 보고서 작성', dept: '감사팀', status: '예정', statusClass: 'not-tested' }
])

// Recent Findings
const recentFindings = ref([
  {
    findingNo: 'FND-2026-001', riskId: 'IT-SEC-001', title: '관리자 계정 다중 사용 발견',
    severity: '심각', dept: '정보보안팀', dueDate: '2026-03-15', status: '조치중'
  },
  {
    findingNo: 'FND-2026-002', riskId: 'IT-ACC-007', title: '퇴직자 계정 15건 미삭제',
    severity: '높음', dept: 'HR시스템팀', dueDate: '2026-03-10', status: '기한초과'
  },
  {
    findingNo: 'FND-2026-003', riskId: 'IT-CHG-002', title: '미승인 변경 3건 발생',
    severity: '높음', dept: '개발팀', dueDate: '2026-03-20', status: '조치완료'
  },
  {
    findingNo: 'FND-2026-004', riskId: 'IT-OPS-004', title: '배치 오류 무감지 운영',
    severity: '중간', dept: 'IT운영팀', dueDate: '2026-04-01', status: '조치중'
  },
  {
    findingNo: 'FND-2026-005', riskId: 'IT-DATA-003', title: '데이터 정합성 검증 누락',
    severity: '중간', dept: 'DBA팀', dueDate: '2026-04-15', status: '미결'
  }
])

const overdueCount = ref(7)
const dueSoonCount = ref(12)
const completedCount = ref(31)

function getSeverityClass(val) {
  const map = { '심각': 'critical', '높음': 'high', '중간': 'medium', '낮음': 'low' }
  return map[val] || 'minimal'
}

function getStatusClass(val) {
  const map = { '조치완료': 'effective', '조치중': 'partial', '기한초과': 'ineffective', '미결': 'not-tested' }
  return map[val] || 'not-tested'
}
</script>

<style lang="scss" scoped>
.view-all {
  font-size: 13px;
  color: #1a3a6b;
  text-decoration: none;
  font-weight: 500;

  &:hover { text-decoration: underline; }
}

// COSO Overview
.coso-overview {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 12px;

  @media (max-width: 1200px) {
    grid-template-columns: repeat(3, 1fr);
  }
}

.coso-component {
  background: white;
  border-radius: 10px;
  padding: 16px;
  border: 1px solid #e9ecef;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06);
  transition: transform 0.2s, box-shadow 0.2s;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  }

  &.coso-env { border-top: 3px solid #4a6fa5; }
  &.coso-risk { border-top: 3px solid #c0392b; }
  &.coso-ctrl { border-top: 3px solid #27ae60; }
  &.coso-info { border-top: 3px solid #8e44ad; }
  &.coso-mon { border-top: 3px solid #e67e22; }
}

.coso-comp-header {
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.coso-comp-icon {
  font-size: 20px;
  flex-shrink: 0;
}

.coso-comp-info {
  flex: 1;
}

.coso-comp-name {
  font-size: 13px;
  font-weight: 600;
  color: #343a40;
}

.coso-comp-en {
  font-size: 10px;
  color: #868e96;
}

.coso-comp-score {
  font-size: 18px;
  font-weight: 700;
  flex-shrink: 0;

  &.score-good { color: #27ae60; }
  &.score-warn { color: #f39c12; }
  &.score-bad { color: #e74c3c; }
}

.coso-comp-stats {
  font-size: 11px;
  color: #868e96;
  display: flex;
  gap: 6px;
}

// Risk List
.risk-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.risk-item {
  padding: 12px;
  background: #f8f9fa;
  border-radius: 8px;
  border: 1px solid #e9ecef;

  &:hover { border-color: #1a3a6b; }
}

.risk-item-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 6px;
}

.risk-code {
  font-size: 11px;
  color: #868e96;
  font-family: monospace;
}

.risk-dept {
  font-size: 11px;
  color: #868e96;
  margin-left: auto;
}

.risk-name {
  font-size: 13px;
  font-weight: 500;
  color: #343a40;
  margin-bottom: 8px;
  line-height: 1.4;
}

.risk-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

// Eval Schedule
.eval-schedule {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.sched-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 12px 0;
  border-bottom: 1px solid #f1f3f5;

  &:last-child { border-bottom: none; }
}

.sched-date {
  width: 44px;
  height: 44px;
  background: #1a3a6b;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.sched-month {
  font-size: 9px;
  color: rgba(255,255,255,0.7);
  font-weight: 600;
  letter-spacing: 1px;
}

.sched-day {
  font-size: 16px;
  color: white;
  font-weight: 700;
  line-height: 1;
}

.sched-info {
  flex: 1;
}

.sched-title {
  font-size: 13px;
  font-weight: 500;
  color: #343a40;
  margin-bottom: 4px;
}

.sched-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #868e96;
}
</style>
