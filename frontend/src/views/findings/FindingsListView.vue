<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">발견사항 목록</h1>
          <p class="page-subtitle">운영평가 및 감사에서 발견된 통제 미비점을 관리합니다</p>
        </div>
        <div class="d-flex gap-8">
          <DxButton text="Excel 내보내기" icon="exportxlsx" type="normal" />
          <DxButton text="발견사항 등록" icon="plus" type="default" @click="showDialog = true" />
        </div>
      </div>
    </div>

    <!-- Summary -->
    <div class="stat-cards" style="margin-bottom: 20px">
      <div v-for="s in findingStats" :key="s.id" class="stat-card">
        <div class="stat-icon" :class="`icon-${s.iconType}`">{{ s.icon }}</div>
        <div class="stat-info">
          <div class="stat-label">{{ s.label }}</div>
          <div class="stat-value">{{ s.value }}</div>
          <div class="stat-change" :class="s.changeType">{{ s.change }}</div>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="card" style="margin-bottom: 16px">
      <div class="filter-row">
        <div class="filter-item">
          <label class="filter-label">심각도</label>
          <DxSelectBox v-model:value="filters.severity" :items="['심각', '높음', '중간', '낮음']" placeholder="전체" :show-clear-button="true" width="130" />
        </div>
        <div class="filter-item">
          <label class="filter-label">상태</label>
          <DxSelectBox v-model:value="filters.status" :items="['미결', '조치중', '조치완료', '기한초과', '수용']" placeholder="전체" :show-clear-button="true" width="140" />
        </div>
        <div class="filter-item">
          <label class="filter-label">담당 부서</label>
          <DxSelectBox v-model:value="filters.dept" :items="deptOptions" placeholder="전체" :show-clear-button="true" width="160" />
        </div>
        <div class="filter-item">
          <label class="filter-label">발견 유형</label>
          <DxSelectBox v-model:value="filters.type" :items="['운영평가', '내부감사', '외부감사', '자체점검']" placeholder="전체" :show-clear-button="true" width="140" />
        </div>
        <DxButton text="조회" type="default" icon="search" />
        <DxButton text="초기화" type="normal" icon="clear" @click="resetFilters" />
      </div>
    </div>

    <!-- Findings Grid -->
    <div class="card" style="padding: 0">
      <DxDataGrid
        :data-source="filteredFindings"
        :show-borders="false"
        :hover-state-enabled="true"
        :column-auto-width="true"
        :allow-column-resizing="true"
        :row-alternation-enabled="true"
        :master-detail="{ enabled: true, template: 'detailTemplate' }"
      >
        <DxToolbar>
          <DxItem location="before" template="titleTemplate" />
          <DxItem name="searchPanel" />
        </DxToolbar>
        <DxSearchPanel :visible="true" placeholder="발견사항 검색..." />
        <DxPaging :page-size="15" />
        <DxPager :show-info="true" :allowed-page-sizes="[10, 15, 30]" />

        <DxColumn data-field="findingNo" caption="발견사항 번호" width="140" :fixed="true" />
        <DxColumn data-field="findingType" caption="발견 유형" width="100" />
        <DxColumn data-field="title" caption="발견사항명" min-width="200" />
        <DxColumn data-field="relatedControl" caption="관련 통제" width="130" />
        <DxColumn data-field="severity" caption="심각도" width="90" cell-template="severityTemplate" />
        <DxColumn data-field="dept" caption="담당 부서" width="120" />
        <DxColumn data-field="owner" caption="담당자" width="100" />
        <DxColumn data-field="discoveryDate" caption="발견일" width="105" />
        <DxColumn data-field="dueDate" caption="조치 기한" width="105" cell-template="dueDateTemplate" />
        <DxColumn data-field="status" caption="상태" width="100" cell-template="statusTemplate" />
        <DxColumn caption="관리" width="100" cell-template="actionTemplate" :allow-sorting="false" />

        <template #titleTemplate>
          <div style="font-weight: 600; font-size: 15px; color: #1a3a6b; padding: 4px 0">
            발견사항 목록 ({{ filteredFindings.length }}건)
          </div>
        </template>
        <template #severityTemplate="{ data }">
          <span class="badge" :class="`badge-${getSeverityClass(data.value)}`">{{ data.value }}</span>
        </template>
        <template #dueDateTemplate="{ data }">
          <span :class="{ 'text-danger fw-bold': isOverdue(data.value) }">
            {{ data.value }}{{ isOverdue(data.value) ? ' (초과)' : '' }}
          </span>
        </template>
        <template #statusTemplate="{ data }">
          <span class="badge" :class="`badge-${getStatusClass(data.value)}`">{{ data.value }}</span>
        </template>
        <template #actionTemplate="{ data }">
          <div class="action-btns">
            <button class="action-btn edit" @click="editFinding(data.data)" title="수정">✏</button>
            <button class="action-btn view" @click="viewFinding(data.data)" title="상세">👁</button>
          </div>
        </template>
        <template #detailTemplate="{ data }">
          <div class="finding-detail">
            <div class="detail-section">
              <div class="detail-label">발견사항 설명</div>
              <div class="detail-value">{{ data.data.description }}</div>
            </div>
            <div class="detail-section">
              <div class="detail-label">위험 영향</div>
              <div class="detail-value">{{ data.data.riskImpact }}</div>
            </div>
            <div class="detail-section">
              <div class="detail-label">근본 원인</div>
              <div class="detail-value">{{ data.data.rootCause }}</div>
            </div>
            <div class="detail-section">
              <div class="detail-label">개선 권고사항</div>
              <div class="detail-value">{{ data.data.recommendation }}</div>
            </div>
          </div>
        </template>
      </DxDataGrid>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxDataGrid, { DxColumn, DxPaging, DxPager, DxSearchPanel, DxToolbar, DxItem } from 'devextreme-vue/data-grid'
