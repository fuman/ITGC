
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.util import Inches, Pt
import copy

prs = Presentation()
prs.slide_width  = Inches(13.33)
prs.slide_height = Inches(7.5)

# ── 색상 팔레트 ──────────────────────────────────────────────
NAVY    = RGBColor(0x1A, 0x2E, 0x4A)   # 진남색 (타이틀 배경)
BLUE    = RGBColor(0x1E, 0x6F, 0xC8)   # 포인트 파랑
LIGHT   = RGBColor(0xF0, 0xF4, 0xFA)   # 연한 배경
WHITE   = RGBColor(0xFF, 0xFF, 0xFF)
GRAY    = RGBColor(0x60, 0x60, 0x60)
LGRAY   = RGBColor(0xE8, 0xEC, 0xF2)
ORANGE  = RGBColor(0xE8, 0x6A, 0x1A)
GREEN   = RGBColor(0x1A, 0x9E, 0x5A)
RED     = RGBColor(0xD9, 0x2B, 0x2B)
YELLOW  = RGBColor(0xF0, 0xA5, 0x1A)

# COSO 구성요소 색상
COSO_CE = RGBColor(0x1E, 0x6F, 0xC8)
COSO_RA = RGBColor(0xE8, 0x6A, 0x1A)
COSO_CA = RGBColor(0x1A, 0x9E, 0x5A)
COSO_IC = RGBColor(0x8B, 0x2E, 0xC8)
COSO_MA = RGBColor(0xD9, 0x2B, 0x2B)

# ── 공통 헬퍼 ────────────────────────────────────────────────
def add_rect(slide, l, t, w, h, color, radius=False):
    shape = slide.shapes.add_shape(1, Inches(l), Inches(t), Inches(w), Inches(h))
    shape.fill.solid()
    shape.fill.fore_color.rgb = color
    shape.line.fill.background()
    return shape

def add_text_box(slide, text, l, t, w, h,
                 font_size=14, bold=False, color=WHITE,
                 align=PP_ALIGN.LEFT, wrap=True, italic=False):
    txBox = slide.shapes.add_textbox(Inches(l), Inches(t), Inches(w), Inches(h))
    txBox.word_wrap = wrap
    tf = txBox.text_frame
    tf.word_wrap = wrap
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
    """상단 진남색 헤더 바"""
    add_rect(slide, 0, 0, 13.33, 1.35, NAVY)
    add_text_box(slide, title, 0.4, 0.15, 10, 0.7,
                 font_size=28, bold=True, color=WHITE)
    if subtitle:
        add_text_box(slide, subtitle, 0.4, 0.82, 12, 0.45,
                     font_size=13, bold=False, color=RGBColor(0xA8, 0xC8, 0xF0))

def add_badge(slide, text, l, t, color):
    add_rect(slide, l, t, 1.6, 0.35, color)
    add_text_box(slide, text, l, t+0.02, 1.6, 0.33,
                 font_size=11, bold=True, color=WHITE, align=PP_ALIGN.CENTER)

def add_feature_card(slide, title, items, l, t, w=3.8, h=2.0,
                     title_color=BLUE, border_color=BLUE):
    # 카드 배경
    add_rect(slide, l, t, w, h, WHITE)
    bg = slide.shapes[-1]
    bg.line.color.rgb = border_color
    bg.line.width = Pt(1.5)
    # 타이틀 바
    add_rect(slide, l, t, w, 0.42, title_color)
    add_text_box(slide, title, l+0.1, t+0.06, w-0.2, 0.32,
                 font_size=12, bold=True, color=WHITE)
    # 항목들
    y_offset = t + 0.5
    for item in items:
        add_text_box(slide, f"▸  {item}", l+0.15, y_offset, w-0.25, 0.32,
                     font_size=10.5, bold=False, color=NAVY)
        y_offset += 0.3

# ═══════════════════════════════════════════════════════════
# 슬라이드 1 – 표지
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, NAVY)

# 대각선 장식 블록
add_rect(slide, 9.5, 0, 3.83, 7.5, RGBColor(0x12, 0x20, 0x38))
add_rect(slide, 10.2, 0, 0.08, 7.5, BLUE)

# 로고 영역 아이콘 텍스트
add_text_box(slide, "🛡", 0.5, 0.8, 1.5, 1.5, font_size=48, color=BLUE)

# 메인 타이틀
add_text_box(slide, "그룹사 ITGC 포털", 0.5, 1.8, 8.5, 1.0,
             font_size=42, bold=True, color=WHITE)
add_text_box(slide, "IT General Controls Management Portal",
             0.5, 2.75, 8.5, 0.6, font_size=18, bold=False,
             color=RGBColor(0x7A, 0xB4, 0xE8))

# 구분선
add_rect(slide, 0.5, 3.45, 5.0, 0.06, BLUE)

# 부제
add_text_box(slide,
             "COSO 2013 프레임워크 기반\n위험관리 · 통제평가 · 운영평가 통합 플랫폼",
             0.5, 3.65, 8.5, 1.0,
             font_size=16, bold=False, color=RGBColor(0xC0, 0xD8, 0xF0))

# 하단 버전/날짜
add_text_box(slide, "Version 1.0  |  2026", 0.5, 6.8, 5.0, 0.5,
             font_size=12, color=RGBColor(0x70, 0x90, 0xB0))

