<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">COSO 설정</h1>
          <p class="page-subtitle">COSO 2013 프레임워크 기반 위험 평가 기준 및 통제 수준을 설정합니다</p>
        </div>
        <DxButton text="설정 저장" icon="save" type="default" @click="saveConfig" />
      </div>
    </div>

    <!-- Risk Scoring Matrix Config -->
    <div class="section">
      <div class="section-header">
        <div class="section-title">위험 평가 기준 설정</div>
      </div>
      <div class="grid-2">
        <div class="card">
          <div class="card-header">
            <div class="card-title">발생 가능성 기준</div>
          </div>
          <DxDataGrid :data-source="likelihoodConfig" :show-borders="false" key-expr="level">
            <DxEditing mode="cell" :allow-updating="true" />
            <DxColumn data-field="level" caption="수준" width="60" :allow-editing="false" alignment="center" />
            <DxColumn data-field="label" caption="등급명" width="100" />
            <DxColumn data-field="description" caption="기준 설명" />
            <DxColumn data-field="frequency" caption="발생 빈도" width="120" />
          </DxDataGrid>
        </div>

        <div class="card">
          <div class="card-header">
            <div class="card-title">영향도 기준</div>
          </div>
          <DxDataGrid :data-source="impactConfig" :show-borders="false" key-expr="level">
            <DxEditing mode="cell" :allow-updating="true" />
            <DxColumn data-field="level" caption="수준" width="60" :allow-editing="false" alignment="center" />
            <DxColumn data-field="label" caption="등급명" width="100" />
            <DxColumn data-field="description" caption="기준 설명" />
            <DxColumn data-field="financialImpact" caption="재무적 영향" width="120" />
          </DxDataGrid>
        </div>
      </div>
    </div>

    <!-- Risk Level Thresholds -->
    <div class="section">
      <div class="section-header">
        <div class="section-title">위험 수준 임계값 설정</div>
      </div>
      <div class="card">
        <div class="threshold-grid">
          <div v-for="threshold in riskThresholds" :key="threshold.level" class="threshold-item" :class="`threshold-${threshold.cssClass}`">
            <div class="threshold-header">
              <span class="badge" :class="`badge-${threshold.cssClass}`">{{ threshold.level }}</span>
              <span class="threshold-range">점수 범위</span>
            </div>
            <div class="threshold-values">
              <DxNumberBox v-model:value="threshold.min" :min="1" :max="25" width="80" />
              <span>~</span>
              <DxNumberBox v-model:value="threshold.max" :min="1" :max="25" width="80" />
            </div>
            <div class="threshold-action">
              <label class="filter-label">대응 전략</label>
              <DxSelectBox v-model:value="threshold.defaultResponse" :items="['완화', '이전', '수용', '회피']" width="120" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- COSO Component Weights -->
    <div class="section">
      <div class="section-header">
        <div class="section-title">COSO 구성요소 가중치</div>
      </div>
      <div class="card">
        <div class="weight-note">
          <span class="badge badge-info">ℹ</span>
          전체 가중치의 합은 100%여야 합니다. 현재 합계: <strong :class="totalWeight === 100 ? 'text-success' : 'text-danger'">{{ totalWeight }}%</strong>
        </div>
        <div class="weight-grid">
          <div v-for="comp in cosoWeights" :key="comp.id" class="weight-item">
            <div class="weight-header">
              <span class="weight-icon">{{ comp.icon }}</span>
              <div>
                <div class="weight-name">{{ comp.name }}</div>
                <div class="weight-en">{{ comp.nameEn }}</div>
              </div>
            </div>
            <div class="weight-control">
              <DxSlider
                v-model:value="comp.weight"
                :min="0"
                :max="50"
                :step="5"
                width="200"
              />
              <div class="weight-value">{{ comp.weight }}%</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Evaluation Settings -->
    <div class="section">
      <div class="section-header">
        <div class="section-title">운영평가 설정</div>
      </div>
      <div class="card">
        <div class="eval-settings">
          <div class="setting-item">
            <label class="setting-label">기본 샘플링 방법</label>
            <DxSelectBox v-model:value="evalSettings.defaultSampling" :items="['확률적', '비통계적', '판단적', '전수']" width="200" />
          </div>
          <div class="setting-item">
            <label class="setting-label">예외율 임계값 (%)</label>
            <DxNumberBox v-model:value="evalSettings.exceptionThreshold" :min="0" :max="100" width="100" />
            <span class="setting-hint">초과 시 '비효과적'으로 분류</span>
          </div>
          <div class="setting-item">
            <label class="setting-label">평가 보고서 자동 생성</label>
            <DxCheckBox v-model:value="evalSettings.autoReport" text="활성화" />
          </div>
          <div class="setting-item">
            <label class="setting-label">기한 초과 알림 (일 전)</label>
            <DxNumberBox v-model:value="evalSettings.overdueAlertDays" :min="1" :max="30" width="100" />
            <span class="setting-hint">기한 도래 N일 전 알림</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxDataGrid, { DxColumn, DxEditing } from 'devextreme-vue/data-grid'
