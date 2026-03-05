"""
ITGC 포털 구축 과정 정리 PPT 생성 스크립트
- Part 1: 대화 히스토리 (시간순)
- Part 2: 향후 개선된 대화 방법 가이드
"""

from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
import os

prs = Presentation()
prs.slide_width  = Inches(13.33)
prs.slide_height = Inches(7.5)

# ── 색상 팔레트 ──────────────────────────────────────────────
NAVY    = RGBColor(0x1A, 0x2E, 0x4A)
BLUE    = RGBColor(0x1E, 0x6F, 0xC8)
LIGHT   = RGBColor(0xF0, 0xF4, 0xFA)
WHITE   = RGBColor(0xFF, 0xFF, 0xFF)
GRAY    = RGBColor(0x60, 0x60, 0x60)
LGRAY   = RGBColor(0xE8, 0xEC, 0xF2)
ORANGE  = RGBColor(0xE8, 0x6A, 0x1A)
GREEN   = RGBColor(0x1A, 0x9E, 0x5A)
RED     = RGBColor(0xD9, 0x2B, 0x2B)
YELLOW  = RGBColor(0xF0, 0xA5, 0x1A)
PURPLE  = RGBColor(0x6B, 0x2A, 0xC8)
TEAL    = RGBColor(0x1A, 0x8E, 0x9E)

# ── 공통 헬퍼 ────────────────────────────────────────────────
def add_rect(slide, l, t, w, h, color):
    shape = slide.shapes.add_shape(1, Inches(l), Inches(t), Inches(w), Inches(h))
    shape.fill.solid()
    shape.fill.fore_color.rgb = color
    shape.line.fill.background()
    return shape

def add_text_box(slide, text, l, t, w, h,
                 font_size=14, bold=False, color=WHITE,
                 align=PP_ALIGN.LEFT, italic=False):
    txBox = slide.shapes.add_textbox(Inches(l), Inches(t), Inches(w), Inches(h))
    txBox.word_wrap = True
    tf = txBox.text_frame
    tf.word_wrap = True
    para = tf.paragraphs[0]
    para.alignment = align
    run = para.add_run()
    run.text = text
    run.font.size = Pt(font_size)
    run.font.bold = bold
    run.font.italic = italic
    run.font.color.rgb = color
    run.font.name = "맑은 고딕"
    return txBox

def set_slide_bg(slide, color):
    bg = slide.background
    fill = bg.fill
    fill.solid()
    fill.fore_color.rgb = color

def add_header_bar(slide, title, subtitle=None):
    add_rect(slide, 0, 0, 13.33, 1.35, NAVY)
    add_text_box(slide, title, 0.4, 0.15, 10, 0.7,
                 font_size=26, bold=True, color=WHITE)
    if subtitle:
        add_text_box(slide, subtitle, 0.4, 0.82, 12, 0.45,
                     font_size=12, bold=False,
                     color=RGBColor(0xA8, 0xC8, 0xF0))

def add_section_badge(slide, text, color, l=0.35, t=1.52):
    add_rect(slide, l, t, 2.2, 0.35, color)
    add_text_box(slide, text, l, t+0.03, 2.2, 0.3,
                 font_size=10, bold=True, color=WHITE,
                 align=PP_ALIGN.CENTER)

def add_card(slide, title, items, l, t, w=3.9, h=2.2,
             title_color=BLUE, text_color=NAVY, icon="▸"):
    add_rect(slide, l, t, w, h, WHITE)
    border = slide.shapes[-1]
    border.line.color.rgb = title_color
    border.line.width = Pt(1.5)
    add_rect(slide, l, t, w, 0.42, title_color)
    add_text_box(slide, title, l+0.12, t+0.07, w-0.2, 0.32,
                 font_size=12, bold=True, color=WHITE)
    y = t + 0.52
    for item in items:
        add_text_box(slide, f"{icon}  {item}", l+0.15, y, w-0.25, 0.32,
                     font_size=10, color=text_color)
        y += 0.3

# ═══════════════════════════════════════════════════════════
# 슬라이드 1 – 표지
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, NAVY)

add_rect(slide, 9.5, 0, 3.83, 7.5, RGBColor(0x12, 0x20, 0x38))
add_rect(slide, 10.15, 0, 0.08, 7.5, BLUE)

add_text_box(slide, "📋", 0.5, 0.8, 1.5, 1.5, font_size=52, color=BLUE)
add_text_box(slide, "ITGC 포털 구축 과정 정리",
             0.5, 1.8, 8.5, 1.0, font_size=38, bold=True, color=WHITE)
add_text_box(slide, "AI(Claude)와 함께한 시스템 개발 히스토리 & 개선 가이드",
             0.5, 2.75, 8.5, 0.6, font_size=17, bold=False,
             color=RGBColor(0x7A, 0xB4, 0xE8))

add_rect(slide, 0.5, 3.5, 5.0, 0.06, BLUE)

add_text_box(slide,
             "대화 히스토리 시간순 정리\n향후 효율적인 AI 협업 가이드",
             0.5, 3.65, 8.5, 1.0,
             font_size=15, color=RGBColor(0xC0, 0xD8, 0xF0))

add_text_box(slide, "2026.03.05  |  ITGC 포털 프로젝트 팀",
             0.5, 6.8, 6.0, 0.5,
             font_size=12, color=RGBColor(0x70, 0x90, 0xB0))

