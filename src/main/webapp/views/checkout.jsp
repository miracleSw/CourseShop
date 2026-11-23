<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/navbar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 max-w-[1160px] w-full mx-auto px-4 sm:px-6 lg:px-10 py-10">
    <h1 class="text-[28px] sm:text-[34px] font-extrabold tracking-tight text-ink mb-2">Thanh toán &amp; Kích hoạt khóa học</h1>
    <p class="text-[14.5px] text-ink-muted mb-8">Chọn phương thức thanh toán phù hợp để hoàn tất đăng ký khóa học.</p>

    <form action="${pageContext.request.contextPath}/checkout" method="post"
          x-data="{ method: '${stripeAvailable ? 'STRIPE' : 'BANK_TRANSFER'}', submitting: false }"
          @submit="submitting = true"
          class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">

        <!-- Payment Methods -->
        <div class="lg:col-span-7 space-y-4">
            <div class="binder-sheet rounded-xl p-6 space-y-4">
                <h2 class="text-[18px] font-extrabold text-ink">Phương thức thanh toán</h2>

                <!-- Option 1: Real Stripe Checkout -->
                <label class="block p-4 rounded-lg border-[1.5px] transition-colors ${stripeAvailable ? 'cursor-pointer' : 'opacity-65 cursor-not-allowed'}"
                       :class="method === 'STRIPE' ? 'border-blueprint bg-blueprint-soft/40' : 'border-rule bg-sheet'">
                    <div class="flex items-start gap-3">
                        <input type="radio" name="paymentMethod" value="STRIPE" x-model="method"
                               ${stripeAvailable ? '' : 'disabled'}
                               class="mt-1 accent-blueprint">
                        <div class="flex-1">
                            <div class="flex flex-wrap items-center justify-between gap-2">
                                <span class="font-extrabold text-[15px] text-ink">Thẻ thanh toán quốc tế (Stripe)</span>
                                <span class="font-mono text-[11px] font-bold px-2 py-0.5 rounded ${stripeAvailable ? 'bg-emerald-soft text-emerald-ok' : 'bg-paper border border-rule text-ink-muted'}">
                                    ${stripeAvailable ? 'Mở khóa tức thì' : 'Tạm bảo trì'}
                                </span>
                            </div>
                            <p class="text-[13px] text-ink-muted mt-1 leading-relaxed">
                                <c:choose>
                                    <c:when test="${stripeAvailable}">
                                        Thanh toán bảo mật bằng thẻ Visa, Mastercard qua cổng Stripe. Khóa học được kích hoạt ngay sau khi giao dịch thành công.
                                    </c:when>
                                    <c:otherwise>
                                        Cổng thanh toán thẻ trực tuyến hiện đang tạm bảo trì. Vui lòng chọn chuyển khoản ngân hàng bên dưới.
                                    </c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </div>
                </label>

                <!-- Option 2: Bank Transfer -->
                <label class="block p-4 rounded-lg border-[1.5px] cursor-pointer transition-colors"
                       :class="method === 'BANK_TRANSFER' ? 'border-blueprint bg-blueprint-soft/40' : 'border-rule bg-sheet hover:border-ink'">
                    <div class="flex items-start gap-3">
                        <input type="radio" name="paymentMethod" value="BANK_TRANSFER" x-model="method" class="mt-1 accent-blueprint">
                        <div class="flex-1">
                            <div class="flex flex-wrap items-center justify-between gap-2">
                                <span class="font-extrabold text-[15px] text-ink">Chuyển khoản ngân hàng</span>
                                <span class="font-mono text-[11px] font-bold px-2 py-0.5 rounded bg-amber-soft text-amber-ink">Xác nhận thủ công</span>
                            </div>
                            <p class="text-[13px] text-ink-muted mt-1 leading-relaxed">
                                Chuyển khoản theo thông tin ngân hàng và mã đơn hàng hiển thị ở bước tiếp theo. Khóa học được kích hoạt ngay sau khi xác nhận giao dịch.
                            </p>
                        </div>
                    </div>
                </label>
            </div>

            <!-- Buyer Info -->
            <div class="binder-sheet rounded-xl p-6 space-y-2.5 text-[14px]">
                <h2 class="text-[16px] font-extrabold text-ink mb-2">Thông tin tài khoản nhận khóa học</h2>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-[13.5px]">
                    <div class="p-3 rounded bg-paper-soft border border-rule">
                        <div class="text-ink-muted text-[12px]">Học viên</div>
                        <div class="font-bold text-ink mt-0.5"><c:out value="${sessionScope.user.fullName}"/></div>
                    </div>
                    <div class="p-3 rounded bg-paper-soft border border-rule">
                        <div class="text-ink-muted text-[12px]">Email nhận xác nhận</div>
                        <div class="font-mono font-bold text-ink mt-0.5"><c:out value="${sessionScope.user.email}"/></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Order Summary -->
        <aside class="lg:col-span-5 binder-sheet rounded-xl p-6 space-y-5">
            <h2 class="text-[18px] font-extrabold text-ink pb-3 border-b border-rule">Chi tiết đơn hàng</h2>

            <ul class="divide-y divide-rule text-[13.5px]">
                <c:forEach var="c" items="${cartItems}">
                    <li class="py-3 flex items-start justify-between gap-3">
                        <div class="min-w-0">
                            <div class="font-mono text-[11px] font-bold text-amber-pro">${c.code}</div>
                            <div class="font-bold text-ink leading-snug"><c:out value="${c.title}"/></div>
                        </div>
                        <span class="font-mono font-bold text-ink shrink-0 tabular-nums">${c.formattedEffectivePrice}</span>
                    </li>
                </c:forEach>
            </ul>

            <div class="space-y-2 pt-3 border-t border-rule text-[14px] tabular-nums">
                <div class="flex justify-between text-ink-muted">
                    <span>Tạm tính</span>
                    <span class="font-mono font-semibold text-ink">${formattedSubtotal}</span>
                </div>
                <c:if test="${not empty appliedCoupon}">
                    <div class="flex justify-between text-emerald-ok font-semibold">
                        <span>Mã ưu đãi (${appliedCoupon.code})</span>
                        <span class="font-mono">-${formattedDiscount}</span>
                    </div>
                </c:if>
                <div class="flex justify-between items-baseline pt-3 border-t border-ink">
                    <span class="font-extrabold text-[15px] text-ink">Tổng thanh toán</span>
                    <span class="font-mono text-[24px] font-extrabold text-amber-pro">${formattedTotal}</span>
                </div>
            </div>

            <button type="submit" :disabled="submitting"
                    class="btn-pro w-full py-3.5 text-[15px] disabled:opacity-60 disabled:cursor-not-allowed">
                <i data-lucide="lock" class="w-4 h-4"></i>
                <span x-text="submitting ? 'Đang xử lý đơn hàng...' : (method === 'BANK_TRANSFER' ? 'Xác nhận đặt đơn chuyển khoản' : 'Tiếp tục thanh toán qua Stripe')"></span>
            </button>

            <a href="${pageContext.request.contextPath}/cart"
               class="block text-center text-[13px] font-bold text-ink-muted hover:text-ink hover:underline">
                ← Quay lại chỉnh sửa giỏ hàng
            </a>
        </aside>
    </form>
</main>

<jsp:include page="/inc/footer.jsp"/>
</body>
</html>
