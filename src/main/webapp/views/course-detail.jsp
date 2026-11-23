<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/navbar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 max-w-[1360px] w-full mx-auto px-4 sm:px-6 lg:px-10 py-8"
      x-data="{
          previewOpen: false,
          previewTitle: '',
          previewYoutubeId: '',
          expandAll: true,
          openPreview(title, ytId) {
              this.previewTitle = title;
              this.previewYoutubeId = ytId;
              this.previewOpen = true;
          },
          closePreview() {
              this.previewOpen = false;
              this.previewYoutubeId = '';
          }
      }"
      @keydown.escape.window="closePreview()">

    <!-- Breadcrumb -->
    <nav class="flex items-center gap-2 text-[13px] font-semibold text-ink-muted mb-6" aria-label="Breadcrumb">
        <a href="${pageContext.request.contextPath}/home" class="hover:text-ink hover:underline">Giáo trình</a>
        <i data-lucide="chevron-right" class="w-3.5 h-3.5"></i>
        <a href="${pageContext.request.contextPath}/home?category=${course.categoryId}#catalog" class="hover:text-ink hover:underline">
            <c:out value="${course.categoryName}"/>
        </a>
        <i data-lucide="chevron-right" class="w-3.5 h-3.5"></i>
        <span class="font-mono text-ink">${course.code}</span>
    </nav>

    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        <!-- Left Main Content (8 cols) -->
        <div class="lg:col-span-8 space-y-8">
            <!-- Overview Sheet -->
            <section class="binder-sheet rounded-xl p-6 sm:p-8">
                <div class="flex flex-wrap items-center gap-2 mb-3 font-mono text-[12px] font-bold">
                    <span class="px-2.5 py-0.5 rounded ${course.pro ? 'bg-amber-soft text-amber-ink' : 'bg-blueprint-soft text-blueprint'}">
                        ${course.code} · ${course.pro ? 'KHÓA PRO' : 'MIỄN PHÍ 0Đ'}
                    </span>
                    <span class="px-2.5 py-0.5 rounded bg-paper border border-rule text-ink-muted">${course.levelLabel}</span>
                </div>

                <h1 class="text-[28px] sm:text-[36px] font-extrabold tracking-tight text-ink leading-tight">
                    <c:out value="${course.title}"/>
                </h1>
                <p class="text-[15.5px] text-ink-muted leading-relaxed mt-3">
                    <c:out value="${course.description}"/>
                </p>

                <div class="mt-6 pt-5 border-t border-rule flex flex-wrap gap-x-6 gap-y-2.5 text-[13.5px] font-semibold text-ink">
                    <span class="inline-flex items-center gap-1.5">
                        <i data-lucide="user-check" class="w-4 h-4 text-blueprint"></i>
                        Giảng viên: <c:out value="${course.instructorName}"/>
                    </span>
                    <span class="inline-flex items-center gap-1.5 font-mono tabular-nums">
                        <i data-lucide="book-open" class="w-4 h-4 text-blueprint"></i>
                        ${course.lessonCount} bài học (${course.formattedDuration})
                    </span>
                    <span class="inline-flex items-center gap-1.5 font-mono tabular-nums">
                        <i data-lucide="users" class="w-4 h-4 text-blueprint"></i>
                        ${course.studentCount} học viên
                    </span>
                    <c:if test="${course.reviewCount > 0}">
                        <span class="inline-flex items-center gap-1.5 font-mono tabular-nums">
                            <i data-lucide="star" class="w-4 h-4 text-amber-bar fill-amber-bar"></i>
                            ${course.avgRating} (${course.reviewCount} đánh giá)
                        </span>
                    </c:if>
                </div>
            </section>

            <!-- What You Will Learn -->
            <c:if test="${not empty course.outcomes}">
                <section class="binder-sheet rounded-xl p-6 sm:p-8">
                    <h2 class="text-[20px] font-extrabold text-ink mb-4">Bạn sẽ học được gì?</h2>
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                        <c:forEach var="out" items="${course.outcomes}">
                            <div class="flex items-start gap-2.5 text-[14px] text-ink leading-snug">
                                <i data-lucide="check-circle-2" class="w-4 h-4 text-emerald-ok shrink-0 mt-0.5"></i>
                                <span><c:out value="${out}"/></span>
                            </div>
                        </c:forEach>
                    </div>
                </section>
            </c:if>

            <!-- Course Syllabus Accordion -->
            <section class="binder-sheet rounded-xl p-6 sm:p-8">
                <div class="flex flex-wrap items-center justify-between gap-3 mb-5">
                    <div>
                        <h2 class="text-[20px] font-extrabold text-ink">Nội dung giáo trình</h2>
                        <p class="text-[13px] text-ink-muted font-mono tabular-nums mt-0.5">
                            ${sections.size()} chương · ${course.lessonCount} bài giảng · Tổng thời lượng ${course.formattedDuration}
                        </p>
                    </div>
                    <button type="button" @click="expandAll = !expandAll"
                            class="text-[13px] font-bold text-blueprint hover:underline">
                        <span x-text="expandAll ? 'Thu gọn tất cả' : 'Mở rộng tất cả'"></span>
                    </button>
                </div>

                <div class="space-y-3">
                    <c:forEach var="sec" items="${sections}">
                        <div x-data="{ open: true }"
                             x-effect="open = expandAll"
                             class="border-[1.5px] border-rule rounded-lg overflow-hidden">
                            <button type="button" @click="open = !open"
                                    class="w-full px-4 py-3.5 bg-paper-soft hover:bg-paper-tab flex items-center justify-between gap-3 text-left transition-colors">
                                <span class="font-bold text-[14.5px] text-ink"><c:out value="${sec.title}"/></span>
                                <span class="shrink-0 flex items-center gap-2 font-mono text-[12px] text-ink-muted tabular-nums">
                                    <span>${sec.lessons.size()} bài</span>
                                    <i data-lucide="chevron-down" class="w-4 h-4 transition-transform" :class="open ? 'rotate-180' : ''"></i>
                                </span>
                            </button>

                            <ul x-show="open" x-cloak class="divide-y divide-rule bg-sheet">
                                <c:forEach var="lesson" items="${sec.lessons}">
                                    <li class="px-4 py-3 flex items-center justify-between gap-3 text-[13.5px]">
                                        <div class="flex items-center gap-2.5 min-w-0">
                                            <c:choose>
                                                <c:when test="${enrolled || lesson.preview}">
                                                    <i data-lucide="play-circle" class="w-4 h-4 text-blueprint shrink-0"></i>
                                                </c:when>
                                                <c:otherwise>
                                                    <i data-lucide="lock" class="w-4 h-4 text-ink-subtle shrink-0"></i>
                                                </c:otherwise>
                                            </c:choose>
                                            <span class="font-medium text-ink truncate"><c:out value="${lesson.title}"/></span>
                                        </div>
                                        <div class="shrink-0 flex items-center gap-3">
                                            <c:if test="${lesson.preview && not empty lesson.youtubeId}">
                                                <button type="button"
                                                        @click="openPreview('<c:out value="${lesson.title}"/>', '${lesson.youtubeId}')"
                                                        class="text-[12px] font-bold text-blueprint hover:underline">
                                                    Học thử
                                                </button>
                                            </c:if>
                                            <c:if test="${enrolled}">
                                                <a href="${pageContext.request.contextPath}/learn?courseId=${course.id}&lessonId=${lesson.id}"
                                                   class="text-[12px] font-bold text-emerald-ok hover:underline">
                                                    Mở bài
                                                </a>
                                            </c:if>
                                            <span class="font-mono text-[12px] text-ink-muted tabular-nums">${lesson.formattedDuration}</span>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </div>
                    </c:forEach>
                </div>
            </section>

            <!-- Reviews & Rating Distribution -->
            <section id="reviews" class="binder-sheet rounded-xl p-6 sm:p-8">
                <h2 class="text-[20px] font-extrabold text-ink mb-5">Đánh giá từ học viên</h2>

                <div class="grid grid-cols-1 sm:grid-cols-12 gap-6 pb-6 mb-6 border-b border-rule items-center">
                    <div class="sm:col-span-4 text-center sm:text-left">
                        <div class="font-mono text-[42px] font-extrabold text-ink leading-none tabular-nums">
                            ${course.reviewCount > 0 ? course.avgRating : '—'}
                        </div>
                        <div class="text-[13px] text-ink-muted mt-1.5 font-semibold">
                            ${course.reviewCount} lượt đánh giá xác thực
                        </div>
                    </div>
                    <div class="sm:col-span-8 space-y-1.5">
                        <c:forEach var="entry" items="${ratingDist}">
                            <c:set var="pct" value="${course.reviewCount > 0 ? (entry.value * 100 / course.reviewCount) : 0}"/>
                            <div class="flex items-center gap-3 text-[12.5px] font-mono tabular-nums">
                                <span class="w-10 font-bold text-ink">${entry.key} sao</span>
                                <div class="flex-1 h-2 bg-paper rounded-full overflow-hidden border border-rule">
                                    <div class="h-full bg-amber-bar" style="width: ${pct}%"></div>
                                </div>
                                <span class="w-8 text-right text-ink-muted">${entry.value}</span>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Review Form (Enrolled Users Only) -->
                <c:if test="${enrolled}">
                    <form action="${pageContext.request.contextPath}/review" method="post"
                          class="p-4 bg-paper-soft border border-rule rounded-lg mb-6 space-y-3">
                        <input type="hidden" name="courseId" value="${course.id}">
                        <div class="flex flex-wrap items-center justify-between gap-2">
                            <label for="ratingSelect" class="font-bold text-[14px] text-ink">Viết đánh giá của bạn</label>
                            <select id="ratingSelect" name="rating"
                                    class="h-9 px-3 rounded border-[1.5px] border-ink bg-sheet text-[13px] font-bold">
                                <option value="5">5 sao — Rất hài lòng</option>
                                <option value="4">4 sao — Tốt</option>
                                <option value="3">3 sao — Khá ổn</option>
                                <option value="2">2 sao — Cần cải thiện</option>
                                <option value="1">1 sao — Chưa phù hợp</option>
                            </select>
                        </div>
                        <textarea name="comment" rows="3" required minlength="5"
                                  placeholder="Chia sẻ cảm nhận thực tế về chất lượng bài giảng và bài tập thực hành..."
                                  class="lab-input text-[14px]"></textarea>
                        <button type="submit" class="btn-blueprint px-4 py-2 text-[13.5px]">Gửi đánh giá</button>
                    </form>
                </c:if>

                <c:choose>
                    <c:when test="${empty reviews}">
                        <p class="text-[14px] text-ink-muted">Chưa có đánh giá nào cho khóa học này.</p>
                    </c:when>
                    <c:otherwise>
                        <div class="divide-y divide-rule">
                            <c:forEach var="rv" items="${reviews}">
                                <article class="py-4 first:pt-0 last:pb-0">
                                    <div class="flex items-center justify-between gap-2 mb-1.5">
                                        <span class="font-bold text-[14px] text-ink"><c:out value="${rv.userName}"/></span>
                                        <span class="font-mono text-[12px] font-bold text-amber-pro tabular-nums">${rv.rating} / 5 sao</span>
                                    </div>
                                    <p class="text-[14px] text-ink-muted leading-relaxed"><c:out value="${rv.comment}"/></p>
                                </article>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
        </div>

        <!-- Right Sticky Purchase Binder Card (4 cols) -->
        <aside class="lg:col-span-4 lg:sticky lg:top-24">
            <div class="binder-sheet rounded-xl overflow-hidden">
                <div class="h-2 ${course.pro ? 'bg-amber-bar' : 'bg-blueprint'}"></div>

                <!-- Previewable Cover -->
                <div class="relative aspect-video bg-ink border-b border-rule">
                    <img src="${course.externalThumbnail ? '' : pageContext.request.contextPath}${course.externalThumbnail ? '' : '/'}${course.thumbnail}"
                         alt="<c:out value='${course.title}'/>"
                         class="w-full h-full object-cover">
                    <c:if test="${not empty firstPreview && not empty firstPreview.youtubeId}">
                        <button type="button"
                                @click="openPreview('<c:out value="${firstPreview.title}"/>', '${firstPreview.youtubeId}')"
                                class="absolute inset-0 bg-ink/40 hover:bg-ink/55 transition-colors flex flex-col items-center justify-center gap-2 text-white">
                            <span class="w-14 h-14 rounded-full bg-sheet text-ink border-[1.5px] border-ink grid place-items-center shadow-lg">
                                <i data-lucide="play" class="w-6 h-6 ml-0.5"></i>
                            </span>
                            <span class="text-[13px] font-bold px-3 py-1 rounded-full bg-ink/80">Xem bài học thử</span>
                        </button>
                    </c:if>
                </div>

                <div class="p-6 space-y-5">
                    <!-- Price Block -->
                    <div class="flex flex-wrap items-baseline gap-x-2.5 gap-y-1.5 tabular-nums">
                        <span class="text-[26px] sm:text-[30px] font-extrabold leading-none ${course.free ? 'text-blueprint' : 'text-ink'}">
                            ${course.formattedEffectivePrice}
                        </span>
                        <c:if test="${course.hasDiscount}">
                            <span class="text-[14px] sm:text-[15px] text-ink-subtle line-through">${course.formattedPrice}</span>
                            <span class="font-mono text-[12px] font-bold px-2 py-0.5 rounded bg-amber-soft text-amber-ink shrink-0">
                                -${course.discountPercent}%
                            </span>
                        </c:if>
                    </div>

                    <!-- Action Buttons -->
                    <div class="space-y-2.5">
                        <c:choose>
                            <c:when test="${enrolled}">
                                <a href="${pageContext.request.contextPath}/learn?courseId=${course.id}"
                                   class="btn-blueprint w-full py-3 text-[15px]">
                                    <i data-lucide="play-circle" class="w-4 h-4"></i>
                                    <span>Vào học ngay</span>
                                </a>
                            </c:when>
                            <c:when test="${course.free}">
                                <form action="${pageContext.request.contextPath}/enroll-free" method="post">
                                    <input type="hidden" name="courseId" value="${course.id}">
                                    <button type="submit" class="btn-blueprint w-full py-3 text-[15px]">
                                        <i data-lucide="check-circle" class="w-4 h-4"></i>
                                        <span>Đăng ký học miễn phí</span>
                                    </button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <form action="${pageContext.request.contextPath}/cart" method="post">
                                    <input type="hidden" name="action" value="add">
                                    <input type="hidden" name="courseId" value="${course.id}">
                                    <input type="hidden" name="buyNow" value="1">
                                    <button type="submit" class="btn-pro w-full py-3 text-[15px]">
                                        <i data-lucide="credit-card" class="w-4 h-4"></i>
                                        <span>Mua ngay</span>
                                    </button>
                                </form>

                                <c:choose>
                                    <c:when test="${inCart}">
                                        <a href="${pageContext.request.contextPath}/cart"
                                           class="btn-outline-ink w-full py-2.5 text-[14px]">
                                            <i data-lucide="shopping-bag" class="w-4 h-4"></i>
                                            <span>Xem trong giỏ hàng</span>
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <button type="button" onclick="addToCartAsync(${course.id}, this)"
                                                class="btn-outline-ink w-full py-2.5 text-[14px]">
                                            <i data-lucide="plus" class="w-4 h-4"></i>
                                            <span>Thêm vào giỏ hàng</span>
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Course Includes -->
                    <ul class="pt-4 border-t border-rule space-y-2.5 text-[13.5px] text-ink-muted">
                        <li class="flex items-center gap-2.5">
                            <i data-lucide="infinity" class="w-4 h-4 text-ink shrink-0"></i>
                            <span>Truy cập trọn đời, học mọi lúc mọi nơi</span>
                        </li>
                        <li class="flex items-center gap-2.5">
                            <i data-lucide="notebook-pen" class="w-4 h-4 text-ink shrink-0"></i>
                            <span>Ghi chú trực tiếp theo mốc thời gian video</span>
                        </li>
                        <li class="flex items-center gap-2.5">
                            <i data-lucide="sparkles" class="w-4 h-4 text-ink shrink-0"></i>
                            <span>Trợ giảng AI giải đáp bài học 24/7</span>
                        </li>
                        <c:if test="${course.pro && not empty activeCoupons}">
                            <li class="flex items-start gap-2.5">
                                <i data-lucide="tag" class="w-4 h-4 text-amber-pro shrink-0 mt-0.5"></i>
                                <span>
                                    Mã ưu đãi đang mở:
                                    <c:forEach var="cp" items="${activeCoupons}" varStatus="cst">
                                        <strong class="font-mono text-ink"><c:out value="${cp.code}"/></strong><c:if test="${!cst.last}">, </c:if>
                                    </c:forEach>
                                </span>
                            </li>
                        </c:if>
                    </ul>
                </div>
            </div>
        </aside>
    </div>

    <!-- Video Preview Modal -->
    <div x-show="previewOpen" x-cloak
         class="fixed inset-0 z-50 bg-ink/75 flex items-center justify-center p-4"
         @click.self="closePreview()">
        <div class="w-full max-w-3xl bg-sheet border-[1.5px] border-ink rounded-xl overflow-hidden shadow-2xl">
            <div class="px-5 py-3.5 bg-paper-soft border-b-[1.5px] border-ink flex items-center justify-between gap-3">
                <div class="font-bold text-[15px] text-ink truncate" x-text="'Học thử: ' + previewTitle"></div>
                <button type="button" @click="closePreview()"
                        class="p-1 rounded hover:bg-paper-tab text-ink" aria-label="Đóng cửa sổ học thử">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>
            <div class="aspect-video bg-theatre">
                <template x-if="previewOpen && previewYoutubeId">
                    <iframe class="w-full h-full"
                            :src="'https://www.youtube.com/embed/' + previewYoutubeId + '?autoplay=1&rel=0'"
                            title="Video học thử"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                            allowfullscreen></iframe>
                </template>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/inc/footer.jsp"/>
<jsp:include page="/inc/chat-widget.jsp"/>
</body>
</html>
