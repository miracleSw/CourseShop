---
name: CourseShop Engineering Lab
description: Tactile Lab Binder Manual design system for Vietnamese IT programming courses, learning paths, and focused e-learning workspaces.
colors:
  blueprint: "#23469E"
  blueprint-hover: "#1B377E"
  blueprint-soft: "#E6EEFC"
  amber-pro: "#B45309"
  amber-pro-hover: "#92400E"
  amber-bar: "#D97706"
  amber-soft: "#FEF3C7"
  amber-ink: "#78350F"
  emerald-ok: "#15803D"
  emerald-soft: "#DCFCE7"
  danger: "#B91C1C"
  danger-soft: "#FEE2E2"
  paper: "#F4F1EA"
  paper-soft: "#FAF8F3"
  paper-tab: "#EAE5DA"
  sheet: "#FFFFFF"
  ink: "#16181D"
  ink-muted: "#4A4E57"
  ink-subtle: "#5C616B"
  rule: "#D6D1C4"
  theatre: "#11151B"
  theatre-panel: "#191F28"
  theatre-border: "#2B3340"
typography:
  display:
    fontFamily: "\"Be Vietnam Pro\", system-ui, -apple-system, sans-serif"
    fontSize: "2.5rem"
    fontWeight: 800
    lineHeight: 1.08
    letterSpacing: "-0.025em"
  headline:
    fontFamily: "\"Be Vietnam Pro\", system-ui, -apple-system, sans-serif"
    fontSize: "1.625rem"
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: "-0.02em"
  title:
    fontFamily: "\"Be Vietnam Pro\", system-ui, -apple-system, sans-serif"
    fontSize: "0.9375rem"
    fontWeight: 800
    lineHeight: 1.35
    letterSpacing: "0em"
  body:
    fontFamily: "\"Be Vietnam Pro\", system-ui, -apple-system, sans-serif"
    fontSize: "0.9375rem"
    fontWeight: 400
    lineHeight: 1.625
    letterSpacing: "0em"
  label:
    fontFamily: "\"Be Vietnam Pro\", system-ui, -apple-system, sans-serif"
    fontSize: "0.8125rem"
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: "0em"
  mono:
    fontFamily: "\"JetBrains Mono\", ui-monospace, SFMono-Regular, Consolas, monospace"
    fontSize: "0.75rem"
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: "0em"
    fontFeature: "\"tnum\""
rounded:
  xs: "4px"
  sm: "6px"
  md: "8px"
  lg: "10px"
  xl: "12px"
  full: "9999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
  2xl: "40px"
components:
  button-primary:
    backgroundColor: "{colors.blueprint}"
    textColor: "{colors.sheet}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    padding: "10px 16px"
  button-primary-hover:
    backgroundColor: "{colors.blueprint-hover}"
    textColor: "{colors.sheet}"
  button-pro:
    backgroundColor: "{colors.amber-pro}"
    textColor: "{colors.sheet}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    padding: "10px 16px"
  button-pro-hover:
    backgroundColor: "{colors.amber-pro-hover}"
    textColor: "{colors.sheet}"
  button-ink:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.paper-soft}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    padding: "10px 16px"
  button-outline:
    backgroundColor: "{colors.paper-soft}"
    textColor: "{colors.ink}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    padding: "10px 16px"
  input-lab:
    backgroundColor: "{colors.sheet}"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.sm}"
    padding: "9px 14px"
  chip-free:
    backgroundColor: "{colors.blueprint-soft}"
    textColor: "{colors.blueprint}"
    typography: "{typography.mono}"
    rounded: "{rounded.xs}"
    padding: "2px 8px"
  chip-pro:
    backgroundColor: "{colors.amber-soft}"
    textColor: "{colors.amber-ink}"
    typography: "{typography.mono}"
    rounded: "{rounded.xs}"
    padding: "2px 8px"
  binder-sheet:
    backgroundColor: "{colors.sheet}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    padding: "20px 28px"
  course-card:
    backgroundColor: "{colors.sheet}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    padding: "14px"
---

# Design System: CourseShop Engineering Lab

## Overview

**Creative North Star: "The Engineering Lab Binder Manual"**

