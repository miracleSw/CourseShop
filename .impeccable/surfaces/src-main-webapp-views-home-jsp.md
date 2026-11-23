---
version: 1
slug: "src-main-webapp-views-home-jsp"
primary_target: "src/main/webapp/views/home.jsp"
related_targets: ["src/main/webapp/views/paths.jsp","src/main/webapp/views/course-detail.jsp"]
---

# Surface Brief: CourseShop Storefront (`home.jsp`)

- **Scope & Mode**: Primary Storefront Landing & Course Catalog (`/home`, `/paths`, `/course`) — **Persuade** mode (code-led from chosen sketch `.impeccable/mocks/decision/r2-pick.html`).
- **Audience & Job**: Vietnamese IT students and career-switchers deciding which programming track to follow and verifying quality via 1-click Free foundations before purchasing Pro project courses.
- **Primary Action & Proof**: Switch learning-path binder tabs interactively (`01 Fullstack Web`, `02 Java Backend`, `03 Frontend React`, `Pro Stripe & AI`), register for Free foundation courses in 1 click, preview syllabus videos, or add Pro courses to cart.
- **Constraints**: Java 21 + Jakarta EE 10 Maven (`src/main/webapp`), Tailwind CSS v4 (`@tailwindcss/cli` -> static `assets/css/app.css`) + Alpine.js 3 + Lucide Icons, full Vietnamese UTF-8, `tabular-nums` VND pricing, WCAG AA contrast, zero Bootstrap, zero fabricated commercial claims.

## Direction contract

- **THESIS**: CourseShop rejects the cluttered discount-coupon grid and neon-SaaS template by presenting programming education as a tactile **Engineering Lab Binder Manual** — tabbed career-path dividers open directly into a numbered syllabus sheet where Free foundations lead cleanly into Pro production projects.
- **OWN-WORLD**: Warm uncoated limestone paper (`#F4F1EA`), crisp white index sheets (`#FFFFFF`), carbon ink (`#16181D`) 1.5px structural rules, blueprint-indigo (`#23469E`) exclusively for Free tracks and primary learning actions, and safety-amber (`#D97706`) exclusively for Pro projects, discounts, and paid CTAs; clean Vietnamese-crisp neo-grotesk sans (`Be Vietnam Pro`) paired with monospaced tabular codes (`JetBrains Mono`) for course IDs (`LAB-01`, `PRO-03`), lesson counts, durations, and VND prices.
- **STORY**: Within five seconds, a student sees their exact career binder tab, scans the ordered 01→04 module sheet separating 0đ Free courses from paid Pro projects, trusts the engineering rigor, and clicks either **Đăng ký miễn phí 1-click** or **Xem / Thêm vào giỏ**.
- **FIRST VIEWPORT**: Edge-to-edge 66px ink-ruled top bar (CourseShop Engineering Lab mark with indigo spine tab, 5 concise links, ink-bordered search input, cart badge, Đăng nhập), immediately followed by physical top-attached binder tabs (`01 · Lộ trình Fullstack Web`, `02 · Java Backend Engineer`, `03 · Frontend React`, `★ Khóa Pro Stripe & AI`) opening seamlessly into a white 1.5px ink-framed binder sheet split 1.15fr / 1fr (headline + value copy + dual indigo/amber CTAs on the left; numbered 4-module syllabus index card with Free/Pro status pills on the right), with the 4-column ink-ruled course grid (8px indigo/amber top status bars, course codes, VND prices, direct actions) beginning cleanly in the lower viewport.
- **FORM**: Lab Binder Manual (grounded candidate #1, IMPECCABLE’S PICK on Reroll Round 1), `seed:5b1174fb91751654`, chosen sketch `.impeccable/mocks/decision/r2-pick.html`, signature interaction: live Alpine.js binder-tab switching that swaps the active career syllabus sheet and filters the course index below without layout jank, plus instant 1-click Free enrollment and contextual Gemini AI study advisor.
- **FINISH**: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance.
