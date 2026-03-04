import { defineStore } from 'pinia'

// ===== App Store =====
export const useAppStore = defineStore('app', {
  state: () => ({
    sidebarCollapsed: false,
    currentYear: new Date().getFullYear(),
    loading: false,
    notifications: []
  }),
  actions: {
    toggleSidebar() {
      this.sidebarCollapsed = !this.sidebarCollapsed
    },
    setLoading(val) {
      this.loading = val
    }
  }
})

// ===== Risk Store =====
export const useRiskStore = defineStore('risk', {
  state: () => ({
    risks: [],
    riskCategories: [
      { id: 1, code: 'IT-OPS', name: 'IT 운영 위험' },
      { id: 2, code: 'IT-SEC', name: '정보보안 위험' },
      { id: 3, code: 'IT-CHG', name: '변경관리 위험' },
      { id: 4, code: 'IT-ACC', name: '접근통제 위험' },
      { id: 5, code: 'IT-BCM', name: '업무연속성 위험' },
      { id: 6, code: 'IT-DATA', name: '데이터 무결성 위험' }
    ],
    riskLevels: ['심각', '높음', '중간', '낮음', '미미'],
    selectedRisk: null
  }),
  getters: {
    riskCount: (state) => state.risks.length,
    criticalRisks: (state) => state.risks.filter(r => r.inherentRisk === '심각' || r.inherentRisk === '높음')
  }
})

// ===== Control Store =====
export const useControlStore = defineStore('control', {
  state: () => ({
    controls: [],
    controlTypes: [
      { id: 1, name: '예방통제', code: 'PREVENT' },
      { id: 2, name: '탐지통제', code: 'DETECT' },
      { id: 3, name: '교정통제', code: 'CORRECT' }
    ],
    controlFrequencies: ['상시', '일일', '주간', '월간', '분기', '반기', '연간'],
    selectedControl: null
  })
})

// ===== Evaluation Store =====
export const useEvaluationStore = defineStore('evaluation', {
  state: () => ({
    evaluations: [],
    currentPeriod: {
      year: new Date().getFullYear(),
      quarter: Math.ceil((new Date().getMonth() + 1) / 3)
    },
    selectedEvaluation: null
  }),
  getters: {
    periodLabel: (state) =>
      `${state.currentPeriod.year}년 ${state.currentPeriod.quarter}분기`
  }
})