CourseShop treats programming education as a tactile engineering handbook rather than a flash-sale marketplace or dark neon SaaS pitch. Warm limestone paper grounds frame crisp white binder sheets separated by physical top-attached career-path tabs, carbon-ink structural rules, and disciplined two-color coding that immediately distinguishes 0đ foundation labs from paid production projects.

Every visual token earns its place through utility: typography preserves crisp Vietnamese diacritics across headings and dense syllabus tables, monospaced tabular numerals keep VND prices, course codes (`LAB-01`, `PRO-02`), and video timestamps aligned vertically, and dark surfaces appear only where video playback demands zero glare inside `/learn`.

**Key Characteristics:**
- Tactile limestone paper ground (`#F4F1EA`) paired with crisp white ink-ruled index sheets (`#FFFFFF`) and structural 1.5px carbon-ink borders (`#16181D`).
- Strict dual-accent semantic coding: Blueprint Indigo exclusively for Free foundation tracks and primary learning flows; Safety Amber exclusively for Pro projects, discounts, and paid conversion actions.
- Physical top-attached Lab Binder tabs that fuse seamlessly into the active white syllabus sheet without dividing lines.
- Vietnamese-crisp neo-grotesk sans (`Be Vietnam Pro`) paired with tabular monospaced engineering codes (`JetBrains Mono`), both self-hosted as local `.woff2` assets.
- Zero decorative kickers, zero neon gradients, zero emoji chrome (100% Lucide stroke icons), and a dedicated dark-theatre learning surface (`/learn`).

## Colors

The palette anchors on uncoated archival paper and carbon ink, using only two chromatic voices with strict semantic ownership plus dedicated status tones and a dark video-theatre pair.

### Primary
- **Blueprint Indigo** (`#23469E`): Primary learning accent — used for Free foundation course bars, Free enrollment CTAs, brand spine mark, active lesson indicators, form focus rings, and text caret.
- **Deep Blueprint** (`#1B377E`): Hover and pressed state for primary Blueprint actions.
- **Blueprint Wash** (`#E6EEFC`): Soft tint behind `MIỄN PHÍ` status pills, active lesson highlight rows, and inline filter indicators.

### Secondary
- **Safety Amber Pro** (`#B45309`): WCAG AA accessible Pro CTA fill and discount badge background (darkened from pure amber so white button labels stay above 4.5:1 contrast).
- **Burnished Amber Hover** (`#92400E`): Hover state for Pro action buttons.
- **Signal Amber Bar** (`#D97706`): 8px top status rule on Pro course cards, admin spine accent, and rating stars.
- **Parchment Amber Tint** (`#FEF3C7`) with **Espresso Amber Ink** (`#78350F`): Pro price tags, Pro binder tab fill, and AI fallback notice banner.

### Tertiary
- **Lab Emerald** (`#15803D`) & **Emerald Wash** (`#DCFCE7`): Completed lessons, owned course badges (`ĐÃ SỞ HỮU`), paid order pills (`PAID`), and progress fills.
- **Signal Crimson** (`#B91C1C`) & **Crimson Wash** (`#FEE2E2`): Destructive actions, validation errors, declined payment states, and filter resets.

### Neutral
- **Limestone Paper** (`#F4F1EA`): Root page canvas and scrollbar track.
- **Soft Paper** (`#FAF8F3`): Sticky top navigation bar, syllabus index panel, outline buttons, and admin sidebar.
- **Binder Tab Putty** (`#EAE5DA`): Inactive binder tab fill and hover fill for outline controls.
- **Crisp Sheet** (`#FFFFFF`): Active binder sheet, course cards, form fields, modals, and tables.
- **Carbon Ink** (`#16181D`): Primary body text, headings, primary structural 1.5px borders, and high-contrast dark buttons (`Đăng nhập`, `+ Giỏ hàng`).
- **Graphite Muted** (`#4A4E57`): Secondary copy, inactive tab text, and syllabus metadata (~6.7:1+ contrast on tab putty and paper).
- **Slate Subtle** (`#5C616B`): Placeholders and struck-through original prices.
- **Warm Rule** (`#D6D1C4`): Hairline internal dividers, dashed syllabus separators, and secondary borders.
- **Theatre Charcoal** (`#11151B`), **Theatre Panel** (`#191F28`), and **Theatre Rule** (`#2B3340`): Dedicated glare-free header and video stage on `/learn`.