# 우측 목차 미리보기
toc_right = [
    ("PART 1", "대화 히스토리", BLUE),
    ("PART 2", "개선된 대화 가이드", GREEN),
]
for i, (part, label, col) in enumerate(toc_right):
    ty = 1.5 + i * 2.2
    add_rect(slide, 10.3, ty, 2.6, 1.8, RGBColor(0x1A, 0x2E, 0x4A))
    add_rect(slide, 10.3, ty, 2.6, 0.45, col)
    add_text_box(slide, part, 10.3, ty+0.07, 2.6, 0.35,
                 font_size=11, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    add_text_box(slide, label, 10.3, ty+0.55, 2.6, 0.8,
                 font_size=12, bold=True, color=WHITE, align=PP_ALIGN.CENTER)


# ═══════════════════════════════════════════════════════════
# 슬라이드 2 – 목차
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "목  차", "Contents")

toc_data = [
    # (번호, 파트, 제목, 부제, 색)
    ("01", "PART 1", "프로젝트 전체 개요",      "5단계 구축 여정 한눈에 보기",      BLUE),
    ("02", "PART 1", "Phase 1 — 최초 시스템 구축",  "COSO 포털 기초 설계 및 전체 구현",   BLUE),
    ("03", "PART 1", "Phase 2 — 백엔드 기술 전환", "PostgreSQL + MyBatis 마이그레이션", BLUE),
    ("04", "PART 1", "Phase 3 — 문서화 및 PPT",   "README · 사용자 가이드 PPT 작성",   BLUE),
    ("05", "PART 1", "Phase 4 — 샘플 데이터 구축", "12개 테이블 전체 DML 작성",         BLUE),
    ("06", "PART 2", "AI 협업 회고",              "잘된 점 · 개선이 필요했던 점",       GREEN),
    ("07", "PART 2", "향후 대화 방법 가이드",      "효율적 요청 템플릿 및 원칙",         GREEN),
    ("08", "PART 2", "추천 대화 시나리오 예시",    "단계별 구체적 질문 방법",             GREEN),
]

for i, (num, part, title, sub, col) in enumerate(toc_data):
    row, offset_x = (i, 0.35) if i < 4 else (i-4, 6.85)
    ty = 1.55 + row * 1.18
    add_rect(slide, offset_x, ty, 0.65, 0.85, col)
    add_text_box(slide, num, offset_x, ty+0.18, 0.65, 0.52,
                 font_size=15, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    add_rect(slide, offset_x+0.65, ty, 5.8, 0.85, WHITE)
    bg = slide.shapes[-1]
    bg.line.color.rgb = LGRAY
    bg.line.width = Pt(0.75)
    add_rect(slide, offset_x+0.65, ty, 0.7, 0.85, RGBColor(0xE8, 0xF0, 0xFE) if col==BLUE else RGBColor(0xE8, 0xF8, 0xEE))
    add_text_box(slide, part, offset_x+0.68, ty+0.22, 0.7, 0.32,
                 font_size=7.5, bold=True, color=col, align=PP_ALIGN.CENTER)
    add_text_box(slide, title, offset_x+1.48, ty+0.1, 4.9, 0.38,
                 font_size=12, bold=True, color=NAVY)
    add_text_box(slide, sub, offset_x+1.48, ty+0.48, 4.9, 0.3,
                 font_size=9.5, color=GRAY)


# ═══════════════════════════════════════════════════════════
# 슬라이드 3 – 프로젝트 전체 개요 (타임라인)
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "01  프로젝트 전체 개요", "5단계 구축 여정 · 2026년 3월 4~5일")
add_section_badge(slide, "PART 1 — 히스토리", BLUE)

# 타임라인 수평선
add_rect(slide, 0.5, 3.55, 12.35, 0.1, LGRAY)

phases = [
    ("Phase 1", "최초 구축", "03.04\n오전", "COSO 포털\n전체 구현", BLUE,    0.6),
    ("Phase 2", "기술 전환", "03.04\n오후", "PostgreSQL\nMyBatis 전환", ORANGE, 3.0),
    ("Phase 3", "문서화",    "03.04\n저녁", "README\nPPT 작성",       GREEN,  5.4),
    ("Phase 4", "데이터",    "03.05\n자정", "샘플 데이터\n12테이블",   PURPLE, 7.8),
    ("Phase 5", "정리",      "03.05\n오전", "구축 과정\n정리 PPT",     TEAL,  10.2),
]

