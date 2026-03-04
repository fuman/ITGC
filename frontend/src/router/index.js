import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('@/views/dashboard/DashboardView.vue'),
    meta: { title: '대시보드', icon: 'dashboard', breadcrumb: ['대시보드'] }
  },

  // ===== 위험 관리 =====
  {
    path: '/risk',
    meta: { title: '위험 관리', group: 'risk' },
    children: [
      {
        path: '',
        redirect: '/risk/identification'
      },
      {
        path: 'identification',
        name: 'RiskIdentification',
        component: () => import('@/views/risk/RiskIdentificationView.vue'),
        meta: { title: '위험 식별', breadcrumb: ['위험 관리', '위험 식별'] }
      },
      {
        path: 'assessment',
        name: 'RiskAssessment',
        component: () => import('@/views/risk/RiskAssessmentView.vue'),
        meta: { title: '위험 평가', breadcrumb: ['위험 관리', '위험 평가'] }
      },
      {
        path: 'response',
        name: 'RiskResponse',
        component: () => import('@/views/risk/RiskResponseView.vue'),
        meta: { title: '위험 대응', breadcrumb: ['위험 관리', '위험 대응'] }
      },
      {
        path: 'matrix',
        name: 'RiskMatrix',
        component: () => import('@/views/risk/RiskMatrixView.vue'),
        meta: { title: '위험 매트릭스', breadcrumb: ['위험 관리', '위험 매트릭스'] }
      }
    ]
  },

  // ===== 통제 활동 =====
  {
    path: '/control',
    meta: { title: '통제 활동', group: 'control' },
    children: [
      {
        path: '',
        redirect: '/control/list'
      },
      {
        path: 'list',
        name: 'ControlList',
        component: () => import('@/views/control/ControlListView.vue'),
        meta: { title: '통제 목록', breadcrumb: ['통제 활동', '통제 목록'] }
      },
      {
        path: 'design',
        name: 'ControlDesign',
        component: () => import('@/views/control/ControlDesignView.vue'),
        meta: { title: '통제 설계', breadcrumb: ['통제 활동', '통제 설계'] }
      },
      {
        path: 'mapping',
        name: 'ControlMapping',
        component: () => import('@/views/control/ControlMappingView.vue'),
        meta: { title: '위험-통제 매핑', breadcrumb: ['통제 활동', '위험-통제 매핑'] }
      }
    ]
  },

  // ===== 운영 평가 =====
  {
    path: '/evaluation',
    meta: { title: '운영 평가', group: 'evaluation' },
    children: [
      {
        path: '',
        redirect: '/evaluation/plan'
      },
      {
        path: 'plan',
        name: 'EvaluationPlan',
        component: () => import('@/views/evaluation/EvaluationPlanView.vue'),
        meta: { title: '평가 계획', breadcrumb: ['운영 평가', '평가 계획'] }
      },
      {
        path: 'execution',
        name: 'EvaluationExecution',
        component: () => import('@/views/evaluation/EvaluationExecutionView.vue'),
        meta: { title: '평가 실행', breadcrumb: ['운영 평가', '평가 실행'] }
      },
      {
        path: 'result',
        name: 'EvaluationResult',
        component: () => import('@/views/evaluation/EvaluationResultView.vue'),
        meta: { title: '평가 결과', breadcrumb: ['운영 평가', '평가 결과'] }
      }
    ]
  },

  // ===== 발견사항 관리 =====
  {
    path: '/findings',
    meta: { title: '발견사항 관리', group: 'findings' },
    children: [
      {
        path: '',
        redirect: '/findings/list'
      },
      {
        path: 'list',
        name: 'FindingsList',
        component: () => import('@/views/findings/FindingsListView.vue'),
        meta: { title: '발견사항 목록', breadcrumb: ['발견사항 관리', '발견사항 목록'] }
      },
      {
        path: 'remediation',
        name: 'Remediation',
        component: () => import('@/views/findings/RemediationView.vue'),
        meta: { title: '개선 조치', breadcrumb: ['발견사항 관리', '개선 조치'] }
      }
    ]
  },

  // ===== 보고서 =====
  {
    path: '/reports',
    name: 'Reports',
    component: () => import('@/views/reports/ReportsView.vue'),
    meta: { title: '보고서', breadcrumb: ['보고서'] }
  },

  // ===== 시스템 설정 =====
  {
    path: '/settings',
    meta: { title: '시스템 설정', group: 'settings' },
    children: [
      {
        path: '',
        redirect: '/settings/organization'
      },
      {
        path: 'organization',
        name: 'Organization',
        component: () => import('@/views/settings/OrganizationView.vue'),
        meta: { title: '조직 관리', breadcrumb: ['설정', '조직 관리'] }
      },
      {
        path: 'users',
        name: 'Users',
        component: () => import('@/views/settings/UsersView.vue'),
        meta: { title: '사용자 관리', breadcrumb: ['설정', '사용자 관리'] }
      },
      {
        path: 'coso-config',
        name: 'CosoConfig',
        component: () => import('@/views/settings/CosoConfigView.vue'),
        meta: { title: 'COSO 설정', breadcrumb: ['설정', 'COSO 설정'] }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  }
})

router.beforeEach((to, from, next) => {
  document.title = to.meta?.title ? `${to.meta.title} | ITGC 포털` : 'ITGC 포털'
  next()
})

export default router