# 우측 COSO 요소 라벨
coso_items = [
    ("CE", "통제 환경",    COSO_CE, 0.4),
    ("RA", "위험 평가",    COSO_RA, 1.15),
    ("CA", "통제 활동",    COSO_CA, 1.9),
    ("IC", "정보·소통",    COSO_IC, 2.65),
    ("MA", "모니터링",     COSO_MA, 3.4),
]
for abbr, name, col, ty in coso_items:
    add_rect(slide, 10.4, ty+1.2, 2.4, 0.62, RGBColor(0x1A, 0x2E, 0x4A))
    add_rect(slide, 10.4, ty+1.2, 0.55, 0.62, col)
    add_text_box(slide, abbr,  10.41, ty+1.27, 0.53, 0.5,
                 font_size=12, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    add_text_box(slide, name,  11.0, ty+1.28, 1.8, 0.5,
                 font_size=11, bold=False, color=WHITE)

# ═══════════════════════════════════════════════════════════
# 슬라이드 2 – 목차
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "목  차", "Contents")

toc = [
    ("01", "시스템 구축 목적",         "도입 배경 및 핵심 가치"),
    ("02", "시스템 개요 및 아키텍처",  "기술 스택 및 화면 구성"),
    ("03", "대시보드",                 "COSO 종합 현황 및 KPI"),
    ("04", "위험 관리",                "위험 식별 · 평가 · 대응 · 매트릭스"),
    ("05", "통제 활동",                "통제 설계 · 운영 · 매핑"),
    ("06", "운영평가",                 "평가 계획 · 실행 · 결과"),
    ("07", "발견사항 & 개선조치",      "미비점 등록 및 Kanban 추적"),
    ("08", "보고서 & 시스템 설정",     "종합 보고서 · 조직 · 사용자 관리"),
    ("09", "기대 효과 및 활용 방안",   "도입 효과 및 향후 로드맵"),
]

cols = [
    (0.35, toc[:5]),
    (6.85, toc[5:]),
]
for base_x, items in cols:
    for i, (num, title, sub) in enumerate(items):
        ty = 1.55 + i * 1.0
        add_rect(slide, base_x, ty, 0.65, 0.72, BLUE)
        add_text_box(slide, num, base_x, ty+0.12, 0.65, 0.55,
                     font_size=16, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
        add_rect(slide, base_x+0.65, ty, 5.8, 0.72, WHITE)
        bg = slide.shapes[-1]
        bg.line.color.rgb = LGRAY
        bg.line.width = Pt(0.75)
        add_text_box(slide, title, base_x+0.78, ty+0.06, 5.5, 0.35,
                     font_size=13, bold=True, color=NAVY)
        add_text_box(slide, sub, base_x+0.78, ty+0.38, 5.5, 0.28,
                     font_size=10, color=GRAY)

# ═══════════════════════════════════════════════════════════
# 슬라이드 3 – 구축 목적
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "01  시스템 구축 목적",
               "왜 ITGC 포털이 필요한가?")