import DxSelectBox from 'devextreme-vue/select-box'
import dayjs from 'dayjs'

const showDialog = ref(false)
const filters = ref({ severity: null, status: null, dept: null, type: null })
const deptOptions = ['IT운영팀', '개발팀', '정보보안팀', 'IT인프라팀', 'DBA팀', 'HR시스템팀']

const findingStats = ref([
  { id: 1, icon: '🔍', iconType: 'primary', label: '전체 발견사항', value: '47건', change: '누적', changeType: 'neutral' },
  { id: 2, icon: '⚠', iconType: 'danger', label: '미결', value: '24건', change: '51.1%', changeType: 'up' },
  { id: 3, icon: '⏰', iconType: 'warning', label: '기한 초과', value: '7건', change: '즉시 조치 필요', changeType: 'up' },
  { id: 4, icon: '✓', iconType: 'success', label: '조치 완료', value: '23건', change: '48.9%', changeType: 'down' }
])

const findings = ref([
  {
    id: 1, findingNo: 'FND-2026-001', findingType: '운영평가', title: '관리자 계정 다중 사용 발견',
    relatedControl: 'CTRL-ACC-001', severity: '심각', dept: '정보보안팀', owner: '이보안',
    discoveryDate: '2026-03-07', dueDate: '2026-03-15', status: '조치중',
    description: '복수의 사용자가 동일한 관리자 계정 자격증명을 공유하여 사용하고 있음이 발견됨',
    riskImpact: '개인 책임 추적 불가능, 권한 남용 위험 증가',
    rootCause: '개인 계정 발급 절차가 명확하지 않고, 관리자 계정 관리 정책이 미비함',
    recommendation: '개인별 관리자 계정 발급 및 MFA 적용, 공유 계정 즉시 삭제'
  },
  {
    id: 2, findingNo: 'FND-2026-002', findingType: '운영평가', title: '퇴직자 계정 15건 미삭제',
    relatedControl: 'CTRL-ACC-002', severity: '높음', dept: 'HR시스템팀', owner: '최시스템',
    discoveryDate: '2026-03-14', dueDate: '2026-03-10', status: '기한초과',
    description: '반기 재검토 결과, 2025년 하반기 퇴직자 15명의 시스템 계정이 삭제되지 않고 활성 상태로 유지됨',
    riskImpact: '퇴직자의 불법 접근 가능성, 정보 유출 위험',
    rootCause: 'HR 시스템과 IT 시스템 간의 퇴직 정보 연동 프로세스 미비',
    recommendation: 'HR-IT 시스템 연동 자동화, 퇴직 당일 계정 비활성화 프로세스 수립'
  },
  {
    id: 3, findingNo: 'FND-2026-003', findingType: '운영평가', title: '미승인 변경 3건 발생',
    relatedControl: 'CTRL-CHG-001', severity: '높음', dept: '개발팀', owner: '김개발',
    discoveryDate: '2026-03-21', dueDate: '2026-04-05', status: '조치완료',
    description: '긴급 상황을 이유로 승인 없이 운영 환경에 직접 변경이 적용된 사례 3건 발견',
    riskImpact: '운영 환경 안정성 위협, 추적 불가 변경으로 인한 오류 발생 가능',
    rootCause: '긴급변경 절차가 명확하지 않으며, 사후 승인 처리도 미이행',
    recommendation: '긴급변경 절차 수립, 사후 승인 의무화 및 모니터링 강화'
  },
  {
    id: 4, findingNo: 'FND-2026-004', findingType: '운영평가', title: '배치 오류 무감지 운영',
    relatedControl: 'CTRL-OPS-001', severity: '중간', dept: 'IT운영팀', owner: '박운영',
    discoveryDate: '2026-02-25', dueDate: '2026-04-30', status: '조치중',
    description: '야간 배치 처리 실패 시 담당자에게 알림이 전달되지 않아 다음날 오전까지 오류가 방치되는 상황 발생',
    riskImpact: '데이터 처리 지연, 보고서 오류 및 재무 데이터 부정확성 가능',
    rootCause: '모니터링 시스템의 알람 정책 미수립 및 에스컬레이션 체계 부재',
    recommendation: '배치 모니터링 솔루션 도입 및 알람 임계값 설정, 에스컬레이션 체계 수립'
  },
  {
    id: 5, findingNo: 'FND-2026-005', findingType: '내부감사', title: '데이터 정합성 검증 누락',
    relatedControl: 'CTRL-DATA-001', severity: '중간', dept: 'DBA팀', owner: '김DBA',
    discoveryDate: '2026-02-10', dueDate: '2026-05-31', status: '미결',
    description: 'ERP와 분석 시스템 간 데이터 전송 시 무결성 검증 절차가 수행되지 않음',
    riskImpact: '경영 의사결정에 활용되는 데이터의 신뢰성 저하',
    rootCause: '시스템 인터페이스 설계 시 무결성 검증 요건이 반영되지 않음',
    recommendation: '데이터 전송 전후 해시값 검증 로직 구현, 정기 데이터 정합성 점검 수행'
  }
])