### Named Rules
- **The Dual-Ink Ownership Rule.** Blueprint Indigo (`#23469E`) owns Free foundations and learning progress; Amber (`#B45309` / `#D97706`) owns Pro projects and commercial discounts. Never swap them or introduce competing brand hues.
- **The AA Amber Text Rule.** White text on amber surfaces uses `#B45309` (not `#D97706`), while light `#FEF3C7` badges always pair with `#78350F` text to stay safely above WCAG AA 4.5:1.

## Typography

**Display Font:** `Be Vietnam Pro` (fallback: `system-ui, -apple-system, sans-serif`)
**Body Font:** `Be Vietnam Pro` (fallback: `system-ui, -apple-system, sans-serif`)
**Label/Mono Font:** `JetBrains Mono` (fallback: `ui-monospace, SFMono-Regular, Consolas, monospace`)

**Character:** `Be Vietnam Pro` delivers balanced geometric proportions engineered specifically for stacked Vietnamese diacritics without clipping ascenders, while `JetBrains Mono` anchors course codes (`LAB-01`, `PRO-02`), module indices (`01.`–`04.`), timestamps (`02:15`), and VND currency in crisp tabular rhythm.

### Hierarchy
- **Display** (`800`, `28px–40px` responsive / `2.5rem` desktop, `1.08` line-height, `-0.025em` tracking): Storefront hero thesis headline inside the active binder sheet.
- **Headline** (`800`, `22px–26px` / `1.625rem`, `1.2` line-height): Section titles (`Danh mục giáo trình đang mở`, Admin page headers, checkout titles).
- **Title** (`800`, `15px` / `0.9375rem`, `1.35` line-height): Course card titles, syllabus section headings, and panel titles.
- **Body** (`400`, `14.5px–15px` / `0.9375rem`, `1.625` line-height, `54ch–70ch` max measure): Value propositions, course overviews, lesson descriptions, and notes.
- **Label** (`700`, `13px–14px` / `0.8125rem`, `1.3` line-height): Navigation links, binder tab names, form labels, and button labels.
- **Mono Metadata** (`700`, `11px–12px` / `0.75rem`, `tabular-nums`): Course IDs, lesson durations, timestamps, VND prices, order numbers, and table KPIs.

### Named Rules
- **The Zero-Kicker Rule.** Headlines open directly with the thesis; never place uppercase tracked eyebrows or pill kickers above `h1` or section headings.
- **The Tabular Currency Rule.** Every VND price, lesson duration, timestamp, order number, and KPI counter applies `font-variant-numeric: tabular-nums` so numbers align cleanly across grids and admin ledgers.

## Layout

CourseShop uses an edge-to-edge 66px top bar over a centered `1360px` max-width container (`px-4` mobile, `px-6` tablet, `px-10` desktop) on marketing and catalog views, switching to a full-viewport (`100vh`) split workspace on `/learn` and a fixed `248px` left sidebar + fluid ledger canvas on `/admin/*`.

- **First-Viewport Budget (1440×900):** Top bar (`66px`) + Hero Binder Tabs & Sheet (~`375px`) + Catalog Header & Filter Bar (`64px`) + complete first row of 4 course cards (`339px`, ending at `y = 880px`), keeping both Free foundations (`LAB-01`, `LAB-02`) and Pro courses (`PRO-01`, `PRO-02`) visible above the fold.
- **Grid Breakpoints:** Course catalog scales `1 col` (`<640px`) → `2 cols` (`640px–1023px`) → `4 cols` (`>=1024px`) with `16px` (`gap-4`) gutters. Hero binder sheet splits `12 cols` (`7/5` left thesis / right syllabus index) at `lg` (`1024px`) and stacks cleanly on mobile.
- **Learning Workspace (`/learn`):** Dark `56px` top progress header + fluid video/notes column (`max-w-[1060px]` video stage) + collapsible `340px` right syllabus sidebar + sticky `56px` bottom Previous/Next footer.
- **Vertical Rhythm:** Built on a `4px` base step (`8px`, `14px`, `16px`, `20px`, `28px`, `32px`), keeping more space above section headings than below them.

## Elevation & Depth

