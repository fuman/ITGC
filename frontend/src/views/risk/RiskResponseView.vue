<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">위험 대응</h1>
          <p class="page-subtitle">위험 수준에 따른 대응 전략 및 조치 계획을 수립합니다</p>
        </div>
        <DxButton text="대응 계획 등록" icon="plus" type="default" @click="showDialog = true" />
      </div>
    </div>

    <!-- Response Strategy Summary -->
    <div class="stat-cards" style="margin-bottom: 24px">
      <div class="stat-card" v-for="strat in strategies" :key="strat.id">
        <div class="stat-icon" :class="`icon-${strat.iconType}`">{{ strat.icon }}</div>
        <div class="stat-info">
          <div class="stat-label">{{ strat.name }}</div>
          <div class="stat-value">{{ strat.count }}</div>
          <div class="stat-change neutral">{{ strat.desc }}</div>
        </div>
      </div>
    </div>

    <!-- Response Plans Table -->
    <div class="card" style="padding: 0">
      <DxDataGrid
        :data-source="responsePlans"
        :show-borders="false"
        :hover-state-enabled="true"
        :column-auto-width="true"
        :allow-column-resizing="true"
        :word-wrap-enabled="true"
      >
        <DxToolbar>
          <DxItem location="before" template="titleTemplate" />
          <DxItem name="searchPanel" />
        </DxToolbar>
        <DxSearchPanel :visible="true" placeholder="대응 계획 검색..." />
        <DxPaging :page-size="10" />
        <DxPager :show-info="true" />

        <DxColumn data-field="riskCode" caption="위험 코드" width="130" />
        <DxColumn data-field="riskName" caption="위험명" min-width="180" />
        <DxColumn data-field="riskLevel" caption="위험 수준" width="100" cell-template="riskTemplate" />
        <DxColumn data-field="responseStrategy" caption="대응 전략" width="100" cell-template="strategyTemplate" />
        <DxColumn data-field="responseAction" caption="대응 조치" min-width="200" />
        <DxColumn data-field="responsibleDept" caption="담당 부서" width="120" />
        <DxColumn data-field="responsiblePerson" caption="담당자" width="100" />
        <DxColumn data-field="targetDate" caption="목표 완료일" width="115" />
        <DxColumn data-field="progress" caption="진행률" width="120" cell-template="progressTemplate" />
        <DxColumn data-field="responseStatus" caption="상태" width="90" cell-template="statusTemplate" />

        <template #titleTemplate>
          <div style="font-weight: 600; font-size: 15px; color: #1a3a6b; padding: 4px 0">위험 대응 계획</div>
        </template>
        <template #riskTemplate="{ data }">
          <span class="badge" :class="`badge-${getRiskClass(data.value)}`">{{ data.value }}</span>
        </template>
        <template #strategyTemplate="{ data }">
          <span class="strategy-badge" :class="`strategy-${data.value}`">{{ data.value }}</span>
        </template>
        <template #progressTemplate="{ data }">
          <div class="progress-cell">
            <div class="progress-bar" style="flex: 1">
              <div
                class="progress-fill"
                :class="data.value >= 80 ? 'fill-success' : data.value >= 50 ? 'fill-primary' : 'fill-warning'"
                :style="{ width: data.value + '%' }"
              ></div>
            </div>
            <span style="font-size: 12px; min-width: 35px; text-align: right">{{ data.value }}%</span>
          </div>
        </template>
        <template #statusTemplate="{ data }">
          <span class="badge" :class="getStatusBadge(data.value)">{{ data.value }}</span>
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

const strategies = ref([
  { id: 1, icon: '🛡', iconType: 'primary', name: '위험 완화', count: '42건', desc: '통제 강화를 통한 위험 감소' },
  { id: 2, icon: '🔄', iconType: 'info', name: '위험 이전', count: '8건', desc: '보험/아웃소싱으로 이전' },
  { id: 3, icon: '✓', iconType: 'success', name: '위험 수용', count: '15건', desc: '수용 가능 수준으로 판단' },
  { id: 4, icon: '⛔', iconType: 'danger', name: '위험 회피', count: '5건', desc: '위험 활동 중단/변경' }
])

const responsePlans = ref([
  {
    id: 1, riskCode: 'IT-SEC-001', riskName: '권한 없는 시스템 접근', riskLevel: '심각',
    responseStrategy: '완화', responseAction: '다중인증(MFA) 도입 및 접근 로그 모니터링 강화',
    responsibleDept: '정보보안팀', responsiblePerson: '이보안', targetDate: '2026-03-31',
    progress: 65, responseStatus: '진행중'
  },
  {
    id: 2, riskCode: 'IT-CHG-001', riskName: '미승인 시스템 변경', riskLevel: '높음',
    responseStrategy: '완화', responseAction: '변경관리 도구 도입 및 승인 프로세스 자동화',
    responsibleDept: '개발팀', responsiblePerson: '김개발', targetDate: '2026-04-30',
    progress: 30, responseStatus: '진행중'
  },
  {
    id: 3, riskCode: 'IT-ACC-001', riskName: '퇴직자 계정 미삭제', riskLevel: '높음',
    responseStrategy: '완화', responseAction: 'HR-IT 시스템 연동을 통한 계정 자동 삭제 프로세스 구축',
    responsibleDept: 'HR시스템팀', responsiblePerson: '최시스템', targetDate: '2026-06-30',
    progress: 15, responseStatus: '계획'
  },
  {
    id: 4, riskCode: 'IT-BCM-001', riskName: '재해복구 시스템 미검증', riskLevel: '중간',
    responseStrategy: '완화', responseAction: '반기 1회 DR 테스트 실시 및 결과 보고서 작성',
    responsibleDept: 'IT인프라팀', responsiblePerson: '정인프라', targetDate: '2026-06-30',
    progress: 0, responseStatus: '계획'
  },
  {
    id: 5, riskCode: 'IT-OPS-001', riskName: '배치 처리 실패 미탐지', riskLevel: '높음',
    responseStrategy: '완화', responseAction: '모니터링 솔루션 도입 및 알람 정책 수립',
    responsibleDept: 'IT운영팀', responsiblePerson: '박운영', targetDate: '2026-05-31',
    progress: 50, responseStatus: '진행중'
  }
])

function getRiskClass(level) {
  const map = { '심각': 'critical', '높음': 'high', '중간': 'medium', '낮음': 'low', '미미': 'minimal' }
  return map[level] || 'minimal'
}

function getStatusBadge(status) {
  const map = { '완료': 'effective', '진행중': 'partial', '계획': 'not-tested', '지연': 'ineffective' }
  return `badge-${map[status] || 'not-tested'}`
}
</script>

<style lang="scss" scoped>
.strategy-badge {
  display: inline-flex;
  padding: 3px 10px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;

  &.strategy-완화 { background: rgba(52, 152, 219, 0.12); color: #2980b9; }
  &.strategy-이전 { background: rgba(142, 68, 173, 0.12); color: #7d3c98; }
  &.strategy-수용 { background: rgba(39, 174, 96, 0.12); color: #1e8449; }
  &.strategy-회피 { background: rgba(231, 76, 60, 0.12); color: #c0392b; }
}

.progress-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}
</style>