const filteredFindings = computed(() => {
  return findings.value.filter(f => {
    if (filters.value.severity && f.severity !== filters.value.severity) return false
    if (filters.value.status && f.status !== filters.value.status) return false
    if (filters.value.dept && f.dept !== filters.value.dept) return false
    if (filters.value.type && f.findingType !== filters.value.type) return false
    return true
  })
})

function isOverdue(dueDate) {
  return dayjs(dueDate).isBefore(dayjs(), 'day')
}

function getSeverityClass(val) {
  const map = { '심각': 'critical', '높음': 'high', '중간': 'medium', '낮음': 'low' }
  return map[val] || 'minimal'
}

function getStatusClass(val) {
  const map = { '조치완료': 'effective', '조치중': 'partial', '기한초과': 'ineffective', '미결': 'not-tested', '수용': 'low' }
  return map[val] || 'not-tested'
}

function resetFilters() {
  filters.value = { severity: null, status: null, dept: null, type: null }
}

function editFinding(f) { console.log('Edit:', f) }
function viewFinding(f) { console.log('View:', f) }
</script>

<style lang="scss" scoped>
.filter-row {
  display: flex;
  align-items: flex-end;
  gap: 16px;
  flex-wrap: wrap;
}

.filter-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.filter-label {
  font-size: 12px;
  font-weight: 500;
  color: #495057;
}

.finding-detail {
  padding: 16px 24px;
  background: #f8f9fa;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.detail-section {
  .detail-label {
    font-size: 11px;
    font-weight: 600;
    color: #868e96;
    text-transform: uppercase;
    margin-bottom: 4px;
  }

  .detail-value {
    font-size: 13px;
    color: #343a40;
    line-height: 1.5;
  }
}

.action-btns {
  display: flex;
  gap: 4px;
}

.action-btn {
  width: 28px;
  height: 28px;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  background: white;
  cursor: pointer;
  font-size: 13px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.15s;

  &.edit:hover { background: #e8f0fe; border-color: #1a3a6b; }
  &.view:hover { background: #e8f5e9; border-color: #27ae60; }
}
</style>
