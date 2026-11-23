<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="bodyClass" value="bg-paper text-ink antialiased min-h-screen flex flex-col lg:flex-row" scope="request"/>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/admin-sidebar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 p-5 sm:p-8 lg:p-10 min-w-0 space-y-8">
    <div class="pb-4 border-b-[1.5px] border-ink">
        <h1 class="text-[26px] sm:text-[32px] font-extrabold tracking-tight text-ink">Quản lý Mã giảm giá</h1>
        <p class="text-[14px] text-ink-muted mt-1">Tạo mới, bật/tắt và theo dõi lượt sử dụng các mã ưu đãi khóa học.</p>
    </div>

    <!-- Create Coupon Form -->
    <section class="binder-sheet rounded-xl p-6">
        <h2 class="text-[16px] font-extrabold text-ink mb-4">Tạo mã giảm giá mới</h2>
        <form action="${pageContext.request.contextPath}/admin/coupons" method="post" class="grid grid-cols-1 md:grid-cols-12 gap-4 items-end">
            <div class="md:col-span-2">
                <label class="block text-[13px] font-bold mb-1">Mã Coupon</label>
                <input type="text" name="code" required placeholder="VD: SUMMER25" class="lab-input font-mono uppercase">
            </div>
            <div class="md:col-span-2">
                <label class="block text-[13px] font-bold mb-1">% Giảm</label>
                <input type="number" name="discountPercent" min="1" max="90" value="15" required class="lab-input font-mono tabular-nums">
            </div>
            <div class="md:col-span-2">
                <label class="block text-[13px] font-bold mb-1">Giảm tối đa (VNĐ)</label>
                <input type="number" name="maxDiscount" min="0" step="10000" value="250000" required class="lab-input font-mono tabular-nums">
            </div>
            <div class="md:col-span-2">
                <label class="block text-[13px] font-bold mb-1">Giới hạn lượt</label>
                <input type="number" name="usageLimit" min="1" value="100" required class="lab-input font-mono tabular-nums">
            </div>
            <div class="md:col-span-2">
                <label class="block text-[13px] font-bold mb-1">Ngày hết hạn</label>
                <input type="date" name="expiredAt" value="2027-12-31" class="lab-input font-mono">
            </div>
            <div class="md:col-span-2">
                <label class="block text-[13px] font-bold mb-1">Stripe Coupon ID</label>
                <input type="text" name="stripeCouponId" placeholder="Tùy chọn (VD: promo_...)" class="lab-input font-mono text-[13px]">
            </div>
            <div class="md:col-span-12 flex justify-end">
                <button type="submit" class="btn-blueprint px-5 py-2.5 text-[13.5px]">
                    <i data-lucide="plus" class="w-4 h-4"></i>
                    <span>Tạo mã giảm giá</span>
                </button>
            </div>
        </form>
    </section>

    <!-- Coupons Table -->
    <section class="binder-sheet rounded-xl overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-[13.5px] border-collapse">
                <thead>
                    <tr class="bg-paper-soft border-b border-ink font-mono text-[11.5px] uppercase text-ink-muted">
                        <th class="px-5 py-3.5">Mã</th>
                        <th class="px-5 py-3.5">Ưu đãi</th>
                        <th class="px-5 py-3.5">Stripe Coupon / Promo ID</th>
                        <th class="px-5 py-3.5">Đã dùng</th>
                        <th class="px-5 py-3.5">Hạn dùng</th>
                        <th class="px-5 py-3.5">Trạng thái</th>
                        <th class="px-5 py-3.5 text-right">Thao tác</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-rule">
                    <c:forEach var="cp" items="${coupons}">
                        <tr class="hover:bg-paper-soft/60">
                            <td class="px-5 py-3.5 font-mono font-extrabold text-amber-pro"><c:out value="${cp.code}"/></td>
                            <td class="px-5 py-3.5 font-mono tabular-nums">
                                <strong class="text-ink">-${cp.discountPercent}%</strong>
                                <span class="text-ink-muted text-[12px]">(tối đa <fmt:formatNumber value="${cp.maxDiscount}" type="number" groupingUsed="true"/>đ)</span>
                            </td>
                            <td class="px-5 py-3.5">
                                <form action="${pageContext.request.contextPath}/admin/coupons" method="post" class="flex items-center gap-1.5">
                                    <input type="hidden" name="action" value="updateStripeId">
                                    <input type="hidden" name="id" value="${cp.id}">
                                    <input type="text" name="stripeCouponId" value="<c:out value='${cp.stripeCouponId}'/>"
                                           placeholder="Auto khớp theo mã" class="lab-input font-mono text-[12px] py-1 px-2">
                                    <button type="submit" class="btn-outline-ink px-2.5 py-1 text-[12px] shrink-0">Lưu</button>
                                </form>
                            </td>
                            <td class="px-5 py-3.5 font-mono tabular-nums">${cp.usedCount} / ${cp.usageLimit}</td>
                            <td class="px-5 py-3.5 font-mono text-[12.5px] text-ink-muted tabular-nums">
                                <c:choose>
                                    <c:when test="${not empty cp.expiredAt}"><fmt:formatDate value="${cp.expiredAt}" pattern="dd/MM/yyyy"/></c:when>
                                    <c:otherwise>Không giới hạn</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="px-5 py-3.5">
                                <span class="font-mono text-[11px] font-bold px-2 py-0.5 rounded ${cp.status ? 'bg-emerald-soft text-emerald-ok' : 'bg-danger-soft text-danger'}">
                                    ${cp.status ? 'HOẠT ĐỘNG' : 'TẠM TẮT'}
                                </span>
                            </td>
                            <td class="px-5 py-3.5 text-right space-x-2 whitespace-nowrap">
                                <form action="${pageContext.request.contextPath}/admin/coupons" method="post" class="inline">
                                    <input type="hidden" name="action" value="toggle">
                                    <input type="hidden" name="id" value="${cp.id}">
                                    <button type="submit" class="btn-outline-ink px-2.5 py-1 text-[12px]">
                                        ${cp.status ? 'Tắt' : 'Bật'}
                                    </button>
                                </form>
                                <form action="${pageContext.request.contextPath}/admin/coupons" method="post" class="inline"
                                      onsubmit="return confirm('Bạn chắc chắn muốn xóa mã giảm giá này?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${cp.id}">
                                    <button type="submit" class="text-[12px] font-bold text-danger hover:underline">Xóa</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </section>
</main>

</body>
</html>
