<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/navbar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<script>
window.__TRACK_MAP__ = [
<c:forEach var="lp" items="${learningPaths}" varStatus="st">
  {
    title: "<c:out value='${lp.title}'/>",
    ids: [<c:forEach var="pc" items="${lp.courses}" varStatus="cst">${pc.id}<c:if test="${!cst.last}">,</c:if></c:forEach>]
  }<c:if test="${!st.last}">,</c:if>
</c:forEach>
];
</script>

<main class="flex-1"
      x-data="{
        activeTab: 0,
        trackFilter: false,
        tracks: window.__TRACK_MAP__ || [],
        selectTab(idx) {
          this.activeTab = idx;
          this.trackFilter = true;
        },
        matchesTrack(courseId) {
          if (!this.trackFilter) return true;
          const t = this.tracks[this.activeTab];
          return !t || !t.ids || t.ids.length === 0 || t.ids.includes(courseId);
        }
      }">
    <!-- Hero: Lab Binder Manual Tabbed Career Sheet -->
    <section class="max-w-[1360px] mx-auto px-4 sm:px-6 lg:px-10 pt-3 pb-4">

        <!-- Physical Top Binder Tabs (seams flush into white sheet below) -->
        <div class="relative">
            <div class="binder-tablist flex items-end gap-1.5 overflow-x-auto no-scrollbar pr-8 lg:pr-0" role="tablist" aria-label="Lộ trình học tập">
                <c:forEach var="lp" items="${learningPaths}" varStatus="st">
                    <button type="button" role="tab"
                            @click="selectTab(${st.index})"
                            :data-active="activeTab === ${st.index}"
                            :aria-selected="activeTab === ${st.index}"
                            class="binder-tab shrink-0 px-3.5 sm:px-5 py-2 text-[12.5px] sm:text-[13px] font-extrabold tracking-tight cursor-pointer">
                        <span class="font-mono text-[11.5px] sm:text-[12px] mr-1.5 text-ink-muted">${lp.code}</span>
                        <span><c:out value="${lp.title}"/></span>
                    </button>
                </c:forEach>
                <a href="${pageContext.request.contextPath}/home?type=pro#catalog"
                   class="binder-tab shrink-0 px-3.5 sm:px-5 py-2 text-[12.5px] sm:text-[13px] font-extrabold bg-amber-soft text-amber-ink border-b-ink hover:bg-[#FDE68A] inline-flex items-center gap-1.5">
                    <i data-lucide="award" class="w-3.5 h-3.5"></i>
                    <span>Khóa học Pro</span>
                </a>
            </div>
            <div class="pointer-events-none lg:hidden absolute top-0 bottom-[1.5px] right-0 w-10 bg-gradient-to-l from-paper via-paper/80 to-transparent z-20" aria-hidden="true"></div>
        </div>

        <!-- Active White Binder Sheet -->
        <div class="binder-sheet rounded-b-[10px] rounded-tr-[10px] p-5 sm:p-6 lg:px-7 lg:py-5">
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-5 lg:gap-8 items-center">
                <!-- Left Thesis & Dual Actions -->
                <div class="lg:col-span-7 space-y-3.5">
                    <h1 class="text-[28px] sm:text-[36px] lg:text-[40px] font-extrabold leading-[1.08] tracking-[-0.025em] text-ink text-balance">
                        <c:out value="${not empty siteSettings['site.hero_title'] ? siteSettings['site.hero_title'] : 'Học lập trình theo lộ trình bài bản, làm ra sản phẩm thật'}"/>
                    </h1>
                    <p class="text-[14.5px] leading-relaxed text-ink-muted max-w-[54ch]">
                        <c:out value="${siteSettings['site.hero_subtitle']}"/>
                    </p>
                    <div class="flex flex-wrap items-center gap-3 pt-1">
                        <a href="${pageContext.request.contextPath}/home?type=free#catalog"
                           class="btn-blueprint px-4 py-2.5 text-[14px]">
                            <i data-lucide="play-circle" class="w-4 h-4"></i>
                            <span>Học miễn phí ngay (0đ)</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/home?type=pro#catalog"
                           class="btn-pro px-4 py-2.5 text-[14px]">
                            <i data-lucide="layers" class="w-4 h-4"></i>
                            <span>Xem giáo trình Pro</span>
                        </a>
                    </div>
                </div>

                <!-- Right Live Syllabus Index Panel (swaps per selected Binder Tab) -->
                <div class="lg:col-span-5">
                    <c:forEach var="lp" items="${learningPaths}" varStatus="st">
                        <div x-show="activeTab === ${st.index}"
                             <c:if test="${st.index > 0}">x-cloak</c:if>
                             class="sheet-reveal bg-paper-soft border-[1.5px] border-rule rounded-lg p-4">
                            <div class="flex items-start justify-between gap-2 pb-2 mb-1.5 border-b border-rule font-mono text-[11.5px] font-bold text-ink-muted leading-snug">
                                <span class="uppercase"><c:out value="${lp.targetRole}"/></span>
                                <span class="shrink-0 tabular-nums">${lp.courses.size()} học phần</span>
                            </div>

                            <ol class="divide-y divide-dashed divide-rule">
                                <c:forEach var="pc" items="${lp.courses}" varStatus="cst">
                                    <li class="py-1.5 flex items-start justify-between gap-2.5">
                                        <a href="${pageContext.request.contextPath}/course?slug=${pc.slug}"
                                           class="flex items-baseline gap-2 min-w-0 group">
                                            <span class="font-mono text-[11.5px] font-bold text-ink-muted tabular-nums shrink-0">0${cst.count}.</span>
                                            <span class="text-[13px] font-semibold text-ink leading-snug group-hover:text-blueprint group-hover:underline">
                                                <c:out value="${pc.title}"/>
                                            </span>
                                        </a>
                                        <c:choose>
                                            <c:when test="${ownedIds.contains(pc.id)}">
                                                <span class="shrink-0 mt-0.5 font-mono text-[10.5px] font-bold px-2 py-0.5 rounded bg-emerald-soft text-emerald-ok">ĐÃ SỞ HỮU</span>
                                            </c:when>
                                            <c:when test="${pc.free}">
                                                <span class="shrink-0 mt-0.5 font-mono text-[10.5px] font-bold px-2 py-0.5 rounded bg-blueprint-soft text-blueprint">MIỄN PHÍ</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="shrink-0 mt-0.5 font-mono text-[11px] font-bold px-2 py-0.5 rounded bg-amber-soft text-amber-ink tabular-nums">
                                                    ${pc.formattedEffectivePrice}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </li>
                                </c:forEach>
                            </ol>

                            <div class="pt-2.5 mt-1.5 border-t border-rule flex flex-wrap items-center justify-between gap-2 text-[12px]">
                                <span class="text-ink-muted leading-snug flex-1 min-w-[180px]"><c:out value="${lp.summary}"/></span>
                                <a href="${pageContext.request.contextPath}/paths#${lp.slug}"
                                   class="shrink-0 font-bold text-blueprint hover:underline inline-flex items-center gap-1">
                                    <span>Mở lộ trình</span>
                                    <i data-lucide="arrow-up-right" class="w-3.5 h-3.5"></i>
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </section>

    <!-- Course Catalog Section -->
    <section id="catalog" class="max-w-[1360px] mx-auto px-4 sm:px-6 lg:px-10 pt-0.5 pb-16">
        <div class="flex flex-col md:flex-row md:items-end justify-between gap-3 pb-2.5 mb-3.5 border-b-[1.5px] border-ink">
            <div>
                <h2 class="text-[22px] sm:text-[26px] font-extrabold tracking-tight text-ink leading-tight">
                    Danh mục giáo trình đang mở
                </h2>
                <div class="text-[13.5px] text-ink-muted mt-1 flex flex-wrap items-center gap-x-2 gap-y-1">
                    <span>
                        Hiển thị <strong class="font-mono text-ink tabular-nums">${totalCourses}</strong> khóa học
                        <c:if test="${not empty filterQ}">cho từ khóa "<strong class="text-ink"><c:out value="${filterQ}"/></strong>"</c:if>
                    </span>
                    <span x-show="trackFilter" x-cloak
                          class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded bg-blueprint-soft text-blueprint font-bold text-[12px]">
                        <span>Lộ trình: <span x-text="tracks[activeTab]?.title"></span></span>
                        <button type="button" @click="trackFilter = false"
                                class="underline hover:text-ink ml-1 cursor-pointer">Xem tất cả</button>
                    </span>
                </div>
            </div>

            <!-- Styled SQL Filter Bar -->
            <form action="${pageContext.request.contextPath}/home#catalog" method="get"
                  class="flex flex-wrap items-center gap-2">
                <c:if test="${not empty filterQ}">
                    <input type="hidden" name="q" value="<c:out value='${filterQ}'/>">
                </c:if>

                <div class="relative">
                    <select name="type" onchange="this.form.submit()" aria-label="Loại khóa học"
                            class="lab-select appearance-none h-9 pl-3 pr-9 text-[13px] font-semibold bg-sheet border-[1.5px] border-ink rounded-[5px] text-ink cursor-pointer">
                        <option value="">Tất cả loại</option>
                        <option value="free" ${filterType == 'free' ? 'selected' : ''}>Miễn phí (0đ)</option>
                        <option value="pro" ${filterType == 'pro' ? 'selected' : ''}>Khóa học Pro</option>
                    </select>
                    <i data-lucide="chevron-down" class="w-3.5 h-3.5 text-ink pointer-events-none absolute right-2.5 top-1/2 -translate-y-1/2"></i>
                </div>

                <div class="relative">
                    <select name="category" onchange="this.form.submit()" aria-label="Danh mục"
                            class="lab-select appearance-none h-9 pl-3 pr-9 text-[13px] font-semibold bg-sheet border-[1.5px] border-ink rounded-[5px] text-ink cursor-pointer">
                        <option value="">Tất cả chủ đề</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.id}" ${filterCategory == cat.id ? 'selected' : ''}>
                                <c:out value="${cat.name}"/> (${cat.courseCount})
                            </option>
                        </c:forEach>
                    </select>
                    <i data-lucide="chevron-down" class="w-3.5 h-3.5 text-ink pointer-events-none absolute right-2.5 top-1/2 -translate-y-1/2"></i>
                </div>

                <div class="relative">
                    <select name="level" onchange="this.form.submit()" aria-label="Trình độ"
                            class="lab-select appearance-none h-9 pl-3 pr-9 text-[13px] font-semibold bg-sheet border-[1.5px] border-ink rounded-[5px] text-ink cursor-pointer">
                        <option value="">Mọi trình độ</option>
                        <option value="BEGINNER" ${filterLevel == 'BEGINNER' ? 'selected' : ''}>Người mới</option>
                        <option value="INTERMEDIATE" ${filterLevel == 'INTERMEDIATE' ? 'selected' : ''}>Trung cấp</option>
                        <option value="ADVANCED" ${filterLevel == 'ADVANCED' ? 'selected' : ''}>Đi làm / Nâng cao</option>
                    </select>
                    <i data-lucide="chevron-down" class="w-3.5 h-3.5 text-ink pointer-events-none absolute right-2.5 top-1/2 -translate-y-1/2"></i>
                </div>

                <div class="relative">
                    <select name="sort" onchange="this.form.submit()" aria-label="Sắp xếp"
                            class="lab-select appearance-none h-9 pl-3 pr-9 text-[13px] font-semibold bg-sheet border-[1.5px] border-ink rounded-[5px] text-ink cursor-pointer">
                        <option value="">Mặc định</option>
                        <option value="popular" ${filterSort == 'popular' ? 'selected' : ''}>Phổ biến nhất</option>
                        <option value="price_asc" ${filterSort == 'price_asc' ? 'selected' : ''}>Giá tăng dần</option>
                        <option value="price_desc" ${filterSort == 'price_desc' ? 'selected' : ''}>Giá giảm dần</option>
                    </select>
                    <i data-lucide="chevron-down" class="w-3.5 h-3.5 text-ink pointer-events-none absolute right-2.5 top-1/2 -translate-y-1/2"></i>
                </div>

                <c:if test="${hasActiveFilter}">
                    <a href="${pageContext.request.contextPath}/home#catalog"
                       class="h-9 px-3 inline-flex items-center gap-1 text-[13px] font-bold text-danger hover:underline">
                        <i data-lucide="x" class="w-3.5 h-3.5"></i>
                        <span>Xóa lọc</span>
                    </a>
                </c:if>
            </form>
        </div>

        <!-- Course Grid or Empty State -->
        <c:choose>
            <c:when test="${empty courses}">
                <div class="binder-sheet rounded-xl p-12 text-center max-w-xl mx-auto my-8">
                    <div class="w-12 h-12 rounded-lg bg-paper border border-rule grid place-items-center mx-auto mb-4 text-ink-muted">
                        <i data-lucide="search-x" class="w-6 h-6"></i>
                    </div>
                    <h3 class="text-[19px] font-extrabold text-ink">Không tìm thấy khóa học phù hợp</h3>
                    <p class="text-[14px] text-ink-muted mt-2 mb-6">
                        Thử bỏ bớt bộ lọc trình độ hoặc tìm từ khóa ngắn hơn như "Java", "SQL", "React".
                    </p>
                    <a href="${pageContext.request.contextPath}/home#catalog" class="btn-blueprint px-5 py-2.5 text-[14px]">
                        Xem toàn bộ khóa học
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                    <c:forEach var="c" items="${courses}">
                        <article x-show="matchesTrack(${c.id})" class="course-card flex flex-col">
                            <!-- Top Status Rule (8px Lab Binder coding) -->
                            <div class="h-2 ${c.pro ? 'bg-amber-bar' : 'bg-blueprint'}"></div>

                            <!-- Compact Technical Cover -->
                            <a href="${pageContext.request.contextPath}/course?slug=${c.slug}"
                               class="block relative aspect-[2/1] bg-ink overflow-hidden border-b border-rule">
                                <img src="${c.externalThumbnail ? '' : pageContext.request.contextPath}${c.externalThumbnail ? '' : '/'}${c.thumbnail}"
                                     alt="<c:out value='${c.title}'/>"
                                     loading="lazy"
                                     class="w-full h-full object-cover transition-transform duration-300 hover:scale-[1.03]">
                                <c:if test="${c.hasDiscount}">
                                    <span class="absolute top-2 right-2 font-mono text-[11px] font-bold px-2 py-0.5 rounded bg-amber-pro text-white tabular-nums">
                                        -${c.discountPercent}%
                                    </span>
                                </c:if>
                            </a>

                            <!-- Card Body -->
                            <div class="p-3.5 flex-1 flex flex-col">
                                <div class="flex items-center justify-between gap-2 mb-1.5 font-mono text-[11px] font-bold">
                                    <span class="${c.pro ? 'text-amber-pro' : 'text-blueprint'}">
                                        <c:out value="${c.code}"/> · ${c.pro ? 'PRO' : 'MIỄN PHÍ'}
                                    </span>
                                    <span class="text-ink-muted"><c:out value="${c.levelLabel}"/></span>
                                </div>

                                <h3 class="text-[15px] font-extrabold leading-snug text-ink line-clamp-2 min-h-[40px] mb-2">
                                    <a href="${pageContext.request.contextPath}/course?slug=${c.slug}"
                                       class="hover:text-blueprint transition-colors">
                                        <c:out value="${c.title}"/>
                                    </a>
                                </h3>

                                <div class="mt-auto space-y-2.5">
                                    <div class="flex items-center justify-between text-[12px] text-ink-muted font-mono tabular-nums">
                                        <span class="inline-flex items-center gap-1">
                                            <i data-lucide="book-open" class="w-3.5 h-3.5"></i>
                                            ${c.lessonCount} bài · ${c.formattedDuration}
                                        </span>
                                        <c:if test="${c.reviewCount > 0}">
                                            <span class="inline-flex items-center gap-1 font-bold text-ink">
                                                <i data-lucide="star" class="w-3.5 h-3.5 text-amber-bar fill-amber-bar"></i>
                                                ${c.avgRating}
                                            </span>
                                        </c:if>
                                    </div>

                                    <div class="pt-3 border-t border-rule flex items-center justify-between gap-2">
                                        <div class="tabular-nums">
                                            <c:choose>
                                                <c:when test="${c.free}">
                                                    <span class="text-[16px] font-extrabold text-blueprint">Miễn phí</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="text-[16px] font-extrabold text-ink leading-none">${c.formattedEffectivePrice}</div>
                                                    <c:if test="${c.hasDiscount}">
                                                        <div class="text-[11.5px] text-ink-subtle line-through mt-0.5">${c.formattedPrice}</div>
                                                    </c:if>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <c:choose>
                                            <c:when test="${ownedIds.contains(c.id)}">
                                                <a href="${pageContext.request.contextPath}/learn?courseId=${c.id}"
                                                   class="inline-flex items-center gap-1 px-3 py-1.5 rounded-[5px] bg-emerald-soft text-emerald-ok border border-emerald-ok/30 text-[12px] font-bold hover:bg-emerald-ok hover:text-white transition-colors">
                                                    <i data-lucide="play" class="w-3.5 h-3.5"></i>
                                                    <span>Vào học</span>
                                                </a>
                                            </c:when>
                                            <c:when test="${c.free}">
                                                <form action="${pageContext.request.contextPath}/enroll-free" method="post">
                                                    <input type="hidden" name="courseId" value="${c.id}">
                                                    <button type="submit"
                                                            class="btn-outline-ink px-3 py-1.5 text-[12px]">
                                                        <span>Học ngay</span>
                                                    </button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button"
                                                        onclick="addToCartAsync(${c.id}, this)"
                                                        class="btn-ink px-3 py-1.5 text-[12px]">
                                                    <i data-lucide="plus" class="w-3.5 h-3.5"></i>
                                                    <span>Giỏ hàng</span>
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </article>
                    </c:forEach>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <nav class="mt-10 flex items-center justify-center gap-2" aria-label="Phân trang">
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <c:url var="pageUrl" value="/home">
                                <c:param name="page" value="${p}"/>
                                <c:if test="${not empty filterQ}"><c:param name="q" value="${filterQ}"/></c:if>
                                <c:if test="${not empty filterCategory}"><c:param name="category" value="${filterCategory}"/></c:if>
                                <c:if test="${not empty filterLevel}"><c:param name="level" value="${filterLevel}"/></c:if>
                                <c:if test="${not empty filterType}"><c:param name="type" value="${filterType}"/></c:if>
                                <c:if test="${not empty filterSort}"><c:param name="sort" value="${filterSort}"/></c:if>
                            </c:url>
                            <a href="${pageUrl}#catalog"
                               class="w-10 h-10 grid place-items-center rounded-[6px] font-mono text-[13px] font-bold border-[1.5px] tabular-nums transition-colors ${p == currentPage ? 'bg-ink text-paper-soft border-ink' : 'bg-sheet text-ink border-rule hover:border-ink'}">
                                ${p}
                            </a>
                        </c:forEach>
                    </nav>
                </c:if>
            </c:otherwise>
        </c:choose>
    </section>
</main>

<jsp:include page="/inc/footer.jsp"/>
<jsp:include page="/inc/chat-widget.jsp"/>
</body>
</html>