Surfaces rely primarily on **1.5px carbon-ink structural framing** and warm tonal paper shifts (`#F4F1EA` → `#EAE5DA` → `#FAF8F3` → `#FFFFFF`) rather than heavy drop shadows. Soft diffused ink shadows appear only to anchor primary binder sheets, lift hovered course cards, or elevate floating drawers and modals.

### Shadow Vocabulary
- **Sheet Rest** (`box-shadow: 0 10px 28px -18px rgba(22, 24, 29, 0.22)`): Subtle paper grounding beneath `.binder-sheet` panels.
- **Card Hover Lift** (`box-shadow: 0 14px 28px -16px rgba(22, 24, 29, 0.28)` with `translateY(-2px)`): Tactile feedback when hovering `.course-card` entries.
- **Floating Surface** (`box-shadow: 0 25px 50px -12px rgba(22, 24, 29, 0.25)`): Reserved for overlays — preview modal, AI chat drawer, toast alerts, and mobile slide-over drawers.
- **Focus Ring** (`box-shadow: 0 0 0 3px rgba(35, 70, 158, 0.16)` or `2px solid #23469E` outline with `2px` offset): Keyboard focus state across inputs and interactive controls.

### Named Rules
- **The Structural Ink Rule.** Never use hard offset neobrutalist shadows (`4px 4px 0 #000`); crispness comes from `1.5px solid #16181D` borders paired with restrained diffused lift on state changes.

## Shapes

Form language favors crisp mechanical radii matching printed index cards and tabbed lab folders:

- **Binder Tabs:** `8px 8px 0 0` top corners, `1.5px solid #16181D` border, fusing flush into the sheet below (`margin-bottom: -1.5px`, active tab `border-bottom-color: #FFFFFF`).
- **Active Binder Sheet:** `0 10px 10px 10px` (`rounded-b-[10px] rounded-tr-[10px]`) so tab `01` aligns flush down the left spine without an awkward corner notch.
- **Course Cards:** `8px` outer radius (`rounded-[8px]`), `1.5px solid #16181D` frame, topped by a full-bleed `8px` chromatic status bar (`#23469E` Free or `#D97706` Pro) above an `aspect-[2/1]` technical cover.
- **Controls & Inputs:** `5px–6px` crisp mechanical radius (`rounded-[5px]` / `rounded-[6px]`) for buttons, selects, and text inputs; `4px` (`rounded`) for status chips; `9999px` full pill reserved strictly for progress tracks, floating AI trigger, and step indicators.

## Components

Every component is built from carbon-ink framing, clear state contrast, and concise Vietnamese production copy.

### Buttons
- **Shape:** Crisp rounded rectangle (`6px` radius, `1.5px` border, `font-weight: 700`).
- **Primary (Blueprint):** `#23469E` fill, `#FFFFFF` text, `10px 16px` padding; hover darkens to `#1B377E`. Used for Free enrollment, primary form submission, and next-lesson navigation.
- **Pro (Amber):** `#B45309` fill, `#FFFFFF` text; hover darkens to `#92400E`. Used for Pro catalog actions, Stripe checkout confirmation, and paid upgrades.
- **Carbon Ink:** `#16181D` fill, `#FAF8F3` text; hover `#2B2F3A`. Used for `Đăng nhập` and card `+ Giỏ hàng` buttons.
- **Outline Paper:** `#FAF8F3` fill, `#16181D` text and `1.5px` border; hover shifts to `#EAE5DA`. Used for `Học ngay` (Free card CTA), `Bài trước`, and secondary utility actions.

### Chips
- **Style:** `4px` radius, `JetBrains Mono` `10.5px–11.5px` bold, `2px 8px` padding, `tabular-nums`.
- **Variants:** Free (`#E6EEFC` bg / `#23469E` text), Pro (`#FEF3C7` bg / `#78350F` text), Owned/Paid (`#DCFCE7` bg / `#15803D` text), Declined/Error (`#FEE2E2` bg / `#B91C1C` text).

### Cards / Containers
- **Corner Style:** `8px` (`course-card`) or `10px` (`binder-sheet`).
- **Background:** Crisp Sheet (`#FFFFFF`) over Limestone Paper (`#F4F1EA`).
- **Shadow Strategy:** Flat at rest for course cards (`Sheet Rest` for hero binder); lifts `-2px` with `Card Hover Lift` on hover.
- **Border:** `1.5px solid #16181D`, with an internal `1px solid #D6D1C4` footer divider.
- **Internal Padding:** `14px` (`p-3.5`) on catalog cards; `20px 28px` on hero binder sheets.