# 문제 영역 (좌)
add_rect(slide, 0.35, 1.5, 5.9, 2.4, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=RED; s.line.width=Pt(1.5)
add_rect(slide, 0.35, 1.5, 5.9, 0.42, RED)
add_text_box(slide, "⚠  도입 전 문제점", 0.5, 1.55, 5.6, 0.35,
             font_size=13, bold=True, color=WHITE)
problems = [
    "엑셀/수작업 기반 통제 관리 → 버전 불일치, 누락 위험",
    "COSO 구성요소 간 연계 부재 → 종합적 위험 파악 불가",
    "운영평가 결과 추적 및 발견사항 관리 체계 미흡",
    "감사·규제 대응을 위한 통합 보고 기능 부족",
]
for i, p in enumerate(problems):
    add_text_box(slide, f"✕  {p}", 0.5, 2.05+i*0.43, 5.7, 0.38,
                 font_size=10.5, color=RGBColor(0x80,0x10,0x10))

# 화살표
add_text_box(slide, "→", 6.35, 2.4, 0.7, 0.7,
             font_size=32, bold=True, color=BLUE, align=PP_ALIGN.CENTER)

# 해결 영역 (우)
add_rect(slide, 7.1, 1.5, 5.9, 2.4, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=GREEN; s.line.width=Pt(1.5)
add_rect(slide, 7.1, 1.5, 5.9, 0.42, GREEN)
add_text_box(slide, "✔  ITGC 포털 도입 효과", 7.25, 1.55, 5.6, 0.35,
             font_size=13, bold=True, color=WHITE)
solutions = [
    "COSO 기반 통합 플랫폼으로 위험-통제-평가 일원화",
    "5×5 리스크 매트릭스로 위험 수준 시각화 및 우선순위 결정",
    "운영평가 계획~결과 자동 연계 및 샘플링 관리",
    "발견사항 Kanban 추적 + 실시간 대시보드 보고",
]
for i, s_text in enumerate(solutions):
    add_text_box(slide, f"✓  {s_text}", 7.25, 2.05+i*0.43, 5.7, 0.38,
                 font_size=10.5, color=RGBColor(0x0A,0x60,0x30))

# 핵심 가치 3개
values = [
    ("🔍", "가시성",    "모든 IT 위험과 통제 현황을\n실시간으로 파악"),
    ("⚡", "효율성",    "수작업 제거 및 프로세스\n자동화로 업무 부담 감소"),
    ("📋", "준거성",    "COSO 2013 기준 충족 및\n감사·규제 대응 강화"),
]
for i, (icon, title, desc) in enumerate(values):
    lx = 0.35 + i * 4.33
    add_rect(slide, lx, 4.15, 4.05, 1.55, WHITE)
    bg = slide.shapes[-1]; bg.line.color.rgb=BLUE; bg.line.width=Pt(1.5)
    add_rect(slide, lx, 4.15, 4.05, 0.42, BLUE)
    add_text_box(slide, f"{icon}  {title}", lx+0.12, 4.19, 3.8, 0.38,
                 font_size=13, bold=True, color=WHITE)
    add_text_box(slide, desc, lx+0.15, 4.65, 3.75, 0.9,
                 font_size=11, color=NAVY)

# ═══════════════════════════════════════════════════════════
# 슬라이드 4 – 시스템 개요
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "02  시스템 개요 및 아키텍처",
               "기술 스택, 메뉴 구성, 사용자 역할")

# 기술 스택 카드
add_rect(slide, 0.35, 1.55, 4.0, 3.1, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=BLUE; s.line.width=Pt(1.5)
add_rect(slide, 0.35, 1.55, 4.0, 0.42, BLUE)
add_text_box(slide, "🛠  기술 스택", 0.5, 1.6, 3.7, 0.35,
             font_size=13, bold=True, color=WHITE)
stack = [
    ("Frontend",   "Vue 3  ·  DevExtreme Vue  ·  Pinia"),
    ("Backend",    "Spring Boot 3.2  ·  MyBatis  ·  HikariCP"),
    ("Database",   "PostgreSQL 14+"),
    ("Security",   "Spring Security  ·  JWT"),
    ("Build",      "Vite (FE)  ·  Maven (BE)"),
]
for i, (k, v) in enumerate(stack):
    add_text_box(slide, k, 0.5,  2.08+i*0.5, 1.2, 0.38,
                 font_size=10, bold=True, color=BLUE)
    add_text_box(slide, v, 1.72, 2.08+i*0.5, 2.5, 0.38,
                 font_size=10, color=NAVY)

# 메뉴 구성 카드
add_rect(slide, 4.65, 1.55, 4.5, 3.1, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=ORANGE; s.line.width=Pt(1.5)
add_rect(slide, 4.65, 1.55, 4.5, 0.42, ORANGE)
add_text_box(slide, "🗂  화면 메뉴 구성", 4.8, 1.6, 4.2, 0.35,
             font_size=13, bold=True, color=WHITE)
menus = [
    "📊 대시보드",
    "⚠  위험관리  (식별/평가/대응/매트릭스)",
    "🛡  통제활동  (목록/설계/매핑)",
    "📝 운영평가  (계획/실행/결과)",
    "🔎 발견사항  (목록/개선조치 Kanban)",
    "📄 보고서",
    "⚙  시스템설정  (조직/사용자/COSO)",
]
for i, m in enumerate(menus):
    add_text_box(slide, m, 4.8, 2.08+i*0.37, 4.2, 0.34,
                 font_size=10, color=NAVY)

# 사용자 역할 카드
add_rect(slide, 9.45, 1.55, 3.55, 3.1, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=GREEN; s.line.width=Pt(1.5)
add_rect(slide, 9.45, 1.55, 3.55, 0.42, GREEN)
add_text_box(slide, "👥  사용자 역할", 9.6, 1.6, 3.3, 0.35,
             font_size=13, bold=True, color=WHITE)
roles = [
    ("ADMIN",     "전체 시스템 관리"),
    ("MANAGER",   "위험·통제 계획 수립"),
    ("EVALUATOR", "운영평가 수행"),
    ("VIEWER",    "결과 조회 전용"),
]
for i, (r, d) in enumerate(roles):
    add_rect(slide, 9.55, 2.1+i*0.58, 0.9, 0.38, GREEN)
    add_text_box(slide, r, 9.55, 2.1+i*0.58+0.05, 0.9, 0.3,
                 font_size=8, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    add_text_box(slide, d, 10.5, 2.1+i*0.58+0.06, 2.4, 0.3,
                 font_size=10, color=NAVY)

# 아키텍처 다이어그램 (하단)
add_rect(slide, 0.35, 4.9, 12.65, 0.42, NAVY)
add_text_box(slide, "시스템 구성도", 0.5, 4.94, 5, 0.35,
             font_size=12, bold=True, color=WHITE)
layers = [
    ("Browser\n(Vue 3)", 0.55, BLUE),
    ("API Gateway\n(Spring Boot)", 3.55, NAVY),
    ("MyBatis\n(SQL Mapper)", 6.55, RGBColor(0x2A,0x7E,0x4A)),
    ("PostgreSQL\n(DB)", 9.55, RGBColor(0x6B,0x2A,0xA8)),
]
for label, lx, col in layers:
    add_rect(slide, lx, 5.45, 2.7, 0.95, col)
    add_text_box(slide, label, lx+0.1, 5.52, 2.5, 0.82,
                 font_size=10, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
for arx in [3.3, 6.3, 9.3]:
    add_text_box(slide, "→", arx, 5.65, 0.3, 0.5,
                 font_size=20, bold=True, color=NAVY, align=PP_ALIGN.CENTER)

# ═══════════════════════════════════════════════════════════
# 슬라이드 5 – 대시보드
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "03  대시보드", "COSO 종합 현황 · KPI · 위험 분포 · 최근 발견사항")

add_badge(slide, "COSO 연관: 전체", 0.35, 1.52, NAVY)

# KPI 카드 4개
kpis = [
    ("총 통제 수",     "124건", "효과적 89건", BLUE),
    ("고위험 건수",    "8건",   "심각 2 · 높음 6", RED),
    ("미결 발견사항",  "13건",  "기한초과 3건", ORANGE),
    ("평가 완료율",    "76%",   "2분기 기준", GREEN),
]
for i, (label, val, sub, col) in enumerate(kpis):
    lx = 0.35 + i * 3.25
    add_rect(slide, lx, 2.0, 3.05, 1.25, WHITE)
    bg = slide.shapes[-1]; bg.line.color.rgb=col; bg.line.width=Pt(2)
    add_rect(slide, lx, 2.0, 0.18, 1.25, col)
    add_text_box(slide, label, lx+0.32, 2.08, 2.6, 0.35,
                 font_size=11, bold=False, color=GRAY)
    add_text_box(slide, val,   lx+0.32, 2.38, 2.6, 0.55,
                 font_size=26, bold=True, color=col)
    add_text_box(slide, sub,   lx+0.32, 2.87, 2.6, 0.3,
                 font_size=9, color=GRAY)

# COSO 5대 현황
coso_data = [
    ("통제환경 CE", 82, COSO_CE),
    ("위험평가 RA", 75, COSO_RA),
    ("통제활동 CA", 88, COSO_CA),
    ("정보소통 IC", 70, COSO_IC),
    ("모니터링 MA", 65, COSO_MA),
]
add_rect(slide, 0.35, 3.45, 7.75, 2.7, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=LGRAY; s.line.width=Pt(1)
add_text_box(slide, "COSO 구성요소별 점수", 0.5, 3.5, 5, 0.38,
             font_size=13, bold=True, color=NAVY)
for i, (name, score, col) in enumerate(coso_data):
    ty = 4.0 + i * 0.4
    add_text_box(slide, name, 0.5, ty, 2.0, 0.33,
                 font_size=10, color=NAVY)
    bar_w = score / 100 * 4.5
    add_rect(slide, 2.55, ty+0.04, 4.5, 0.23, LGRAY)
    add_rect(slide, 2.55, ty+0.04, bar_w, 0.23, col)
    add_text_box(slide, f"{score}점", 7.12, ty, 0.7, 0.33,
                 font_size=10, bold=True, color=col)

# 최근 발견사항 테이블
add_rect(slide, 8.3, 3.45, 4.7, 2.7, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=LGRAY; s.line.width=Pt(1)
add_text_box(slide, "최근 발견사항", 8.45, 3.5, 3.5, 0.38,
             font_size=13, bold=True, color=NAVY)
findings = [
    ("접근권한 미회수",   "높음", RED),
    ("패치관리 지연",     "중간", YELLOW),
    ("백업 검증 누락",    "높음", RED),
    ("계정 검토 미실시",  "낮음", GREEN),
]
headers = ["제목", "심각도"]
add_rect(slide, 8.3, 3.95, 4.7, 0.32, NAVY)
add_text_box(slide, "제목",   8.42, 3.98, 3.0, 0.28, font_size=9, bold=True, color=WHITE)
add_text_box(slide, "심각도", 11.45, 3.98, 1.4, 0.28, font_size=9, bold=True, color=WHITE)
for i, (title, sev, col) in enumerate(findings):
    row_col = WHITE if i % 2 == 0 else LIGHT
    add_rect(slide, 8.3, 4.28+i*0.42, 4.7, 0.38, row_col)
    add_text_box(slide, title, 8.42, 4.31+i*0.42, 3.0, 0.32,
                 font_size=9.5, color=NAVY)
    add_rect(slide, 11.42, 4.32+i*0.42, 1.3, 0.28, col)
    add_text_box(slide, sev, 11.42, 4.32+i*0.42+0.04, 1.3, 0.22,
                 font_size=9, bold=True, color=WHITE, align=PP_ALIGN.CENTER)

# ═══════════════════════════════════════════════════════════
# 슬라이드 6 – 위험관리 (1/2) : 식별·평가·대응
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "04  위험 관리 (1/2)", "위험 식별 · 위험 평가 워크시트 · 위험 대응 전략")

add_badge(slide, "COSO 연관: RA", 0.35, 1.52, COSO_RA)

# 3개 기능 카드
cards = [
    ("⚠  위험 식별",
     COSO_RA,
     ["위험 코드 자동 채번 (예: RISK-2026-001)",
      "카테고리 분류: 접근통제/변경관리/IT운영 등",
      "위험명, 설명, 담당자, 소관부서 등록",
      "관련 프로세스 연계 입력",
      "DataGrid에서 직접 인라인 편집 지원"]),
    ("📊  위험 평가 워크시트",
     COSO_RA,
     ["가능성(Likelihood) 1~5 슬라이더 입력",
      "영향도(Impact) 1~5 슬라이더 입력",
      "고유위험·잔여위험 점수 자동 산출",
      "위험 수준 자동 결정 (심각/높음/중간/낮음/미미)",
      "PostgreSQL 트리거로 DB 자동 업데이트"]),
    ("🛡  위험 대응 전략",
     COSO_RA,
     ["4가지 대응 유형 선택",
      "  ① 완화(Mitigate): 통제 강화",
      "  ② 전가(Transfer): 보험·외주",
      "  ③ 수용(Accept): 비용 대비 허용",
      "  ④ 회피(Avoid): 활동 중단",
      "대응 계획 및 담당자 지정"]),
]
for i, (title, col, items) in enumerate(cards):
    lx = 0.35 + i * 4.33
    add_feature_card(slide, title, items, lx, 1.85, w=4.1, h=3.3,
                     title_color=col, border_color=col)

# 위험 수준 범례
add_rect(slide, 0.35, 5.3, 12.65, 1.0, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=LGRAY; s.line.width=Pt(1)
add_text_box(slide, "위험 수준 기준 (가능성 × 영향도)",
             0.5, 5.35, 5, 0.35, font_size=11, bold=True, color=NAVY)
levels = [
    ("심각 (20~25)", RGBColor(0xD9,0x2B,0x2B)),
    ("높음 (12~19)", RGBColor(0xE8,0x6A,0x1A)),
    ("중간 (6~11)",  RGBColor(0xF0,0xA5,0x1A)),
    ("낮음 (3~5)",   RGBColor(0x1A,0x9E,0x5A)),
    ("미미 (1~2)",   RGBColor(0x60,0x60,0x60)),
]
for i, (lvl, col) in enumerate(levels):
    lx = 0.55 + i * 2.5
    add_rect(slide, lx, 5.75, 0.22, 0.35, col)
    add_text_box(slide, lvl, lx+0.28, 5.75, 2.1, 0.35,
                 font_size=10, color=NAVY)

# ═══════════════════════════════════════════════════════════
# 슬라이드 7 – 위험 매트릭스
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "04  위험 관리 (2/2)", "5×5 위험 매트릭스 시각화")

add_badge(slide, "COSO 연관: RA", 0.35, 1.52, COSO_RA)

# 매트릭스 색상 (5×5)
matrix_colors = {
    # (row=likelihood 5->1, col=impact 1->5)
    (5,1): YELLOW, (5,2): ORANGE, (5,3): RED,    (5,4): RED,    (5,5): RED,
    (4,1): YELLOW, (4,2): YELLOW, (4,3): ORANGE, (4,4): RED,    (4,5): RED,
    (3,1): GREEN,  (3,2): YELLOW, (3,3): YELLOW, (3,4): ORANGE, (3,5): RED,
    (2,1): GREEN,  (2,2): GREEN,  (2,3): YELLOW, (2,4): YELLOW, (2,5): ORANGE,
    (1,1): GREEN,  (1,2): GREEN,  (1,3): GREEN,  (1,4): YELLOW, (1,5): YELLOW,
}
mx0, my0 = 1.2, 1.85
cell_w, cell_h = 0.95, 0.82

# 축 레이블
add_text_box(slide, "가능성\n(Likelihood)", 0.1, 2.8, 1.0, 1.5,
             font_size=10, bold=True, color=NAVY, align=PP_ALIGN.CENTER)
for i, label in enumerate(["매우낮음", "낮음", "보통", "높음", "매우높음"]):
    add_text_box(slide, f"{5-i}", mx0-0.5, my0+i*cell_h+0.27, 0.25, 0.35,
                 font_size=10, bold=True, color=NAVY, align=PP_ALIGN.CENTER)

add_text_box(slide, "영향도 (Impact)", mx0+1.5, my0+5*cell_h+0.1, 4.0, 0.38,
             font_size=10, bold=True, color=NAVY, align=PP_ALIGN.CENTER)
for j, label in enumerate(["1\n매우낮음","2\n낮음","3\n보통","4\n높음","5\n매우높음"]):
    add_text_box(slide, label, mx0+j*cell_w+0.15, my0+5*cell_h+0.5, 0.75, 0.5,
                 font_size=7.5, color=GRAY, align=PP_ALIGN.CENTER)

for i in range(5):      # row: likelihood 5-i
    for j in range(5):  # col: impact 1+j
        row = 5 - i
        col_idx = j + 1
        color = matrix_colors[(row, col_idx)]
        score = row * col_idx
        lx = mx0 + j * cell_w
        ty = my0 + i * cell_h
        add_rect(slide, lx, ty, cell_w-0.04, cell_h-0.04, color)
        add_text_box(slide, str(score), lx+0.3, ty+0.27, 0.35, 0.35,
                     font_size=14, bold=True, color=WHITE, align=PP_ALIGN.CENTER)

# 범례
legend_items = [
    ("심각 (20+)", RED), ("높음 (12~19)", ORANGE),
    ("중간 (6~11)", YELLOW), ("낮음 (1~5)", GREEN),
]
add_text_box(slide, "범례", 7.1, 2.0, 1.0, 0.35,
             font_size=12, bold=True, color=NAVY)
for i, (label, col) in enumerate(legend_items):
    add_rect(slide, 7.1, 2.45+i*0.55, 0.45, 0.38, col)
    add_text_box(slide, label, 7.65, 2.47+i*0.55, 2.0, 0.35,
                 font_size=10, color=NAVY)

# 기능 설명
add_rect(slide, 7.1, 5.0, 5.9, 1.8, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=COSO_RA; s.line.width=Pt(1.5)
add_rect(slide, 7.1, 5.0, 5.9, 0.38, COSO_RA)
add_text_box(slide, "📌  매트릭스 주요 기능", 7.25, 5.04, 5.5, 0.32,
             font_size=12, bold=True, color=WHITE)
features = [
    "고유위험·잔여위험 탭 전환으로 비교 분석",
    "셀 클릭 시 해당 위험 목록 팝업 조회",
    "버블 차트로 위험 분포 한눈에 파악",
    "위험 감소 방향성 시각화 (고유→잔여)",
]
for i, f in enumerate(features):
    add_text_box(slide, f"▸  {f}", 7.25, 5.48+i*0.3, 5.7, 0.28,
                 font_size=10, color=NAVY)

# ═══════════════════════════════════════════════════════════
# 슬라이드 8 – 통제 활동
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "05  통제 활동",
               "통제 목록 관리 · 설계 적합성 평가 · 위험-통제 매핑")

add_badge(slide, "COSO 연관: CA", 0.35, 1.52, COSO_CA)

cards2 = [
    ("🛡  통제 목록 관리",
     COSO_CA,
     ["도메인별 탭: 접근통제/변경관리/IT운영/업무연속성/정보보안",
      "통제 코드, 통제명, 유형 등록",
      "통제 유형: 예방·탐지·교정 통제 분류",
      "자동화 여부: 자동·수동·반자동",
      "주기: 상시/일일/주간/월간/분기 등",
      "핵심통제(Key Control) 여부 지정"]),
    ("✅  설계 적합성 평가",
     COSO_CA,
     ["통제별 설계 적합성 평가 워크시트",
      "설계 목적 및 통제 절차 기술",
     "평가 기준 항목별 체크리스트",
      "결과: 적합 / 미흡 / 미평가",
      "설계 미흡 시 개선 의견 입력",
      "최종 승인자 서명 기록"]),
    ("🔗  위험-통제 매핑",
     COSO_CA,
     ["위험별 대응 통제 연결 관리",
      "매핑 유형: 주요통제 / 보완통제",
      "통제 커버리지 비율 자동 계산",
      "미매핑 위험 자동 식별 및 경고",
      "매핑 현황 시각화 차트",
      "도메인별 통제 효과성 요약"]),
]
for i, (title, col, items) in enumerate(cards2):
    lx = 0.35 + i * 4.33
    add_feature_card(slide, title, items, lx, 1.85, w=4.1, h=3.6,
                     title_color=col, border_color=col)

# 통제 도메인 현황 바
add_rect(slide, 0.35, 5.65, 12.65, 1.65, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=LGRAY; s.line.width=Pt(1)
add_text_box(slide, "📊  도메인별 통제 효과성 현황 (예시)",
             0.5, 5.7, 8, 0.38, font_size=12, bold=True, color=NAVY)
domains = [
    ("접근통제",   88, 12, COSO_CA),
    ("변경관리",   75, 25, ORANGE),
    ("IT운영",     82, 18, BLUE),
    ("업무연속성", 70, 30, YELLOW),
    ("정보보안",   92, 8,  GREEN),
]
for i, (name, eff, ineff, col) in enumerate(domains):
    lx = 0.55 + i * 2.5
    add_text_box(slide, name, lx, 6.1, 2.2, 0.28, font_size=9, bold=True, color=NAVY)
    eff_w = eff / 100 * 2.2
    add_rect(slide, lx, 6.4, 2.2, 0.28, LGRAY)
    add_rect(slide, lx, 6.4, eff_w, 0.28, col)
    add_text_box(slide, f"{eff}%", lx+eff_w+0.05, 6.4, 0.5, 0.28,
                 font_size=8, bold=True, color=col)

# ═══════════════════════════════════════════════════════════
# 슬라이드 9 – 운영평가
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "06  운영평가",
               "평가 계획 수립 · 실행(샘플링·증빙) · 결과 확정")

add_badge(slide, "COSO 연관: MA", 0.35, 1.52, COSO_MA)

# 프로세스 플로우
steps = [
    ("📅", "계획 수립",   "평가 대상·기간\n담당자·샘플링 방법"),
    ("🔬", "샘플 선정",   "전수/확률적/판단적\n샘플 추출"),
    ("📂", "증빙 수집",   "파일 업로드\n트랜잭션 ID 기록"),
    ("✅", "테스트 수행", "통과/예외/미적용\n결과 입력"),
    ("📝", "결과 확정",   "평가 의견·검토·승인\n결론 도출"),
]
arrow_placed = False
for i, (icon, title, desc) in enumerate(steps):
    lx = 0.35 + i * 2.56
    add_rect(slide, lx, 1.85, 2.35, 1.6, WHITE)
    bg = slide.shapes[-1]; bg.line.color.rgb=COSO_MA; bg.line.width=Pt(1.5)
    add_rect(slide, lx, 1.85, 2.35, 0.42, COSO_MA)
    add_text_box(slide, f"STEP {i+1}", lx+0.12, 1.89, 0.75, 0.32,
                 font_size=8, bold=True, color=WHITE)
    add_text_box(slide, f"{icon} {title}", lx+0.9, 1.89, 1.35, 0.32,
                 font_size=10, bold=True, color=WHITE)
    add_text_box(slide, desc, lx+0.15, 2.38, 2.05, 0.9,
                 font_size=9.5, color=NAVY)
    if i < 4:
        add_text_box(slide, "→", lx+2.35, 2.4, 0.22, 0.5,
                     font_size=16, bold=True, color=COSO_MA, align=PP_ALIGN.CENTER)

# 기능 상세 카드 3개
detail_cards = [
    ("📅  평가 계획 관리",
     ["연도·분기별 평가 계획 캘린더 타임라인",
      "통제별 담당 평가자 배정",
      "샘플링 방법 선택 (전수/확률적/비통계적/판단적)",
      "계획 대비 실적 진행률 자동 계산",
      "지연 현황 자동 경고 표시"]),
    ("🔬  평가 실행",
     ["샘플 번호 자동 채번",
      "트랜잭션 일자·ID 입력",
      "증빙 파일 첨부 기능",
      "테스트 결과 입력 (통과/예외/미적용)",
      "예외 사유 상세 기록"]),
    ("📝  결과 및 통계",
     ["샘플 합격률·예외율 자동 집계",
      "결론 도출: 효과적/부분효과적/비효과적",
      "평가자→검토자→승인자 워크플로우",
      "도메인별·분기별 효과성 추이 차트",
      "Master-Detail 그리드 결과 조회"]),
]
for i, (title, items) in enumerate(detail_cards):
    lx = 0.35 + i * 4.33
    add_feature_card(slide, title, items, lx, 3.65, w=4.1, h=2.65,
                     title_color=COSO_MA, border_color=COSO_MA)

# ═══════════════════════════════════════════════════════════
# 슬라이드 10 – 발견사항 & 개선조치
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "07  발견사항 & 개선조치",
               "미비점 등록 · 심각도 분류 · Kanban 추적 관리")

add_badge(slide, "COSO 연관: MA", 0.35, 1.52, COSO_MA)

# 왼쪽: 발견사항 목록
add_rect(slide, 0.35, 1.85, 5.9, 4.35, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=RED; s.line.width=Pt(1.5)
add_rect(slide, 0.35, 1.85, 5.9, 0.42, RED)
add_text_box(slide, "🔎  발견사항 목록 관리", 0.5, 1.9, 5.5, 0.35,
             font_size=13, bold=True, color=WHITE)
finding_features = [
    "발견사항 번호 자동 생성 (FND-2026-001)",
    "유형 분류: 운영평가 / 내부감사 / 외부감사 / 자체점검",
    "심각도 필터: 심각(빨강) · 높음(주황) · 중간(노랑) · 낮음(초록)",
    "관련 통제·위험 코드 연결",
    "근본 원인 분석 (Root Cause) 입력",
    "조치 권고사항 및 조치 계획 등록",
    "조치 기한, 담당자, 진행률(0~100%) 관리",
    "기한 초과 시 자동 상태 변경 및 경고",
]
for i, f in enumerate(finding_features):
    add_text_box(slide, f"▸  {f}", 0.5, 2.37+i*0.42, 5.65, 0.38,
                 font_size=10, color=NAVY)

# 오른쪽: Kanban 보드
add_rect(slide, 6.55, 1.85, 6.45, 4.35, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=ORANGE; s.line.width=Pt(1.5)
add_rect(slide, 6.55, 1.85, 6.45, 0.42, ORANGE)
add_text_box(slide, "📋  개선조치 Kanban 보드", 6.7, 1.9, 6.0, 0.35,
             font_size=13, bold=True, color=WHITE)

# Kanban 컬럼
kanban_cols = [
    ("미결",     RED,    ["접근권한 미회수", "배치작업 오류 미처리"]),
    ("조치중",   ORANGE, ["패치 관리 지연", "로그 검토 누락"]),
    ("기한초과", RGBColor(0x80,0x0,0x80), ["계정 검토 미이행"]),
    ("조치완료", GREEN,  ["변경관리 절차 개선"]),
]
for i, (col_name, col_color, items) in enumerate(kanban_cols):
    lx = 6.65 + i * 1.55
    add_rect(slide, lx, 2.35, 1.42, 0.35, col_color)
    add_text_box(slide, col_name, lx, 2.37, 1.42, 0.3,
                 font_size=9, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    for j, item in enumerate(items):
        add_rect(slide, lx+0.05, 2.82+j*1.15, 1.32, 1.0,
                 RGBColor(0xF8,0xF9,0xFA))
        bg = slide.shapes[-1]; bg.line.color.rgb=col_color; bg.line.width=Pt(1)
        add_text_box(slide, item, lx+0.1, 2.87+j*1.15, 1.22, 0.8,
                     font_size=8.5, color=NAVY)

# 진행률 표시
add_text_box(slide, "💡 드래그&드롭으로 상태 변경 가능", 6.7, 5.75, 6.0, 0.3,
             font_size=9.5, italic=True, color=GRAY)

# ═══════════════════════════════════════════════════════════
# 슬라이드 11 – 보고서 & 시스템 설정
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "08  보고서 & 시스템 설정",
               "종합 보고서 생성 · 조직 관리 · 사용자 관리 · COSO 설정")

add_badge(slide, "COSO 연관: IC / CE", 0.35, 1.52, NAVY)

# 보고서
add_rect(slide, 0.35, 1.85, 6.2, 3.3, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=COSO_IC; s.line.width=Pt(1.5)
add_rect(slide, 0.35, 1.85, 6.2, 0.42, COSO_IC)
add_text_box(slide, "📄  보고서 (정보 및 의사소통 IC)", 0.5, 1.9, 5.8, 0.35,
             font_size=13, bold=True, color=WHITE)
reports = [
    "COSO 종합 보고서 — 구성요소별 점수 및 현황",
    "분기별 운영평가 결과 보고서",
    "위험·통제 현황 보고서",
    "발견사항 및 개선조치 현황 보고서",
    "보고서 미리보기 및 PDF/Excel 다운로드",
    "보고 기간 선택 (연도·분기·월)",
]
for i, r in enumerate(reports):
    add_text_box(slide, f"▸  {r}", 0.5, 2.37+i*0.42, 5.9, 0.38,
                 font_size=10, color=NAVY)

# 시스템 설정 (우측)
setting_cards = [
    ("🏢  조직 관리",    COSO_CE,
     ["그룹사/본부/팀 트리 구조 관리",
      "상위 조직 연결 및 정렬 순서",
      "조직 코드·유형 분류"]),
    ("👥  사용자 관리",  BLUE,
     ["사용자 ID/이름/이메일 등록",
      "역할 배정: ADMIN/MANAGER/EVALUATOR/VIEWER",
      "활성/비활성 상태 관리"]),
    ("⚙  COSO 설정",    NAVY,
     ["구성요소별 가중치 설정 (합계 100%)",
      "점수 기준 임계값: 양호/보통/미흡",
      "평가 기준 및 설명 수정"]),
]
for i, (title, col, items) in enumerate(setting_cards):
    lx = 6.85
    ty = 1.85 + i * 1.7
    add_rect(slide, lx, ty, 6.15, 1.55, WHITE)
    bg = slide.shapes[-1]; bg.line.color.rgb=col; bg.line.width=Pt(1.5)
    add_rect(slide, lx, ty, 6.15, 0.38, col)
    add_text_box(slide, title, lx+0.15, ty+0.05, 5.8, 0.3,
                 font_size=12, bold=True, color=WHITE)
    for j, item in enumerate(items):
        add_text_box(slide, f"▸  {item}", lx+0.2, ty+0.48+j*0.32, 5.8, 0.28,
                     font_size=9.5, color=NAVY)

# ═══════════════════════════════════════════════════════════
# 슬라이드 12 – 기대 효과
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, LIGHT)
add_header_bar(slide, "09  기대 효과 및 활용 방안",
               "정량적 효과 · 준거성 강화 · 향후 발전 방향")

# 정량 효과 카드
quant = [
    ("⏱", "업무 시간\n절감", "40%+", "수작업 엑셀 대비\n자동화 효과", BLUE),
    ("🎯", "통제 커버리지\n향상", "95%+", "위험-통제 매핑\n완성도 목표", GREEN),
    ("📉", "발견사항\n감소", "30%↓", "사전 통제로\n미비점 예방", ORANGE),
    ("⚡", "감사 대응\n시간 단축", "50%↓", "보고서 자동화 및\n근거 자료 즉시 제공", RED),
]
for i, (icon, title, val, sub, col) in enumerate(quant):
    lx = 0.35 + i * 3.25
    add_rect(slide, lx, 1.5, 3.05, 2.0, WHITE)
    bg = slide.shapes[-1]; bg.line.color.rgb=col; bg.line.width=Pt(2)
    add_rect(slide, lx, 1.5, 3.05, 0.45, col)
    add_text_box(slide, f"{icon}  {title}", lx+0.15, 1.55, 2.75, 0.38,
                 font_size=11, bold=True, color=WHITE)
    add_text_box(slide, val, lx+0.15, 2.05, 2.75, 0.65,
                 font_size=30, bold=True, color=col, align=PP_ALIGN.CENTER)
    add_text_box(slide, sub, lx+0.15, 2.72, 2.75, 0.65,
                 font_size=9, color=GRAY, align=PP_ALIGN.CENTER)

# 준거성 강화
add_rect(slide, 0.35, 3.7, 6.1, 2.1, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=NAVY; s.line.width=Pt(1.5)
add_rect(slide, 0.35, 3.7, 6.1, 0.42, NAVY)
add_text_box(slide, "🏛  준거성·감사 대응 강화", 0.5, 3.75, 5.7, 0.35,
             font_size=13, bold=True, color=WHITE)
compliance = [
    "COSO 2013 내부통제 프레임워크 완전 준수",
    "금융보안원 ISMS-P 통제 항목 매핑 가능",
    "외부감사인 요청 근거자료 즉시 조회·출력",
    "감사 추적(Audit Trail) 이력 보관",
]
for i, c in enumerate(compliance):
    add_text_box(slide, f"✓  {c}", 0.5, 4.23+i*0.37, 5.8, 0.33,
                 font_size=10, color=NAVY)

# 향후 발전
add_rect(slide, 6.75, 3.7, 6.25, 2.1, WHITE)
s = slide.shapes[-1]; s.line.color.rgb=BLUE; s.line.width=Pt(1.5)
add_rect(slide, 6.75, 3.7, 6.25, 0.42, BLUE)
add_text_box(slide, "🚀  향후 발전 로드맵", 6.9, 3.75, 5.9, 0.35,
             font_size=13, bold=True, color=WHITE)
roadmap = [
    "AI 기반 위험 자동 식별 및 이상징후 탐지",
    "모바일 앱 지원 (평가자 현장 증빙 촬영)",
    "타 시스템 연계 (ERP, SIEM, IAM)",
    "그룹사 간 벤치마킹 리포트 기능",
]
for i, r in enumerate(roadmap):
    add_text_box(slide, f"▸  {r}", 6.9, 4.23+i*0.37, 6.0, 0.33,
                 font_size=10, color=NAVY)

# ═══════════════════════════════════════════════════════════
# 슬라이드 13 – 마무리 슬라이드
# ═══════════════════════════════════════════════════════════
slide = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_bg(slide, NAVY)

add_rect(slide, 0, 0, 13.33, 0.1, BLUE)
add_rect(slide, 0, 7.4, 13.33, 0.1, BLUE)
add_rect(slide, 9.5, 0, 3.83, 7.5, RGBColor(0x12,0x20,0x38))

add_text_box(slide, "🛡", 0.8, 1.5, 1.5, 1.5, font_size=52, color=BLUE)
add_text_box(slide, "감사합니다",
             0.8, 2.7, 8.0, 1.0, font_size=44, bold=True, color=WHITE)
add_rect(slide, 0.8, 3.75, 5.0, 0.07, BLUE)
add_text_box(slide,
             "그룹사 ITGC 포털은 COSO 2013 프레임워크를 기반으로\n"
             "IT 일반통제의 체계적 관리와 운영평가를 지원합니다.",
             0.8, 3.95, 8.0, 1.0,
             font_size=14, color=RGBColor(0xC0,0xD8,0xF0))

# 문의·연락
add_rect(slide, 0.8, 5.2, 4.5, 1.5, RGBColor(0x14,0x28,0x44))
add_text_box(slide, "📧  시스템 문의", 1.0, 5.28, 4.0, 0.38,
             font_size=12, bold=True, color=BLUE)
add_text_box(slide, "ITGC 포털 관리팀\nitgc-admin@company.com",
             1.0, 5.68, 4.0, 0.82, font_size=11, color=WHITE)

# 우측 요약
summary = [
    ("📊", "대시보드 & KPI"),
    ("⚠", "위험 식별·평가·매트릭스"),
    ("🛡", "통제 활동 & 매핑"),
    ("📝", "운영평가 계획·실행·결과"),
    ("🔎", "발견사항 & Kanban 개선조치"),
    ("📄", "보고서 & 시스템 설정"),
]
add_text_box(slide, "주요 기능 요약", 10.0, 1.2, 3.0, 0.42,
             font_size=12, bold=True, color=BLUE)
for i, (icon, label) in enumerate(summary):
    add_text_box(slide, f"{icon}  {label}", 10.0, 1.75+i*0.75, 3.1, 0.55,
                 font_size=10.5, color=WHITE)

# ── 저장 ────────────────────────────────────────────────────
output_path = "/home/user/ITGC/docs/ITGC_Portal_User_Guide.pptx"
import os; os.makedirs("/home/user/ITGC/docs", exist_ok=True)
prs.save(output_path)
print(f"PPT 생성 완료: {output_path}")
print(f"총 슬라이드 수: {len(prs.slides)}")
