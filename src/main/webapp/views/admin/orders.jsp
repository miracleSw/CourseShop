<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="bodyClass" value="bg-paper text-ink antialiased min-h-screen flex flex-col lg:flex-row" scope="request"/>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/admin-sidebar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 p-5 sm:p-8 lg:p-10 min-w-0 space-y-6">
    <div class="flex flex-wrap items-end justify-between gap-4 pb-4 border-b-[1.5px] border-ink">
        <div>
            <h1 class="text-[26px] sm:text-[32px] font-extrabold tracking-tight text-ink">Quản lý Đơn hàng</h1>
            <p class="text-[14px] text-ink-muted mt-1">Theo dõi trạng thái thanh toán và xác nhận các đơn chuyển khoản chờ duyệt.</p>
        </div>
        <div class="flex flex-wrap gap-1.5 text-[12px] font-bold">
            <a href="${pageContext.request.contextPath}/admin/orders"
               class="px-3 py-1.5 rounded border-[1.5px] ${empty statusFilter ? 'bg-ink text-paper-soft border-ink' : 'bg-sheet border-rule text-ink'}">Tất cả</a>
            <a href="${pageContext.request.contextPath}/admin/orders?status=PENDING"
               class="px-3 py-1.5 rounded border-[1.5px] ${statusFilter == 'PENDING' ? 'bg-amber-pro text-white border-amber-pro' : 'bg-sheet border-rule text-ink'}">Chờ xác nhận</a>
            <a href="${pageContext.request.contextPath}/admin/orders?status=PAID"
               class="px-3 py-1.5 rounded border-[1.5px] ${statusFilter == 'PAID' ? 'bg-emerald-ok text-white border-emerald-ok' : 'bg-sheet border-rule text-ink'}">Đã thanh toán</a>
            <a href="${pageContext.request.contextPath}/admin/orders?status=FAILED"
               class="px-3 py-1.5 rounded border-[1.5px] ${statusFilter == 'FAILED' ? 'bg-danger text-white border-danger' : 'bg-sheet border-rule text-ink'}">Thất bại</a>
            <a href="${pageContext.request.contextPath}/admin/orders?status=CANCELLED"
               class="px-3 py-1.5 rounded border-[1.5px] ${statusFilter == 'CANCELLED' ? 'bg-ink text-paper-soft border-ink' : 'bg-sheet border-rule text-ink'}">Đã hủy</a>
        </div>
    </div>

    <section class="binder-sheet rounded-xl overflow-hidden">
        <c:choose>
            <c:when test="${empty orders}">
                <div class="p-12 text-center text-[14px] text-ink-muted">
                    Chưa có đơn hàng nào ở trạng thái này.
                </div>
            </c:when>
            <c:otherwise>
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-[13.5px] border-collapse">
                        <thead>
                            <tr class="bg-paper-soft border-b border-ink font-mono text-[11.5px] uppercase text-ink-muted">
                                <th class="px-4 py-3.5">Mã đơn</th>
                                <th class="px-4 py-3.5">Học viên</th>
                                <th class="px-4 py-3.5">Khóa học</th>
                                <th class="px-4 py-3.5">Phương thức</th>
                                <th class="px-4 py-3.5 text-right">Tổng tiền</th>
                                <th class="px-4 py-3.5">Trạng thái</th>
                                <th class="px-4 py-3.5 text-right">Xử lý</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-rule">
                            <c:forEach var="o" items="${orders}">
                                <tr class="hover:bg-paper-soft/60">
                                    <td class="px-4 py-3.5 font-mono font-bold text-ink">#${o.orderCode}</td>
                                    <td class="px-4 py-3.5">
                                        <div class="font-bold text-ink"><c:out value="${o.userName}"/></div>
                                        <div class="font-mono text-[11.5px] text-ink-muted"><c:out value="${o.userEmail}"/></div>
                                    </td>
                                    <td class="px-4 py-3.5 max-w-xs">
                                        <c:forEach var="it" items="${o.items}" varStatus="st">
                                            <span class="font-semibold"><c:out value="${it.courseCode}"/></span><c:if test="${!st.last}">, </c:if>
                                        </c:forEach>
                                    </td>
                                    <td class="px-4 py-3.5 text-[13px] text-ink-muted"><c:out value="${o.paymentMethodLabel}"/></td>
                                    <td class="px-4 py-3.5 text-right font-mono font-bold tabular-nums">${o.formattedTotal}</td>
                                    <td class="px-4 py-3.5">
                                        <span class="text-[11.5px] font-bold px-2 py-0.5 rounded
                                            ${o.status == 'PAID' ? 'bg-emerald-soft text-emerald-ok' : (o.status == 'PENDING' ? 'bg-amber-soft text-amber-ink' : 'bg-danger-soft text-danger')}">
                                            <c:out value="${o.statusLabel}"/>
                                        </span>
                                    </td>
                                    <td class="px-4 py-3.5 text-right whitespace-nowrap">
                                        <c:if test="${o.status == 'PENDING'}">
                                            <form action="${pageContext.request.contextPath}/admin/orders" method="post" class="inline">
                                                <input type="hidden" name="orderId" value="${o.id}">
                                                <input type="hidden" name="action" value="approve">
                                                <button type="submit" class="px-3 py-1 rounded bg-emerald-ok text-white font-bold text-[12px] hover:bg-[#166534]">
                                                    Duyệt &amp; Mở khóa
                                                </button>
                                            </form>
                                            <form action="${pageContext.request.contextPath}/admin/orders" method="post" class="inline ml-1.5">
                                                <input type="hidden" name="orderId" value="${o.id}">
                                                <input type="hidden" name="action" value="cancel">
                                                <button type="submit" class="px-2.5 py-1 rounded border border-danger/40 text-danger font-bold text-[12px] hover:bg-danger-soft">
                                                    Hủy
                                                </button>
                                            </form>
                                        </c:if>
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
</body>
</html>
