<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">평가 계획</h1>
          <p class="page-subtitle">{{ evalStore.periodLabel }} 운영평가 계획을 수립합니다</p>
        </div>
        <div class="d-flex gap-8">
          <DxButton text="계획 확정" icon="check" type="success" @click="confirmPlan" />
          <DxButton text="평가 계획 추가" icon="plus" type="default" @click="showDialog = true" />
        </div>
      </div>
    </div>

    <!-- Plan Status -->
    <div class="stat-cards" style="margin-bottom: 20px">
      <div v-for="s in planStats" :key="s.id" class="stat-card">
        <div class="stat-icon" :class="`icon-${s.iconType}`">{{ s.icon }}</div>
        <div class="stat-info">
          <div class="stat-label">{{ s.label }}</div>
          <div class="stat-value">{{ s.value }}</div>
          <div class="stat-change" :class="s.changeType">{{ s.change }}</div>
        </div>
      </div>
    </div>

    <!-- Gantt/Schedule View -->
    <div class="card" style="margin-bottom: 20px">
      <div class="card-header">
        <div class="card-title">평가 일정 개요 ({{ currentYear }}년 {{ currentQuarter }}분기)</div>
        <div class="d-flex gap-8">
          <span class="badge badge-primary">총 {{ planItems.length }}개 평가</span>
        </div>
      </div>
      <div class="schedule-timeline">
        <div class="timeline-header">
          <div class="tl-label-col">평가 항목</div>
          <div class="tl-months">
            <div v-for="m in timelineMonths" :key="m" class="tl-month">{{ m }}</div>
          </div>
        </div>
        <div v-for="item in planItems" :key="item.id" class="timeline-row">
          <div class="tl-label-col">
            <div class="tl-item-name">{{ item.controlCode }}</div>
            <div class="tl-item-sub">{{ item.assignee }}</div>
          </div>
          <div class="tl-months">
            <div v-for="(m, mi) in timelineMonths" :key="m" class="tl-cell">
              <div
                v-if="isInRange(item, mi)"
                class="tl-bar"
                :class="`status-${item.status}`"
                :style="getBarStyle(item, mi)"
              >
                <span v-if="isBarStart(item, mi)" class="tl-bar-label">{{ item.status }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Plan Table -->
    <div class="card" style="padding: 0">
      <DxDataGrid
        :data-source="planItems"
        :show-borders="false"
        :hover-state-enabled="true"
        :column-auto-width="true"
        :allow-column-resizing="true"
        key-expr="id"
      >
        <DxEditing mode="row" :allow-updating="true" :allow-deleting="true" />
        <DxToolbar>
          <DxItem location="before" template="titleTemplate" />
          <DxItem name="searchPanel" />
        </DxToolbar>
        <DxSearchPanel :visible="true" placeholder="검색..." />
        <DxPaging :page-size="15" />
        <DxPager :show-info="true" />

        <DxColumn data-field="controlCode" caption="통제 코드" width="130" :allow-editing="false" />
        <DxColumn data-field="controlName" caption="통제명" min-width="180" :allow-editing="false" />
        <DxColumn data-field="domain" caption="도메인" width="110" cell-template="domainTemplate" :allow-editing="false" />
        <DxColumn data-field="assignee" caption="평가자" width="100" />
        <DxColumn data-field="plannedStartDate" caption="계획 시작일" width="115" data-type="date" />
        <DxColumn data-field="plannedEndDate" caption="계획 완료일" width="115" data-type="date" />
        <DxColumn data-field="samplingCount" caption="샘플링 수" width="90" alignment="center" />
        <DxColumn data-field="samplingMethod" caption="샘플링 방법" width="110">
          <DxLookup :data-source="['전수', '확률적', '비통계적', '판단적']" />
        </DxColumn>
        <DxColumn data-field="status" caption="상태" width="100" cell-template="statusTemplate" :allow-editing="false" />

        <template #titleTemplate>
          <div style="font-weight: 600; font-size: 15px; color: #1a3a6b; padding: 4px 0">
            운영평가 계획 목록
          </div>
        </template>
        <template #domainTemplate="{ data }">
          <span class="coso-badge coso-control">{{ data.value }}</span>
        </template>
        <template #statusTemplate="{ data }">
          <span class="badge" :class="getPlanStatusBadge(data.value)">{{ data.value }}</span>
        </template>
      </DxDataGrid>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxDataGrid, { DxColumn, DxEditing, DxLookup, DxPaging, DxPager, DxSearchPanel, DxToolbar, DxItem } from 'devextreme-vue/data-grid'
import { useEvaluationStore } from '@/store'

const evalStore = useEvaluationStore()
const currentYear = new Date().getFullYear()
const currentQuarter = Math.ceil((new Date().getMonth() + 1) / 3)
const showDialog = ref(false)

const planStats = ref([
  { id: 1, icon: '📋', iconType: 'primary', label: '평가 계획 건수', value: '28건', change: '전분기 대비 +3건', changeType: 'neutral' },
  { id: 2, icon: '✓', iconType: 'success', label: '평가 완료', value: '12건', change: '42.9%', changeType: 'down' },
  { id: 3, icon: '⏳', iconType: 'warning', label: '평가 진행중', value: '8건', change: '28.6%', changeType: 'neutral' },
  { id: 4, icon: '○', iconType: 'info', label: '평가 예정', value: '8건', change: '28.6%', changeType: 'neutral' }
])

// Timeline months (Q1 2026)
const timelineMonths = computed(() => {
  const q = currentQuarter
  const months = []
  for (let i = 0; i < 3; i++) {
    const m = ((q - 1) * 3 + i + 1)
    months.push(`${currentYear}년 ${m}월`)
  }
  return months
})

function isInRange(item, monthIdx) {
  // Simplified: check if bar overlaps with month
  return item.monthStart <= monthIdx && item.monthEnd >= monthIdx
}

function isBarStart(item, monthIdx) {
  return item.monthStart === monthIdx
}

function getBarStyle(item, monthIdx) {
  return {}
}

const planItems = ref([
  { id: 1, controlCode: 'CTRL-ACC-001', controlName: '사용자 계정 등록/변경/삭제 승인', domain: '접근통제', assignee: '이보안', plannedStartDate: '2026-03-01', plannedEndDate: '2026-03-07', samplingCount: 25, samplingMethod: '확률적', status: '완료', monthStart: 0, monthEnd: 0 },
  { id: 2, controlCode: 'CTRL-ACC-002', controlName: '특권 계정 반기 재검토', domain: '접근통제', assignee: '이보안', plannedStartDate: '2026-03-08', plannedEndDate: '2026-03-14', samplingCount: 1, samplingMethod: '전수', status: '진행중', monthStart: 0, monthEnd: 0 },
  { id: 3, controlCode: 'CTRL-CHG-001', controlName: '변경 요청 및 승인 관리', domain: '변경관리', assignee: '박검토', plannedStartDate: '2026-03-15', plannedEndDate: '2026-03-21', samplingCount: 30, samplingMethod: '확률적', status: '진행중', monthStart: 0, monthEnd: 0 },
  { id: 4, controlCode: 'CTRL-OPS-001', controlName: '배치 작업 모니터링', domain: 'IT운영', assignee: '김감사', plannedStartDate: '2026-03-22', plannedEndDate: '2026-03-31', samplingCount: 20, samplingMethod: '비통계적', status: '예정', monthStart: 0, monthEnd: 0 },
  { id: 5, controlCode: 'CTRL-BCM-001', controlName: 'DR 테스트 실시', domain: '업무연속성', assignee: '김감사', plannedStartDate: '2026-04-01', plannedEndDate: '2026-04-15', samplingCount: 1, samplingMethod: '전수', status: '예정', monthStart: 1, monthEnd: 1 },
  { id: 6, controlCode: 'CTRL-SEC-001', controlName: '취약점 정기 스캔', domain: '정보보안', assignee: '이보안', plannedStartDate: '2026-04-16', plannedEndDate: '2026-04-30', samplingCount: 3, samplingMethod: '전수', status: '예정', monthStart: 1, monthEnd: 1 }
])

function getPlanStatusBadge(status) {
  const map = { '완료': 'effective', '진행중': 'partial', '예정': 'not-tested', '지연': 'ineffective' }
  return `badge-${map[status] || 'not-tested'}`
}

function confirmPlan() {
  console.log('Plan confirmed')
}
</script>

<style lang="scss" scoped>
// Timeline
.schedule-timeline {
  overflow-x: auto;
}

.timeline-header {
  display: flex;
  border-bottom: 2px solid #e9ecef;
  margin-bottom: 4px;
}

.tl-label-col {
  width: 180px;
  min-width: 180px;
  font-size: 12px;
  font-weight: 600;
  color: #495057;
  padding: 8px;
}

.tl-months {
  flex: 1;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2px;
}

.tl-month {
  font-size: 12px;
  font-weight: 600;
  color: #495057;
  padding: 8px;
  text-align: center;
  background: #f8f9fa;
  border-radius: 4px;
}

.timeline-row {
  display: flex;
  align-items: center;
  border-bottom: 1px solid #f1f3f5;
  min-height: 44px;

  &:hover { background: #f8f9fa; }
}

.tl-item-name {
  font-size: 12px;
  font-weight: 500;
  color: #343a40;
}

.tl-item-sub {
  font-size: 11px;
  color: #868e96;
}

.tl-cell {
  padding: 4px;
  position: relative;
  min-height: 44px;
  display: flex;
  align-items: center;
}

.tl-bar {
  height: 24px;
  border-radius: 4px;
  width: 100%;
  display: flex;
  align-items: center;
  padding: 0 8px;
  position: relative;

  &.status-완료 { background: rgba(39, 174, 96, 0.25); border: 1px solid #27ae60; }
  &.status-진행중 { background: rgba(52, 152, 219, 0.25); border: 1px solid #3498db; }
  &.status-예정 { background: rgba(149, 165, 166, 0.2); border: 1px solid #adb5bd; }
}

.tl-bar-label {
  font-size: 10px;
  font-weight: 600;
  color: #343a40;
  white-space: nowrap;
}
</style>
