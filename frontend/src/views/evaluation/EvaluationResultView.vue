<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">평가 결과</h1>
          <p class="page-subtitle">{{ evalStore.periodLabel }} 운영평가 종합 결과입니다</p>
        </div>
        <div class="d-flex gap-8">
          <DxButton text="결과 보고서" icon="file" type="normal" @click="generateReport" />
          <DxButton text="Excel 다운로드" icon="exportxlsx" type="default" />
        </div>
      </div>
    </div>

    <!-- Result Summary -->
    <div class="stat-cards" style="margin-bottom: 20px">
      <div v-for="s in resultStats" :key="s.id" class="stat-card">
        <div class="stat-icon" :class="`icon-${s.iconType}`">{{ s.icon }}</div>
        <div class="stat-info">
          <div class="stat-label">{{ s.label }}</div>
          <div class="stat-value">{{ s.value }}</div>
          <div class="stat-change" :class="s.changeType">{{ s.change }}</div>
        </div>
      </div>
    </div>

    <!-- Charts Row -->
    <div class="grid-2" style="margin-bottom: 20px">
      <!-- Effectiveness by Domain -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">도메인별 효과성 현황</div>
        </div>
        <DxChart :data-source="domainEffectiveness">
          <DxSeries argument-field="domain" value-field="effective" name="효과적" color="#27ae60" type="bar" />
          <DxSeries argument-field="domain" value-field="partial" name="부분효과적" color="#f39c12" type="bar" />
          <DxSeries argument-field="domain" value-field="ineffective" name="비효과적" color="#e74c3c" type="bar" />
          <DxArgumentAxis>
            <DxLabel :word-wrap="'none'" />
          </DxArgumentAxis>
          <DxLegend vertical-alignment="bottom" horizontal-alignment="center" />
          <DxTooltip :enabled="true" />
          <DxCommonSeriesSettings :bar-overlap-group="'group1'" />
        </DxChart>
      </div>

      <!-- Trend Chart -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">효과성 추이 (분기별)</div>
        </div>
        <DxChart :data-source="trendData">
          <DxSeries argument-field="period" value-field="effectiveRate" name="효과적 비율(%)" type="line" color="#27ae60">
            <DxPoint :visible="true" />
          </DxSeries>
          <DxSeries argument-field="period" value-field="exceptionRate" name="예외율(%)" type="line" color="#e74c3c">
            <DxPoint :visible="true" />
          </DxSeries>
          <DxLegend vertical-alignment="bottom" horizontal-alignment="center" />
          <DxTooltip :enabled="true" />
          <DxValueAxis :value-range="{ min: 0, max: 100 }">
            <DxTitle text="비율(%)" />
          </DxValueAxis>
        </DxChart>
      </div>
    </div>

    <!-- Result Table -->
    <div class="section">
      <div class="section-header">
        <div class="section-title">통제별 평가 결과</div>
      </div>
      <div class="card" style="padding: 0">
        <DxDataGrid
          :data-source="evaluationResults"
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
          <DxSearchPanel :visible="true" placeholder="검색..." />
          <DxPaging :page-size="15" />
          <DxPager :show-info="true" />

          <DxColumn data-field="controlCode" caption="통제 코드" width="130" />
          <DxColumn data-field="controlName" caption="통제명" min-width="180" />
          <DxColumn data-field="domain" caption="도메인" width="110" />
          <DxColumn data-field="sampleCount" caption="샘플 수" width="80" alignment="center" />
          <DxColumn data-field="exceptionCount" caption="예외 수" width="80" alignment="center" cell-template="exceptionTemplate" />
          <DxColumn data-field="exceptionRate" caption="예외율" width="80" alignment="center" cell-template="rateTemplate" />
          <DxColumn data-field="effectiveness" caption="효과성" width="120" cell-template="effectTemplate" />
          <DxColumn data-field="findingCreated" caption="발견사항" width="90" alignment="center" cell-template="findingTemplate" />
          <DxColumn data-field="evaluator" caption="평가자" width="100" />
          <DxColumn data-field="evaluationDate" caption="평가 완료일" width="115" />

          <template #titleTemplate>
            <div style="font-weight: 600; font-size: 15px; color: #1a3a6b; padding: 4px 0">
              운영평가 결과 ({{ evaluationResults.length }}건)
            </div>
          </template>
          <template #exceptionTemplate="{ data }">
            <span :style="{ color: data.value > 0 ? '#e74c3c' : '#27ae60', fontWeight: '600' }">
              {{ data.value }}
            </span>
          </template>
          <template #rateTemplate="{ data }">
            <span :style="{ color: data.value > 10 ? '#e74c3c' : data.value > 0 ? '#f39c12' : '#27ae60', fontWeight: '600' }">
              {{ data.value }}%
            </span>
          </template>
          <template #effectTemplate="{ data }">
            <span class="badge" :class="`badge-${getEffectClass(data.value)}`">{{ data.value }}</span>
          </template>
          <template #findingTemplate="{ data }">
            <span v-if="data.value > 0" class="badge badge-high">{{ data.value }}건</span>
            <span v-else class="text-muted" style="font-size: 12px">-</span>
          </template>
          <template #detailTemplate="{ data }">
            <div class="detail-panel">
              <div class="detail-grid">
                <div>
                  <div class="detail-label">평가 기간</div>
                  <div class="detail-value">{{ data.data.startDate }} ~ {{ data.data.endDate }}</div>
                </div>
                <div>
                  <div class="detail-label">평가 의견</div>
                  <div class="detail-value">{{ data.data.comment }}</div>
                </div>
                <div>
                  <div class="detail-label">개선 권고사항</div>
                  <div class="detail-value">{{ data.data.recommendation || '-' }}</div>
                </div>
              </div>
            </div>
          </template>
        </DxDataGrid>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxDataGrid, { DxColumn, DxPaging, DxPager, DxSearchPanel, DxToolbar, DxItem } from 'devextreme-vue/data-grid'
