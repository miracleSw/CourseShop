<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/navbar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 max-w-[1360px] w-full mx-auto px-4 sm:px-6 lg:px-10 py-10 space-y-12">
    <!-- Owned Courses Section -->
    <section>
        <div class="flex flex-wrap items-end justify-between gap-4 pb-5 mb-7 border-b-[1.5px] border-ink">
            <div>
                <h1 class="text-[28px] sm:text-[34px] font-extrabold tracking-tight text-ink">Khóa học của tôi</h1>
                <p class="text-[14px] text-ink-muted mt-1">Theo dõi tiến độ học tập và mở lại bài học cùng ghi chú bất kỳ lúc nào.</p>
            </div>
            <a href="${pageContext.request.contextPath}/home#catalog" class="btn-outline-ink px-4 py-2 text-[13.5px]">
                Khám phá thêm khóa học
            </a>
        </div>

        <c:choose>
            <c:when test="${empty enrollments}">
                <div class="binder-sheet rounded-xl p-12 text-center max-w-lg mx-auto">
                    <div class="w-12 h-12 rounded-lg bg-paper border border-rule grid place-items-center mx-auto mb-4 text-ink-muted">
                        <i data-lucide="book-open" class="w-6 h-6"></i>
                    </div>
                    <h2 class="text-[19px] font-extrabold text-ink">Bạn chưa đăng ký khóa học nào</h2>
                    <p class="text-[14px] text-ink-muted mt-2 mb-6">Bắt đầu ngay với các khóa học nền tảng miễn phí chỉ với một lần bấm.</p>
                    <a href="${pageContext.request.contextPath}/home?type=free#catalog" class="btn-blueprint px-5 py-2.5 text-[14px]">
                        Xem khóa học Miễn phí
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                    <c:forEach var="en" items="${enrollments}">
                        <c:set var="c" value="${en.course}"/>
                        <article class="course-card flex flex-col">
                            <div class="h-2 ${c.pro ? 'bg-amber-bar' : 'bg-blueprint'}"></div>
                            <a href="${pageContext.request.contextPath}/learn?courseId=${c.id}"
                               class="block aspect-video bg-ink border-b border-rule overflow-hidden">
                                <img src="${c.externalThumbnail ? '' : pageContext.request.contextPath}${c.externalThumbnail ? '' : '/'}${c.thumbnail}"
                                     alt="<c:out value='${c.title}'/>" class="w-full h-full object-cover">
                            </a>
                            <div class="p-5 flex-1 flex flex-col">
                                <div class="font-mono text-[11px] font-bold ${c.pro ? 'text-amber-pro' : 'text-blueprint'} mb-1">
                                    ${c.code} · ${c.pro ? 'PRO' : 'MIỄN PHÍ'}
                                </div>
                                <h3 class="font-extrabold text-[16.5px] text-ink leading-snug mb-3">
                                    <a href="${pageContext.request.contextPath}/learn?courseId=${c.id}" class="hover:text-blueprint">
                                        <c:out value="${c.title}"/>
                                    </a>
                                </h3>

                                <!-- Progress Bar -->
                                <div class="mt-auto space-y-2">
                                    <div class="flex justify-between font-mono text-[12px] font-bold tabular-nums">
                                        <span class="text-ink-muted">${en.completedLessons}/${en.totalLessons} bài</span>
                                        <span class="${en.progressPercent == 100 ? 'text-emerald-ok' : 'text-blueprint'}">${en.progressPercent}%</span>
                                    </div>
                                    <div class="h-2 bg-paper rounded-full overflow-hidden border border-rule">
                                        <div class="h-full ${en.progressPercent == 100 ? 'bg-emerald-ok' : 'bg-blueprint'}"
                                             style="width: ${en.progressPercent}%"></div>
                                    </div>
                                    <div class="pt-3 flex items-center justify-between gap-2">
                                        <a href="${pageContext.request.contextPath}/learn?courseId=${c.id}"
                                           class="btn-blueprint flex-1 py-2 text-[13.5px]">
                                            <i data-lucide="play" class="w-3.5 h-3.5"></i>
                                            <span>${en.completedLessons > 0 ? 'Tiếp tục học' : 'Bắt đầu học'}</span>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/course?slug=${c.slug}#reviews"
                                           title="Đánh giá khóa học"
                                           class="btn-outline-ink px-3 py-2 text-[13px]">
                                            <i data-lucide="star" class="w-4 h-4"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </article>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <!-- Order History -->
    <section>
        <h2 class="text-[22px] font-extrabold text-ink mb-4">Lịch sử đơn hàng</h2>
        <c:choose>
            <c:when test="${empty orders}">
                <p class="text-[14px] text-ink-muted">Bạn chưa có giao dịch mua khóa học Pro nào.</p>
            </c:when>
            <c:otherwise>
                <div class="binder-sheet rounded-xl overflow-x-auto">
                    <table class="w-full text-left text-[13.5px] border-collapse">
                        <thead>
                            <tr class="bg-paper-soft border-b border-ink text-[12px] font-mono uppercase text-ink-muted">
                                <th class="px-5 py-3.5">Mã đơn</th>
                                <th class="px-5 py-3.5">Khóa học</th>
                                <th class="px-5 py-3.5">Phương thức</th>
                                <th class="px-5 py-3.5 text-right">Tổng tiền</th>
                                <th class="px-5 py-3.5">Trạng thái</th>
                                <th class="px-5 py-3.5 text-right">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-rule">
                            <c:forEach var="o" items="${orders}">
                                <tr class="hover:bg-paper-soft/60">
                                    <td class="px-5 py-3.5 font-mono font-bold text-ink">#${o.orderCode}</td>
                                    <td class="px-5 py-3.5">
                                        <c:forEach var="it" items="${o.items}" varStatus="st">
                                            <span class="font-semibold text-ink"><c:out value="${it.courseTitle}"/></span><c:if test="${!st.last}">, </c:if>
                                        </c:forEach>
                                    </td>
                                    <td class="px-5 py-3.5 text-[13px] text-ink-muted"><c:out value="${o.paymentMethodLabel}"/></td>
                                    <td class="px-5 py-3.5 text-right font-mono font-bold tabular-nums">${o.formattedTotal}</td>
                                    <td class="px-5 py-3.5">
                                        <span class="text-[11.5px] font-bold px-2.5 py-0.5 rounded
                                            ${o.status == 'PAID' ? 'bg-emerald-soft text-emerald-ok' : (o.status == 'PENDING' ? 'bg-amber-soft text-amber-ink' : 'bg-danger-soft text-danger')}">
                                            <c:out value="${o.statusLabel}"/>
                                        </span>
                                    </td>
                                    <td class="px-5 py-3.5 text-right">
                                        <a href="${pageContext.request.contextPath}/payment/result?orderCode=${o.orderCode}"
                                           class="font-bold text-blueprint hover:underline">Chi tiết</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</main>

<jsp:include page="/inc/footer.jsp"/>
<jsp:include page="/inc/chat-widget.jsp"/>
</body>
</html>