for (phase, title, date, desc, col, lx) in phases:
    # 위쪽 박스 (날짜)
    add_rect(slide, lx, 2.25, 2.25, 1.2, WHITE)
    bg = slide.shapes[-1]; bg.line.color.rgb=col; bg.line.width=Pt(1.2)
    add_text_box(slide, date, lx+0.15, 2.32, 1.95, 0.9,
                 font_size=12, bold=True, color=NAVY, align=PP_ALIGN.CENTER)
    # 원형 마커
    add_rect(slide, lx+0.8, 3.42, 0.65, 0.65, col)
    add_text_box(slide, "●", lx+0.8, 3.42, 0.65, 0.65,
                 font_size=18, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    # 아래쪽 박스 (설명)
    add_rect(slide, lx, 4.18, 2.25, 1.7, col)
    add_text_box(slide, phase, lx+0.12, 4.22, 2.0, 0.38,
                 font_size=9, bold=True, color=WHITE)
    add_text_box(slide, title, lx+0.12, 4.55, 2.0, 0.38,
                 font_size=13, bold=True, color=WHITE)
    add_text_box(slide, desc, lx+0.12, 4.95, 2.0, 0.8,
                 font_size=10, color=RGBColor(0xD8, 0xEE, 0xFF))

# 총 성과 요약
add_rect(slide, 0.35, 6.1, 12.65, 1.2, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=NAVY; bg.line.width=Pt(1)
results = [
    ("12개", "DB 테이블"),
    ("14개", "화면 페이지"),
    ("13개", "위험 등록"),
    ("14개", "통제 등록"),
    ("20개", "평가 계획"),
    ("8개",  "발견사항"),
    ("1개",  "사용자 가이드 PPT"),
]
add_text_box(slide, "🏆  구축 성과", 0.5, 6.15, 2.5, 0.38,
             font_size=12, bold=True, color=NAVY)
for i, (val, label) in enumerate(results):
    lx = 0.45 + i * 1.8
    add_text_box(slide, val, lx, 6.55, 1.6, 0.42,
                 font_size=18, bold=True, color=BLUE, align=PP_ALIGN.CENTER)
    add_text_box(slide, label, lx, 6.95, 1.6, 0.28,
                 font_size=9, color=GRAY, align=PP_ALIGN.CENTER)


# ═══════════════════════════════════════════════════════════
# 슬라이드 4 – Phase 1: 최초 시스템 구축
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "02  Phase 1 — 최초 시스템 구축",
               "2026-03-04 오전 · 커밋: feat: COSO 기반 그룹사 ITGC 포털 전체 구현")
add_section_badge(slide, "PART 1 — 히스토리", BLUE)

# 요청 내용
add_rect(slide, 0.35, 1.85, 5.8, 2.3, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=BLUE; bg.line.width=Pt(1.5)
add_rect(slide, 0.35, 1.85, 5.8, 0.42, BLUE)
add_text_box(slide, "💬  사용자 요청 내용", 0.5, 1.9, 5.5, 0.35,
             font_size=12, bold=True, color=WHITE)
req_lines = [
    '• "그룹사 ITGC 포털을 만들어 주세요"',
    '• COSO 2013 프레임워크 기반',
    '• 위험관리, 통제활동, 운영평가, 발견사항, 보고서 기능',
    '• Vue 3 프론트엔드 + Spring Boot 백엔드',
    '• 멀티 그룹사 지원 (조직 계층 구조)',
]
for i, line in enumerate(req_lines):
    add_text_box(slide, line, 0.5, 2.38+i*0.33, 5.6, 0.3,
                 font_size=10, color=NAVY)

# 구현 결과
add_rect(slide, 6.45, 1.85, 6.55, 2.3, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=GREEN; bg.line.width=Pt(1.5)
add_rect(slide, 6.45, 1.85, 6.55, 0.42, GREEN)
add_text_box(slide, "✅  Claude 구현 결과", 6.6, 1.9, 6.2, 0.35,
             font_size=12, bold=True, color=WHITE)
res_lines = [
    "• 프론트엔드: Vue 3 + DevExtreme (14개 화면)",
    "• 백엔드: Spring Boot 3.2 + REST API",
    "• DB: PostgreSQL 12개 테이블 + 트리거/인덱스",
    "• 사용자 인증: Spring Security + JWT",
    "• COSO 5개 구성요소 전체 화면 구현 완료",
]
for i, line in enumerate(res_lines):
    add_text_box(slide, line, 6.6, 2.38+i*0.33, 6.3, 0.3,
                 font_size=10, color=NAVY)

# 세부 구현 내용
detail_cards = [
    ("📊 프론트엔드 (Vue 3)",
     ["로그인 · 대시보드 (COSO KPI)",
      "위험 목록/평가/대응/매트릭스",
      "통제 목록/설계/매핑",
      "운영평가 계획/실행/결과",
      "발견사항/개선조치 Kanban",
      "보고서/조직/사용자/COSO 설정"],
     BLUE, 0.35),
    ("🗄️ DB 스키마 (PostgreSQL)",
     ["itgc_organization (조직 계층)",
      "itgc_user (사용자·역할)",
      "itgc_risk (위험 + 자동 점수 트리거)",
      "itgc_control (통제 + 설계평가)",
      "itgc_risk_control_mapping",
      "itgc_eval_plan/sample/result",
      "itgc_finding/remediation_history/report",
      "itgc_coso_config"],
     ORANGE, 4.55),
    ("⚙️ 백엔드 (Spring Boot)",
     ["Controller-Service-Mapper 3계층",
      "JWT 기반 로그인/토큰 갱신",
      "위험·통제·평가·발견사항 CRUD API",
      "COSO 점수 자동 계산 로직",
      "파일 업로드 (증빙 관리)",
      "역할 기반 권한 제어 (RBAC)"],
     GREEN, 8.75),
]
for title, items, col, lx in detail_cards:
    add_card(slide, title, items, lx, 4.3, w=4.0, h=2.9,
             title_color=col)


# ═══════════════════════════════════════════════════════════
# 슬라이드 5 – Phase 2: 백엔드 기술 전환
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "03  Phase 2 — 백엔드 기술 전환",
               "2026-03-04 오후 · 커밋: feat: PostgreSQL + HikariCP + MyBatis로 백엔드 전환 및 DB 스크립트 추가")
add_section_badge(slide, "PART 1 — 히스토리", BLUE)

# Before → After
add_rect(slide, 0.35, 1.85, 5.8, 1.8, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=RED; bg.line.width=Pt(1.5)
add_rect(slide, 0.35, 1.85, 5.8, 0.42, RED)
add_text_box(slide, "⚠  전환 전 (Before)", 0.5, 1.9, 5.5, 0.35,
             font_size=12, bold=True, color=WHITE)
before = [
    "• JPA / Spring Data JPA (ORM)",
    "• H2 In-memory 데이터베이스",
    "• 복잡한 쿼리 커스터마이징 어려움",
    "• 재시작 시 데이터 초기화 문제",
]
for i, b in enumerate(before):
    add_text_box(slide, b, 0.5, 2.38+i*0.3, 5.6, 0.28,
                 font_size=10, color=RGBColor(0x80, 0x10, 0x10))

add_text_box(slide, "→", 6.3, 2.45, 0.8, 0.8,
             font_size=36, bold=True, color=BLUE, align=PP_ALIGN.CENTER)

add_rect(slide, 7.2, 1.85, 5.8, 1.8, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=GREEN; bg.line.width=Pt(1.5)
add_rect(slide, 7.2, 1.85, 5.8, 0.42, GREEN)
add_text_box(slide, "✅  전환 후 (After)", 7.35, 1.9, 5.5, 0.35,
             font_size=12, bold=True, color=WHITE)
after = [
    "• MyBatis (SQL Mapper) 방식",
    "• PostgreSQL 14+ (영구 데이터베이스)",
    "• HikariCP 커넥션 풀 적용",
    "• 세밀한 SQL 제어 및 성능 최적화",
]
for i, a in enumerate(after):
    add_text_box(slide, a, 7.35, 2.38+i*0.3, 5.6, 0.28,
                 font_size=10, color=RGBColor(0x0A, 0x60, 0x30))

# 변경 세부 내용 3개 카드
chg_cards = [
    ("💬  사용자 요청",
     ['• "PostgreSQL 14로 변경해 주세요"',
      '• "JPA 대신 MyBatis 사용해 주세요"',
      '• "HikariCP 설정 추가해 주세요"',
      '• "DB 생성 스크립트 별도 파일로"'],
     ORANGE),
    ("📁  추가된 파일 구조",
     ["db/ddl/01_create_schema.sql",
      "db/ddl/02_create_indexes.sql",
      "db/dml/03_insert_sample_data.sql",
      "backend/src/../mapper/*.xml (MyBatis)",
      "application.yml (HikariCP 설정)"],
     BLUE),
    ("🔧  기술적 개선 포인트",
     ["트리거 기반 위험 점수 자동 계산",
      "GiST 인덱스로 텍스트 검색 최적화",
      "체크 제약조건으로 도메인 무결성",
      "MyBatis dynamic SQL (복잡 쿼리)",
      "트랜잭션 관리 명시적 제어"],
     GREEN),
]
for i, (title, items, col) in enumerate(chg_cards):
    lx = 0.35 + i * 4.33
    add_card(slide, title, items, lx, 3.85, w=4.1, h=2.8, title_color=col)


# ═══════════════════════════════════════════════════════════
# 슬라이드 6 – Phase 3: 문서화 및 PPT
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "04  Phase 3 — 문서화 및 PPT 작성",
               "2026-03-04 저녁 · 커밋: README 업데이트 + 사용자 가이드 PPT 추가")
add_section_badge(slide, "PART 1 — 히스토리", BLUE)

# 좌: README
add_rect(slide, 0.35, 1.85, 6.0, 4.3, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=NAVY; bg.line.width=Pt(1.5)
add_rect(slide, 0.35, 1.85, 6.0, 0.42, NAVY)
add_text_box(slide, "📖  README.md — PC 설치 및 실행 가이드", 0.5, 1.9, 5.7, 0.35,
             font_size=12, bold=True, color=WHITE)
readme_items = [
    ("요청", '"개발 환경 설치 가이드를 README에 작성해 주세요"'),
    ("사전요건", "Node.js 18+, Java 17+, PostgreSQL 14+, Maven"),
    ("DB 설정", "PostgreSQL 설치 → DB 생성 → DDL/DML 실행 순서"),
    ("백엔드", "application.yml 설정 → mvn spring-boot:run"),
    ("프론트", "npm install → npm run dev"),
    ("접속", "http://localhost:5173 (기본 계정: admin/itgc1234)"),
    ("트러블슈팅", "포트 충돌, CORS 설정, DB 연결 오류 해결 방법"),
]
for i, (key, val) in enumerate(readme_items):
    add_rect(slide, 0.45, 2.38+i*0.52, 1.1, 0.38, NAVY)
    add_text_box(slide, key, 0.45, 2.41+i*0.52, 1.1, 0.32,
                 font_size=9, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    add_text_box(slide, val, 1.6, 2.41+i*0.52, 4.6, 0.32,
                 font_size=9.5, color=NAVY)

# 우: PPT
add_rect(slide, 6.65, 1.85, 6.35, 4.3, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=PURPLE; bg.line.width=Pt(1.5)
add_rect(slide, 6.65, 1.85, 6.35, 0.42, PURPLE)
add_text_box(slide, "🖼️  사용자 가이드 PPT (13슬라이드)", 6.8, 1.9, 6.0, 0.35,
             font_size=12, bold=True, color=WHITE)
ppt_items = [
    ("요청", '"시스템 소개 PPT를 만들어 주세요"'),
    ("구성", "표지 → 목차 → 시스템 소개 → 기능별 상세"),
    ("기술", "python-pptx 라이브러리로 코드 생성"),
    ("디자인", "NAVY/BLUE 기업 색상 + COSO 색상 체계"),
    ("포함 내용", "대시보드, 위험관리, 통제활동, 운영평가"),
    ("", "발견사항 Kanban, 보고서, 기대효과 슬라이드"),
    ("결과물", "docs/ITGC_Portal_User_Guide.pptx"),
]
for i, (key, val) in enumerate(ppt_items):
    col_bg = PURPLE if key else LIGHT
    add_rect(slide, 6.75, 2.38+i*0.52, 1.1, 0.38, col_bg)
    add_text_box(slide, key, 6.75, 2.41+i*0.52, 1.1, 0.32,
                 font_size=9, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    add_text_box(slide, val, 7.9, 2.41+i*0.52, 4.9, 0.32,
                 font_size=9.5, color=NAVY)

# 하단 총평
add_rect(slide, 0.35, 6.3, 12.65, 0.95, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=LGRAY; bg.line.width=Pt(1)
add_text_box(slide, "💡  특징",
             0.5, 6.35, 1.2, 0.35, font_size=10, bold=True, color=NAVY)
add_text_box(slide,
             "README와 PPT 모두 단일 요청으로 완성 · make_ppt.py 스크립트로 언제든 재생성 가능 · python-pptx 기반 코드형 문서",
             1.7, 6.35, 11.1, 0.35, font_size=10, color=NAVY)


# ═══════════════════════════════════════════════════════════
# 슬라이드 7 – Phase 4: 샘플 데이터
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "05  Phase 4 — 샘플 데이터 구축",
               "2026-03-05 자정 · 커밋: feat: 전체 12개 테이블 샘플 데이터 추가")
add_section_badge(slide, "PART 1 — 히스토리", BLUE)

# 요청
add_rect(slide, 0.35, 1.85, 12.65, 0.7, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=BLUE; bg.line.width=Pt(1.2)
add_text_box(slide, '💬  요청: "모든 테이블에 샘플 데이터 입력하는 SQL 작성해 주세요. 데이터 양은 적당히 넣어주면 됩니다."',
             0.5, 1.92, 12.3, 0.5, font_size=11, color=NAVY)

# 12개 테이블 현황
tables = [
    ("itgc_organization",       "조직·계층",     "13건", BLUE),
    ("itgc_user",               "사용자",         "11명", BLUE),
    ("itgc_risk",               "위험",           "13건", ORANGE),
    ("itgc_control",            "통제",           "14건", ORANGE),
    ("itgc_risk_control_mapping","위험-통제 매핑", "22건", ORANGE),
    ("itgc_eval_plan",          "평가 계획",      "20건", GREEN),
    ("itgc_eval_sample",        "평가 샘플",      "21건 ★", GREEN),
    ("itgc_eval_result",        "평가 결과",      "13건 ★", GREEN),
    ("itgc_finding",            "발견사항",        "8건",  RED),
    ("itgc_remediation_history","개선 이력",       "25건 ★", RED),
    ("itgc_report",             "보고서",          "7건 ★", PURPLE),
    ("itgc_coso_config",        "COSO 설정",      "24건", NAVY),
]

add_text_box(slide, "★ = 이번 Phase에서 신규 추가된 테이블",
             0.35, 2.66, 6.0, 0.3, font_size=9, italic=True, color=GRAY)

for i, (tbl, desc, cnt, col) in enumerate(tables):
    row = i % 6
    col_x = 0.35 if i < 6 else 6.7
    ty = 3.0 + row * 0.68
    add_rect(slide, col_x, ty, 3.3, 0.56, WHITE)
    bg = slide.shapes[-1]; bg.line.color.rgb=col; bg.line.width=Pt(1)
    add_rect(slide, col_x, ty, 0.12, 0.56, col)
    add_text_box(slide, tbl, col_x+0.2, ty+0.04, 2.5, 0.28,
                 font_size=9.5, bold=True, color=NAVY)
    add_text_box(slide, desc, col_x+0.2, ty+0.3, 1.8, 0.22,
                 font_size=8.5, color=GRAY)
    add_text_box(slide, cnt, col_x+2.8, ty+0.12, 0.7, 0.32,
                 font_size=11, bold=True, color=col, align=PP_ALIGN.CENTER)

# 오른쪽 하단: 특징
add_rect(slide, 9.8, 6.2, 3.2, 1.05, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=GREEN; bg.line.width=Pt(1.2)
add_rect(slide, 9.8, 6.2, 3.2, 0.38, GREEN)
add_text_box(slide, "🔑  데이터 설계 원칙", 9.95, 6.24, 3.0, 0.32,
             font_size=10, bold=True, color=WHITE)
add_text_box(slide, "ON CONFLICT DO NOTHING · FK 서브쿼리 · BEGIN/COMMIT 트랜잭션 · 검증 SELECT",
             9.95, 6.65, 3.0, 0.5, font_size=8.5, color=NAVY)

add_rect(slide, 0.35, 6.2, 9.3, 1.05, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=LGRAY; bg.line.width=Pt(1)
add_text_box(slide, "마지막 확인 쿼리 (적용 결과 검증)",
             0.5, 6.22, 5.0, 0.32, font_size=10, bold=True, color=NAVY)
add_text_box(slide,
             "SELECT COUNT(*) FROM 각 테이블 — 12개 테이블 건수를 1개 쿼리로 동시 확인",
             0.5, 6.58, 9.0, 0.55, font_size=9.5, color=NAVY)


# ═══════════════════════════════════════════════════════════
# 슬라이드 8 – AI 협업 회고
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "06  AI 협업 회고",
               "잘된 점 · 아쉬운 점 · 다음에 개선할 점")
add_section_badge(slide, "PART 2 — 개선 가이드", GREEN)

# 잘된 점
add_rect(slide, 0.35, 1.85, 5.8, 2.85, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=GREEN; bg.line.width=Pt(1.5)
add_rect(slide, 0.35, 1.85, 5.8, 0.42, GREEN)
add_text_box(slide, "👍  잘된 점", 0.5, 1.9, 5.5, 0.35,
             font_size=13, bold=True, color=WHITE)
goods = [
    "단일 요청으로 프론트+백엔드+DB 동시 구현",
    "COSO 프레임워크를 정확히 반영한 설계",
    "실무 수준의 코드 품질 (트리거, 인덱스, JWT)",
    "기술 전환 요청에 신속·정확한 대응",
    "문서화(README·PPT)도 코드와 동일한 퀄리티",
    "커밋 메시지 컨벤션·브랜치 전략 준수",
]
for i, g in enumerate(goods):
    add_text_box(slide, f"✓  {g}", 0.5, 2.38+i*0.37, 5.6, 0.33,
                 font_size=10, color=RGBColor(0x0A, 0x60, 0x30))

# 아쉬운 점
add_rect(slide, 6.45, 1.85, 6.55, 2.85, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=ORANGE; bg.line.width=Pt(1.5)
add_rect(slide, 6.45, 1.85, 6.55, 0.42, ORANGE)
add_text_box(slide, "🔶  아쉬운 점 / 추가 커뮤니케이션이 필요했던 부분",
             6.6, 1.9, 6.2, 0.35, font_size=12, bold=True, color=WHITE)
issues = [
    ("기술 스택 미리 확정", "최초 요청 시 JPA vs MyBatis, H2 vs PostgreSQL을\n명시하지 않아 추후 기술 전환이 필요했음"),
    ("샘플 데이터 범위 불명확", '"적당히"라는 표현 대신 테이블별 건수,\n기간 범위, 필수 시나리오를 사전에 정의했다면 효율적'),
    ("단계별 확인 누락", "기능 구현 후 동작 확인·테스트 결과 공유가\n이루어지지 않아 실제 오류 여부 미검증"),
    ("비기능 요건 미명시", "성능(응답시간), 보안(패스워드 정책), 로깅,\n에러 처리 기준이 사전에 합의되지 않음"),
]
for i, (title, desc) in enumerate(issues):
    add_rect(slide, 6.55, 2.38+i*0.58, 0.08, 0.45, ORANGE)
    add_text_box(slide, title, 6.7, 2.38+i*0.58, 2.3, 0.22,
                 font_size=10, bold=True, color=ORANGE)
    add_text_box(slide, desc, 6.7, 2.6+i*0.58, 6.2, 0.32,
                 font_size=9, color=NAVY)

# 개선 포인트 요약
add_rect(slide, 0.35, 4.9, 12.65, 2.35, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=NAVY; bg.line.width=Pt(1.5)
add_rect(slide, 0.35, 4.9, 12.65, 0.42, NAVY)
add_text_box(slide, "💡  핵심 교훈 — 처음 요청할 때 이것만 정리해도 대화 횟수가 절반으로 줄어든다",
             0.5, 4.95, 12.2, 0.35, font_size=12, bold=True, color=WHITE)
lessons = [
    ("①  기술 스택", "언어/프레임워크/DB/빌드 도구 버전까지 명시"),
    ("②  기능 범위", "포함 기능 목록 + 제외 기능 목록 동시 제시"),
    ("③  데이터 기준", "샘플 건수, 기간, 필수 포함 시나리오 지정"),
    ("④  산출물 형식", "파일 경로, 파일명 규칙, 코드 컨벤션 사전 합의"),
]
for i, (key, val) in enumerate(lessons):
    lx = 0.5 + i * 3.18
    add_rect(slide, lx, 5.42, 0.9, 0.35, NAVY)
    add_text_box(slide, key, lx, 5.45, 0.9, 0.28,
                 font_size=9, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    add_text_box(slide, val, lx+0.95, 5.45, 2.1, 0.42,
                 font_size=9.5, color=NAVY)
    add_text_box(slide, "→", lx+3.1, 5.5, 0.2, 0.32,
                 font_size=14, bold=True, color=BLUE, align=PP_ALIGN.CENTER) if i < 3 else None


# ═══════════════════════════════════════════════════════════
# 슬라이드 9 – 향후 대화 방법 가이드
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "07  향후 대화 방법 가이드",
               "효율적인 AI 협업을 위한 요청 원칙 & 황금 템플릿")
add_section_badge(slide, "PART 2 — 개선 가이드", GREEN)

# 왼쪽: 요청 템플릿
add_rect(slide, 0.35, 1.85, 6.1, 5.3, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=GREEN; bg.line.width=Pt(1.5)
add_rect(slide, 0.35, 1.85, 6.1, 0.42, GREEN)
add_text_box(slide, "📝  황금 요청 템플릿", 0.5, 1.9, 5.8, 0.35,
             font_size=13, bold=True, color=WHITE)

template_sections = [
    ("🎯  목적",
     "무엇을 만들고 싶은가? (한 문장으로)"),
    ("🛠  기술 스택",
     "FE: Vue 3 + DevExtreme\nBE: Spring Boot 3.2 + MyBatis + HikariCP\nDB: PostgreSQL 14\n빌드: Vite / Maven"),
    ("📋  기능 범위",
     "포함: 기능 A, B, C\n제외: 기능 D, E (추후 개발)"),
    ("📐  산출물 기준",
     "파일 경로: src/views/...\n코딩 컨벤션: camelCase\n커밋 메시지 형식: feat/fix/docs"),
    ("✅  완료 기준",
     "어떤 상태가 되면 완료인가?\n(예: npm run dev 실행 시 화면 정상 출력)"),
]
y = 2.38
for title, content in template_sections:
    add_rect(slide, 0.45, y, 5.9, 0.28, RGBColor(0xE8, 0xF8, 0xEE))
    add_text_box(slide, title, 0.48, y+0.03, 5.8, 0.22,
                 font_size=10, bold=True, color=GREEN)
    y += 0.3
    add_text_box(slide, content, 0.55, y, 5.7, 0.6,
                 font_size=9.5, color=NAVY)
    y += 0.65

# 오른쪽: 5가지 원칙
add_rect(slide, 6.75, 1.85, 6.25, 5.3, WHITE)
bg = slide.shapes[-1]; bg.line.color.rgb=BLUE; bg.line.width=Pt(1.5)
add_rect(slide, 6.75, 1.85, 6.25, 0.42, BLUE)
add_text_box(slide, "⚡  효율적 AI 협업 5원칙", 6.9, 1.9, 5.9, 0.35,
             font_size=13, bold=True, color=WHITE)

principles = [
    (BLUE,   "1. 컨텍스트 먼저",
     "목적, 사용자, 제약사항을 첫 메시지에 모두 담는다.\n"
     '"ITGC 포털 개발" → "5개 그룹사 내부감사팀이 사용할\n'
     ' COSO 기반 ITGC 포털, Spring Boot + Vue 3"'),
    (GREEN,  "2. 구체적 완료 기준 제시",
     '"적당히"가 아닌 수치 기준을 제시한다.\n'
     '"샘플 데이터 적당히" → "테이블당 5~25건, 2025 Q3\n'
     ' ~ 2026 Q2 기간, 완료/진행중/예정 상태 혼합"'),
    (ORANGE, "3. 단계별 확인",
     "큰 기능을 한 번에 요청하지 말고 단계를 나눈다.\n"
     "DB 스키마 → 백엔드 API → 프론트엔드 순으로\n"
     "각 단계 완료 후 동작 확인 후 다음 단계 진행"),
    (PURPLE, "4. 제약사항 명시",
     "하면 안 되는 것을 미리 알려준다.\n"
     '"의존성 추가 금지", "파일 삭제 금지",\n'
     ' "기존 API 시그니처 유지" 등을 첫 메시지에'),
    (RED,    "5. 산출물 형식 지정",
     "파일 경로, 파일명, 코드 스타일을 명시한다.\n"
     '"docs/ 폴더에 make_XXX.py 스크립트로 생성",\n'
     ' "한글 주석, 영문 변수명, 들여쓰기 4칸"'),
]
y = 2.38
for col, title, desc in principles:
    add_rect(slide, 6.85, y, 0.35, 0.95, col)
    add_text_box(slide, title, 7.25, y, 5.6, 0.3,
                 font_size=10, bold=True, color=col)
    add_text_box(slide, desc, 7.25, y+0.3, 5.6, 0.6,
                 font_size=9, color=NAVY)
    y += 1.0


# ═══════════════════════════════════════════════════════════
# 슬라이드 10 – 추천 대화 시나리오 예시
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "08  추천 대화 시나리오 예시",
               "이렇게 요청했더라면 — Before & After 비교")
add_section_badge(slide, "PART 2 — 개선 가이드", GREEN)

# 비교 4쌍
comparisons = [
    ("❌  AS-IS (실제 요청)",
     '"그룹사 ITGC 포털을 만들어 주세요"',
     RED, ORANGE),
    ("✅  TO-BE (개선된 요청)",
     '"그룹사 ITGC 포털을 구축해 주세요.\n'
     '• 기술: Vue 3 + DevExtreme + Spring Boot 3.2 + MyBatis + PostgreSQL 14\n'
     '• 기능: COSO 5개 구성요소 (위험관리/통제활동/운영평가/발견사항/보고서)\n'
     '• 조직: 최대 4개 그룹사, 7개 부서 지원\n'
     '• 역할: ADMIN / LEAD / AUDITOR / OWNER / VIEWER\n'
     '• 완료 기준: npm run dev + mvn spring-boot:run 정상 동작"',
     GREEN, GREEN),
]

add_text_box(slide, "Phase 1 — 최초 구축 요청", 0.35, 1.55, 12.65, 0.35,
             font_size=12, bold=True, color=NAVY)

for i, (label, text, header_col, border_col) in enumerate(comparisons):
    lx = 0.35 if i == 0 else 6.75
    w = 6.25
    add_rect(slide, lx, 1.95, w, 2.55, WHITE)
    bg = slide.shapes[-1]; bg.line.color.rgb=border_col; bg.line.width=Pt(1.5)
    add_rect(slide, lx, 1.95, w, 0.38, header_col)
    add_text_box(slide, label, lx+0.15, 1.99, w-0.2, 0.3,
                 font_size=11, bold=True, color=WHITE)
    add_text_box(slide, text, lx+0.15, 2.4, w-0.25, 2.0,
                 font_size=9.5, color=NAVY)

# Phase 4 샘플 데이터 비교
add_rect(slide, 0.35, 4.6, 12.65, 0.06, LGRAY)
add_text_box(slide, "Phase 4 — 샘플 데이터 요청", 0.35, 4.75, 12.65, 0.35,
             font_size=12, bold=True, color=NAVY)

comparisons2 = [
    ("❌  AS-IS",
     '"모든 테이블에 샘플 데이터 입력하는 SQL 작성해주세요.\n'
     ' 데이터 양은 적당히 넣어주면 됩니다."',
     RED),
    ("✅  TO-BE",
     '"12개 테이블 전체 샘플 DML SQL을 작성해 주세요.\n'
     '• 건수: 마스터 테이블 10~15건, 트랜잭션 테이블 20~30건\n'
     '• 기간: 2025 Q3 ~ 2026 Q1 (완료) + 2026 Q2 (예정)\n'
     '• 상태: 완료/진행중/예정/기한초과 모두 포함\n'
     '• 파일: db/dml/03_insert_sample_data.sql, ON CONFLICT DO NOTHING"',
     GREEN),
]
for i, (label, text, col) in enumerate(comparisons2):
    lx = 0.35 if i == 0 else 6.75
    w = 6.25
    add_rect(slide, lx, 5.15, w, 1.95, WHITE)
    bg = slide.shapes[-1]; bg.line.color.rgb=col; bg.line.width=Pt(1.5)
    add_rect(slide, lx, 5.15, w, 0.35, col)
    add_text_box(slide, label, lx+0.15, 5.18, w-0.2, 0.28,
                 font_size=10, bold=True, color=WHITE)
    add_text_box(slide, text, lx+0.15, 5.57, w-0.25, 1.45,
                 font_size=9.5, color=NAVY)


# ═══════════════════════════════════════════════════════════
# 슬라이드 11 – 마무리
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, NAVY)

add_rect(slide, 0, 0, 13.33, 0.1, BLUE)
add_rect(slide, 0, 7.4, 13.33, 0.1, BLUE)
add_rect(slide, 9.5, 0, 3.83, 7.5, RGBColor(0x12, 0x20, 0x38))
add_rect(slide, 10.15, 0, 0.08, 7.5, BLUE)

add_text_box(slide, "📋", 0.8, 1.3, 1.5, 1.5, font_size=52, color=BLUE)
add_text_box(slide, "구축 과정 정리 완료",
             0.8, 2.55, 8.0, 1.0, font_size=40, bold=True, color=WHITE)
add_rect(slide, 0.8, 3.65, 5.0, 0.07, BLUE)

add_text_box(slide,
             "ITGC 포털은 단 하루 만에\n"
             "Claude와의 5단계 대화로 완성되었습니다.",
             0.8, 3.85, 8.0, 0.9,
             font_size=14, color=RGBColor(0xC0, 0xD8, 0xF0))

# 핵심 요약 박스
summary_items = [
    ("PART 1",  "히스토리 요약",
     "최초 구축 → 기술 전환 → 문서화 → 샘플 데이터 → 과정 정리",
     BLUE),
    ("PART 2",  "개선 가이드",
     "기술 스택·완료 기준·데이터 기준을 첫 메시지에 명시",
     GREEN),
]
for i, (part, title, desc, col) in enumerate(summary_items):
    ty = 5.0 + i * 1.05
    add_rect(slide, 0.8, ty, 7.8, 0.92, RGBColor(0x14, 0x28, 0x44))
    add_rect(slide, 0.8, ty, 1.3, 0.92, col)
    add_text_box(slide, part, 0.8, ty+0.28, 1.3, 0.38,
                 font_size=11, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    add_text_box(slide, title, 2.15, ty+0.07, 6.3, 0.32,
                 font_size=12, bold=True, color=WHITE)
    add_text_box(slide, desc, 2.15, ty+0.42, 6.3, 0.42,
                 font_size=10, color=RGBColor(0xC0, 0xD8, 0xF0))

# 우측 요약
add_text_box(slide, "Phase별 커밋 요약", 10.1, 1.2, 3.0, 0.38,
             font_size=11, bold=True, color=BLUE)
phases_final = [
    "Phase 1: COSO 포털 전체 구현",
    "Phase 2: PostgreSQL + MyBatis 전환",
    "Phase 3: README + 사용자 가이드 PPT",
    "Phase 4: 12개 테이블 샘플 데이터",
    "Phase 5: 구축 과정 정리 PPT",
]
for i, p in enumerate(phases_final):
    add_text_box(slide, f"{'✓' if i < 4 else '→'}  {p}",
                 10.1, 1.75+i*0.72, 3.1, 0.55,
                 font_size=9.5, color=WHITE if i < 4 else BLUE)

# ── 저장 ────────────────────────────────────────────────────
output_path = "/home/user/ITGC/docs/ITGC_Dev_Process.pptx"
os.makedirs("/home/user/ITGC/docs", exist_ok=True)
prs.save(output_path)
print(f"✅  PPT 생성 완료: {output_path}")
print(f"   총 슬라이드 수: {len(prs.slides)}")