import { DxChart, DxSeries, DxArgumentAxis, DxValueAxis, DxTitle, DxLabel, DxLegend, DxTooltip, DxPoint, DxCommonSeriesSettings } from 'devextreme-vue/chart'
import { useEvaluationStore } from '@/store'

const evalStore = useEvaluationStore()

const resultStats = ref([
  { id: 1, icon: '📊', iconType: 'primary', label: '평가 완료 통제', value: '28건', change: '전체 100% 완료', changeType: 'neutral' },
  { id: 2, icon: '✓', iconType: 'success', label: '효과적', value: '20건', change: '71.4%', changeType: 'down' },
  { id: 3, icon: '⚠', iconType: 'warning', label: '부분 효과적', value: '6건', change: '21.4%', changeType: 'neutral' },
  { id: 4, icon: '✗', iconType: 'danger', label: '비효과적', value: '2건', change: '7.1%', changeType: 'up' }
])

const domainEffectiveness = ref([
  { domain: '접근통제', effective: 20, partial: 5, ineffective: 3 },
  { domain: '변경관리', effective: 18, partial: 3, ineffective: 1 },
  { domain: 'IT운영', effective: 24, partial: 4, ineffective: 2 },
  { domain: '업무연속성', effective: 11, partial: 3, ineffective: 1 },
  { domain: '정보보안', effective: 12, partial: 3, ineffective: 1 }
])

const trendData = ref([
  { period: '2025 Q1', effectiveRate: 68, exceptionRate: 12 },
  { period: '2025 Q2', effectiveRate: 72, exceptionRate: 10 },
  { period: '2025 Q3', effectiveRate: 75, exceptionRate: 8 },
  { period: '2025 Q4', effectiveRate: 78, exceptionRate: 7 },
  { period: '2026 Q1', effectiveRate: 80, exceptionRate: 5 }
])

const evaluationResults = ref([
  { id: 1, controlCode: 'CTRL-ACC-001', controlName: '사용자 계정 등록/변경/삭제 승인', domain: '접근통제', sampleCount: 25, exceptionCount: 1, exceptionRate: 4, effectiveness: '부분 효과적', findingCreated: 1, evaluator: '이보안', evaluationDate: '2026-03-07', startDate: '2026-03-01', endDate: '2026-03-07', comment: '전반적으로 효과적이나 일부 미승인 권한 변경 발견', recommendation: '권한 변경 승인 프로세스 자동화 필요' },
  { id: 2, controlCode: 'CTRL-ACC-002', controlName: '특권 계정 반기 재검토', domain: '접근통제', sampleCount: 1, exceptionCount: 1, exceptionRate: 100, effectiveness: '비효과적', findingCreated: 1, evaluator: '이보안', evaluationDate: '2026-03-14', startDate: '2026-03-08', endDate: '2026-03-14', comment: '반기 재검토 수행되었으나 15개 퇴직자 계정 미삭제 발견', recommendation: '퇴직자 계정 즉시 삭제 및 자동화 체계 구축' },
  { id: 3, controlCode: 'CTRL-CHG-001', controlName: '변경 요청 및 승인 관리', domain: '변경관리', sampleCount: 30, exceptionCount: 2, exceptionRate: 7, effectiveness: '부분 효과적', findingCreated: 1, evaluator: '박검토', evaluationDate: '2026-03-21', startDate: '2026-03-15', endDate: '2026-03-21', comment: '대부분의 변경은 승인 절차를 준수하나 긴급변경 시 절차 미준수 발견', recommendation: '긴급변경 절차 재정비 필요' },
  { id: 4, controlCode: 'CTRL-CHG-002', controlName: '변경 후 테스트 및 검증', domain: '변경관리', sampleCount: 25, exceptionCount: 0, exceptionRate: 0, effectiveness: '효과적', findingCreated: 0, evaluator: '박검토', evaluationDate: '2026-03-21', startDate: '2026-03-15', endDate: '2026-03-21', comment: '변경 후 테스트 절차가 일관되게 수행됨', recommendation: '' }
])

function getEffectClass(val) {
  const map = { '효과적': 'effective', '부분 효과적': 'partial', '비효과적': 'ineffective', '미평가': 'not-tested' }
  return map[val] || 'not-tested'
}

function generateReport() {
  console.log('Generating report...')
}
</script>

<style lang="scss" scoped>
.detail-panel {
  padding: 16px 24px;
  background: #f8f9fa;
}

.detail-grid {
  display: grid;
  grid-template-columns: 200px 1fr 1fr;
  gap: 20px;
}

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
</style>