### Inputs / Fields
- **Style:** `#FFFFFF` fill, `1.5px solid #16181D` border, `6px` radius, `9px 14px` padding (`36px` height on filter selects).
- **Custom Select (`lab-select`):** Strips native OS dropdown triangles (`appearance: none`, `::picker-icon { display: none }`) and pairs `pr-8` clearance with a crisp `14px` Lucide `chevron-down` indicator.
- **Focus:** Border shifts to `#23469E` with `3px` soft blueprint glow (`rgba(35, 70, 158, 0.16)`).

### Navigation
- **Top Bar:** Sticky `66px` edge-to-edge `#FAF8F3` bar with `1.5px` bottom carbon-ink rule, brand spine badge (`6px × 24px` `#23469E` tab), 4–5 concise links (active underline `2px solid #16181D`), ink-bordered search bar, cart counter, and single-line `Đăng nhập` / user menu. Collapses cleanly on `<1024px` into a right slide-over drawer.
- **Admin Sidebar:** Fixed `248px` `#FAF8F3` rail with `1.5px` right rule, amber brand spine, active carbon-ink nav pill, and sticky admin profile footer.

### Tabbed Binder Sheet
- **Signature Component:** Horizontal `role="tablist"` (`margin-bottom: -1.5px; z-index: 10`) positioned directly atop `.binder-sheet`. Active tab (`data-active="true"`) uses `#FFFFFF` background and `#FFFFFF` bottom border to physically dissolve the sheet's top rule, while Alpine.js simultaneously swaps the numbered `01.`–`04.` syllabus sheet and filters the course index grid below without page reload.

### Video Learning Workspace & AI Chat Drawer
- **Operate Mode (`/learn`):** Dark `#11151B` top progress bar and `#0B0E13` 16:9 video theatre paired with limestone-paper lesson tabs (`Nội dung bài học`, `Ghi chú timestamp`) and a collapsible `340px` syllabus drawer.
- **Contextual AI Drawer:** Fixed bottom-right trigger (`w-11 h-11` circular icon-only on mobile `<640px` to keep content unobstructed; compact labeled pill on desktop) opening a `1.5px` ink-framed Gemini drawer (`w-[322px]` on `/learn` to stay completely inside the right syllabus column with zero video overlap).

## Do's and Don'ts

### Do:
- **Do** fuse active binder tabs seamlessly into `.binder-sheet` using `.binder-tablist` negative overlap (`-1.5px`) and matching `#FFFFFF` bottom border.
- **Do** present both Free (`LAB-*`, Blueprint Indigo) and Pro (`PRO-*`, Safety Amber) courses visibly in the storefront's first viewport so learners see the 0đ-to-Pro progression immediately.
- **Do** self-host `Be Vietnam Pro` and `JetBrains Mono` `.woff2` subsets with `tabular-nums` on every VND price, lesson duration, timestamp, and order code.
- **Do** wrap Vietnamese titles naturally inside syllabus cards and mobile views instead of mid-word `truncate` clipping.
- **Do** keep `select.lab-select` free of native OS triangles by pairing `appearance: none` with Lucide `chevron-down` icons and `pr-8` clearance.
- **Do** keep toasts anchored at `bottom-left` so they never cover top-right header CTAs or the bottom-right AI chat trigger.

### Don't:
- **Don't** add Bootstrap, generic glassmorphism, neon glow gradients, or hard offset neobrutalist shadows anywhere in the system.
- **Don't** place uppercase tracked kickers or pill eyebrows above `h1` or section headings.
- **Don't** use Unicode emojis as UI icons; always use Lucide stroke icons consistently.
- **Don't** place white text on `#D97706` or drop secondary text contrast below WCAG AA `4.5:1` (never add `opacity-75` to `#4A4E57` labels on `#EAE5DA`).
- **Don't** duplicate filter controls (such as placing category pills immediately beneath a category `<select>` dropdown).
- **Don't** fabricate real-world commercial numbers, student testimonials, or partner logos; keep demo data honestly structured and disclosed.
