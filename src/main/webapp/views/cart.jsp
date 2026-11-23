<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/navbar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 max-w-[1360px] w-full mx-auto px-4 sm:px-6 lg:px-10 py-10">
    <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-3 sm:gap-4 pb-5 mb-8 border-b-[1.5px] border-ink">
        <div>
            <h1 class="text-[28px] sm:text-[34px] font-extrabold tracking-tight text-ink">Giỏ hàng khóa học</h1>
            <p class="text-[14px] text-ink-muted mt-1">Mỗi khóa học Pro được kích hoạt sở hữu trọn đời sau khi thanh toán.</p>
        </div>
        <a href="${pageContext.request.contextPath}/home#catalog" class="text-[13.5px] font-bold text-blueprint hover:underline inline-flex items-center gap-1 shrink-0 self-start sm:self-auto">
            <i data-lucide="arrow-left" class="w-4 h-4"></i>
            <span>Tiếp tục xem khóa học</span>
        </a>
    </div>

    <c:choose>
        <c:when test="${empty cartItems}">
            <div class="binder-sheet rounded-xl p-12 text-center max-w-lg mx-auto my-8">
                <div class="w-12 h-12 rounded-lg bg-paper border border-rule grid place-items-center mx-auto mb-4 text-ink-muted">
                    <i data-lucide="shopping-bag" class="w-6 h-6"></i>
                </div>
                <h2 class="text-[20px] font-extrabold text-ink">Giỏ hàng đang trống</h2>
                <p class="text-[14px] text-ink-muted mt-2 mb-6">
                    Hãy chọn thêm khóa học Pro hoặc đăng ký ngay 4 khóa nền tảng miễn phí để trải nghiệm trước.
                </p>
                <div class="flex flex-wrap justify-center gap-3">
                    <a href="${pageContext.request.contextPath}/home?type=pro#catalog" class="btn-pro px-5 py-2.5 text-[14px]">Khám phá khóa Pro</a>
                    <a href="${pageContext.request.contextPath}/home?type=free#catalog" class="btn-outline-ink px-5 py-2.5 text-[14px]">Xem khóa Miễn phí</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
                <!-- Items List -->
                <div class="lg:col-span-8 binder-sheet rounded-xl overflow-hidden">
                    <div class="px-5 py-3.5 bg-paper-soft border-b border-rule flex items-center justify-between text-[13px] font-bold text-ink-muted">
                        <span>${cartItems.size()} khóa học đã chọn</span>
                        <form action="${pageContext.request.contextPath}/cart" method="post">
                            <input type="hidden" name="action" value="clear">
                            <button type="submit" class="text-danger hover:underline text-[12.5px]">Xóa tất cả</button>
                        </form>
                    </div>
                    <ul class="divide-y divide-rule">
                        <c:forEach var="c" items="${cartItems}">
                            <li class="p-5 flex flex-col sm:flex-row sm:items-center gap-4">
                                <a href="${pageContext.request.contextPath}/course?slug=${c.slug}"
                                   class="w-full sm:w-40 aspect-video rounded-md overflow-hidden border border-ink shrink-0 block bg-ink">
                                    <img src="${c.externalThumbnail ? '' : pageContext.request.contextPath}${c.externalThumbnail ? '' : '/'}${c.thumbnail}"
                                         alt="<c:out value='${c.title}'/>" class="w-full h-full object-cover">
                                </a>
                                <div class="flex-1 min-w-0">
                                    <div class="font-mono text-[11px] font-bold text-amber-pro mb-1">${c.code} · ${c.levelLabel}</div>
                                    <h3 class="font-extrabold text-[16px] text-ink leading-snug">
                                        <a href="${pageContext.request.contextPath}/course?slug=${c.slug}" class="hover:text-blueprint hover:underline">
                                            <c:out value="${c.title}"/>
                                        </a>
                                    </h3>
                                    <div class="text-[12.5px] text-ink-muted mt-1 font-mono">
                                        GV. <c:out value="${c.instructorName}"/> · ${c.lessonCount} bài · ${c.formattedDuration}
                                    </div>
                                </div>
                                <div class="flex sm:flex-col items-center sm:items-end justify-between gap-2 shrink-0">
                                    <div class="text-right tabular-nums">
                                        <div class="text-[17px] font-extrabold text-ink">${c.formattedEffectivePrice}</div>
                                        <c:if test="${c.hasDiscount}">
                                            <div class="text-[12px] text-ink-subtle line-through">${c.formattedPrice}</div>
                                        </c:if>
                                    </div>
                                    <form action="${pageContext.request.contextPath}/cart" method="post">
                                        <input type="hidden" name="action" value="remove">
                                        <input type="hidden" name="courseId" value="${c.id}">
                                        <button type="submit" class="inline-flex items-center gap-1 text-[12.5px] font-bold text-danger hover:underline">
                                            <i data-lucide="trash-2" class="w-3.5 h-3.5"></i>
                                            <span>Bỏ chọn</span>
                                        </button>
                                    </form>
                                </div>
                            </li>
                        </c:forEach>
                    </ul>
                </div>

                <!-- Summary & Coupon Box -->
                <aside class="lg:col-span-4 lg:sticky lg:top-24">
                    <div class="binder-sheet rounded-xl p-6 space-y-5">
                    <h2 class="text-[18px] font-extrabold text-ink pb-3 border-b border-rule">Tóm tắt đơn hàng</h2>

                    <!-- Coupon Form -->
                    <div>
                        <c:choose>
                            <c:when test="${not empty appliedCoupon}">
                                <div class="flex items-center justify-between gap-2 p-3 rounded-lg bg-emerald-soft border border-emerald-ok/30">
                                    <div class="text-[13px] min-w-0">
                                        <span class="font-mono font-bold text-emerald-ok">${appliedCoupon.code}</span>
                                        <span class="text-ink font-semibold ml-1">(-${appliedCoupon.discountPercent}%<c:if test="${appliedCoupon.hasMaxDiscount}">, tối đa ${appliedCoupon.formattedMaxDiscount}</c:if>)</span>
                                    </div>
                                    <form action="${pageContext.request.contextPath}/cart" method="post" class="shrink-0">
                                        <input type="hidden" name="action" value="removeCoupon">
                                        <button type="submit" class="text-[12px] font-bold text-danger hover:underline">Gỡ mã</button>
                                    </form>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <form action="${pageContext.request.contextPath}/cart" method="post" class="flex gap-2">
                                    <input type="hidden" name="action" value="applyCoupon">
                                    <input type="text" name="couponCode" placeholder="Nhập mã giảm giá..."
                                           class="lab-input h-10 text-[13.5px] font-mono uppercase">
                                    <button type="submit" class="btn-outline-ink px-3.5 h-10 text-[13px] shrink-0">Áp dụng</button>
                                </form>
                                <c:if test="${not empty activeCoupons}">
                                    <div class="mt-2.5 flex flex-wrap gap-1.5">
                                        <c:forEach var="cp" items="${activeCoupons}">
                                            <form action="${pageContext.request.contextPath}/cart" method="post">
                                                <input type="hidden" name="action" value="applyCoupon">
                                                <input type="hidden" name="couponCode" value="${cp.code}">
                                                <button type="submit"
                                                        title="Giảm ${cp.discountPercent}%${cp.hasMaxDiscount ? ', tối đa '.concat(cp.formattedMaxDiscount) : ''}"
                                                        class="font-mono text-[11px] font-bold px-2 py-0.5 rounded bg-paper border border-rule hover:border-ink text-ink-muted hover:text-ink transition-colors">
                                                    ${cp.code} (-${cp.discountPercent}%)
                                                </button>
                                            </form>
                                        </c:forEach>
                                    </div>
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Totals -->
                    <dl class="space-y-2.5 pt-2 border-t border-rule text-[14px] tabular-nums">
                        <div class="flex justify-between text-ink-muted">
                            <dt>Tạm tính</dt>
                            <dd class="font-mono font-semibold text-ink">${formattedSubtotal}</dd>
                        </div>
                        <div class="flex justify-between text-ink-muted">
                            <dt>Giảm giá mã ưu đãi</dt>
                            <dd class="font-mono font-semibold text-emerald-ok">-${formattedDiscount}</dd>
                        </div>
                        <div class="flex justify-between items-baseline pt-3 border-t border-rule text-[16px]">
                            <dt class="font-extrabold text-ink">Tổng thanh toán</dt>
                            <dd class="font-mono text-[22px] font-extrabold text-ink">${formattedTotal}</dd>
                        </div>
                    </dl>

                    <a href="${pageContext.request.contextPath}/checkout"
                       class="btn-pro w-full py-3 text-[15px]">
                        <i data-lucide="shield-check" class="w-4 h-4"></i>
                        <span>Tiến hành thanh toán</span>
                    </a>
                    </div>
                </aside>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<jsp:include page="/inc/footer.jsp"/>
<jsp:include page="/inc/chat-widget.jsp"/>
</body>
</html>
