import axios from 'axios'

const api = axios.create({
  baseURL: '/api/v1',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// Request interceptor: JWT 토큰 추가
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('itgc_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Response interceptor: 에러 처리
api.interceptors.response.use(
  (response) => response.data,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('itgc_token')
      window.location.href = '/login'
    }
    return Promise.reject(error.response?.data || error.message)
  }
)

// ===== 대시보드 API =====
export const dashboardApi = {
  getDashboard: (year, quarter) => api.get('/dashboard', { params: { year, quarter } }),
  getCosoOverview: (year, quarter) => api.get('/dashboard/coso-overview', { params: { year, quarter } }),
  getKpi: (year, quarter) => api.get('/dashboard/kpi', { params: { year, quarter } }),
  getRiskDistribution: (year) => api.get('/dashboard/risk-distribution', { params: { year } })
}

// ===== 위험 관리 API =====
export const riskApi = {
  getAll: (params) => api.get('/risks', { params }),
  getById: (id) => api.get(`/risks/${id}`),
  create: (data) => api.post('/risks', data),
  update: (id, data) => api.put(`/risks/${id}`, data),
  delete: (id) => api.delete(`/risks/${id}`),
  getMatrix: (type) => api.get('/risks/matrix', { params: { type } }),
  getSummary: () => api.get('/risks/summary'),
  saveAssessment: (data) => api.post('/risks/assessment', data)
}

// ===== 통제 활동 API =====
export const controlApi = {
  getAll: (params) => api.get('/controls', { params }),
  getById: (id) => api.get(`/controls/${id}`),
  create: (data) => api.post('/controls', data),
  update: (id, data) => api.put(`/controls/${id}`, data),
  delete: (id) => api.delete(`/controls/${id}`),
  getMapping: () => api.get('/controls/mapping'),
  saveDesignEvaluation: (data) => api.post('/controls/design-evaluation', data),
  getDomainSummary: () => api.get('/controls/summary/domain')
}

// ===== 운영 평가 API =====
export const evaluationApi = {
  getPlans: (year, quarter) => api.get('/evaluation/plans', { params: { year, quarter } }),
  getPlanById: (id) => api.get(`/evaluation/plans/${id}`),
  createPlan: (data) => api.post('/evaluation/plans', data),
  updatePlan: (id, data) => api.put(`/evaluation/plans/${id}`, data),
  getSamples: (planId) => api.get(`/evaluation/plans/${planId}/samples`),
  saveSample: (planId, data) => api.post(`/evaluation/plans/${planId}/samples`, data),
  saveConclusion: (planId, data) => api.post(`/evaluation/plans/${planId}/conclusion`, data),
  getResults: (year, quarter) => api.get('/evaluation/results', { params: { year, quarter } })
}

// ===== 발견사항 API =====
export const findingApi = {
  getAll: (params) => api.get('/findings', { params }),
  getById: (id) => api.get(`/findings/${id}`),
  create: (data) => api.post('/findings', data),
  update: (id, data) => api.put(`/findings/${id}`, data),
  delete: (id) => api.delete(`/findings/${id}`),
  getSummary: () => api.get('/findings/summary'),
  getOverdue: () => api.get('/findings/overdue'),
  updateRemediation: (id, data) => api.patch(`/findings/${id}/remediation`, data)
}

// ===== 보고서 API =====
export const reportApi = {
  getList: () => api.get('/reports'),
  generate: (data) => api.post('/reports/generate', data),
  download: (id) => api.get(`/reports/${id}/download`, { responseType: 'blob' })
}

// ===== 설정 API =====
export const settingApi = {
  getOrganizations: () => api.get('/settings/organizations'),
  createOrganization: (data) => api.post('/settings/organizations', data),
  getUsers: () => api.get('/settings/users'),
  createUser: (data) => api.post('/settings/users', data),
  updateUser: (id, data) => api.put(`/settings/users/${id}`, data),
  getCosoConfig: () => api.get('/settings/coso-config'),
  saveCosoConfig: (data) => api.post('/settings/coso-config', data)
}

export default api