import DxSelectBox from 'devextreme-vue/select-box'
import DxNumberBox from 'devextreme-vue/number-box'
import DxSlider from 'devextreme-vue/slider'
import DxCheckBox from 'devextreme-vue/check-box'

const likelihoodConfig = ref([
  { level: 5, label: '거의 확실', description: '1년 내 발생이 거의 확실함', frequency: '1회 이상/년' },
  { level: 4, label: '높음', description: '1년 내 발생 가능성 높음', frequency: '1-2회/2년' },
  { level: 3, label: '보통', description: '2-5년 내 발생 가능성 있음', frequency: '1회/3-5년' },
  { level: 2, label: '낮음', description: '5-10년 내 발생 가능성 있음', frequency: '1회/5-10년' },
  { level: 1, label: '드묾', description: '10년 이상 발생하지 않을 수 있음', frequency: '1회/10년 이상' }
])

const impactConfig = ref([
  { level: 5, label: '심각', description: '사업 존속 위협', financialImpact: '100억원 이상' },
  { level: 4, label: '높음', description: '중대한 사업 영향', financialImpact: '10-100억원' },
  { level: 3, label: '보통', description: '상당한 운영 영향', financialImpact: '1-10억원' },
  { level: 2, label: '낮음', description: '소규모 운영 영향', financialImpact: '1억원 미만' },
  { level: 1, label: '미미', description: '미미한 영향', financialImpact: '1천만원 미만' }
])

const riskThresholds = ref([
  { level: '심각', cssClass: 'critical', min: 20, max: 25, defaultResponse: '회피' },
  { level: '높음', cssClass: 'high', min: 12, max: 19, defaultResponse: '완화' },
  { level: '중간', cssClass: 'medium', min: 6, max: 11, defaultResponse: '완화' },
  { level: '낮음', cssClass: 'low', min: 3, max: 5, defaultResponse: '수용' },
  { level: '미미', cssClass: 'minimal', min: 1, max: 2, defaultResponse: '수용' }
])

const cosoWeights = ref([
  { id: 1, icon: '🏛', name: '통제 환경', nameEn: 'Control Environment', weight: 25 },
  { id: 2, icon: '⚠', name: '위험 평가', nameEn: 'Risk Assessment', weight: 20 },
  { id: 3, icon: '⚙', name: '통제 활동', nameEn: 'Control Activities', weight: 25 },
  { id: 4, icon: '📡', name: '정보 및 의사소통', nameEn: 'Information & Communication', weight: 15 },
  { id: 5, icon: '📊', name: '모니터링', nameEn: 'Monitoring Activities', weight: 15 }
])

const totalWeight = computed(() => cosoWeights.value.reduce((s, c) => s + c.weight, 0))

const evalSettings = ref({
  defaultSampling: '확률적',
  exceptionThreshold: 10,
  autoReport: true,
  overdueAlertDays: 7
})

function saveConfig() {
  console.log('Saving config...')
}
</script>

<style lang="scss" scoped>
.weight-note {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #495057;
  background: #f8f9fa;
  padding: 10px 14px;
  border-radius: 6px;
  margin-bottom: 20px;
}

.weight-grid {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.weight-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px;
  border: 1px solid #e9ecef;
  border-radius: 8px;

  &:hover { border-color: #1a3a6b; }
}

.weight-header {
  display: flex;
  align-items: center;
  gap: 12px;
}

.weight-icon { font-size: 20px; }

.weight-name {
  font-size: 14px;
  font-weight: 600;
  color: #343a40;
}

.weight-en {
  font-size: 11px;
  color: #868e96;
}

.weight-control {
  display: flex;
  align-items: center;
  gap: 16px;
}

.weight-value {
  font-size: 16px;
  font-weight: 700;
  color: #1a3a6b;
  min-width: 40px;
  text-align: right;
}

// Threshold
.threshold-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 12px;

  @media (max-width: 1200px) {
    grid-template-columns: repeat(3, 1fr);
  }
}

.threshold-item {
  border-radius: 10px;
  padding: 16px;
  border: 1px solid #e9ecef;

  &.threshold-critical { border-top: 3px solid #8b0000; }
  &.threshold-high { border-top: 3px solid #e74c3c; }
  &.threshold-medium { border-top: 3px solid #f39c12; }
  &.threshold-low { border-top: 3px solid #27ae60; }
  &.threshold-minimal { border-top: 3px solid #95a5a6; }
}

.threshold-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.threshold-range {
  font-size: 11px;
  color: #868e96;
}

.threshold-values {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  font-size: 14px;
  color: #495057;
}

.threshold-action {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

// Eval Settings
.eval-settings {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.setting-item {
  display: flex;
  align-items: center;
  gap: 16px;
}

.setting-label {
  font-size: 13px;
  font-weight: 500;
  color: #495057;
  min-width: 200px;
}

.setting-hint {
  font-size: 12px;
  color: #868e96;
}

.filter-label {
  font-size: 12px;
  font-weight: 500;
  color: #495057;
  display: block;
  margin-bottom: 4px;
}
</style>
