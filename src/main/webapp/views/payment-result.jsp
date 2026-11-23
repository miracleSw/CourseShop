<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/navbar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 max-w-3xl w-full mx-auto px-4 sm:px-6 py-12">
    <div class="binder-sheet rounded-xl overflow-hidden">
        <div class="h-2 ${order.status == 'PAID' ? 'bg-emerald-ok' : (order.status == 'PENDING' ? 'bg-amber-bar' : 'bg-danger')}"></div>

        <div class="p-7 sm:p-10">
            <c:choose>
                <c:when test="${order.status == 'PAID'}">
                    <div class="w-12 h-12 rounded-lg bg-emerald-soft text-emerald-ok grid place-items-center mb-4">
                        <i data-lucide="check-circle-2" class="w-7 h-7"></i>
                    </div>
                    <h1 class="text-[28px] font-extrabold text-ink">Thanh toán thành công</h1>
                    <p class="text-[15px] text-ink-muted mt-1.5">
                        Đơn hàng <strong class="font-mono text-ink">#${order.orderCode}</strong> đã được xác nhận. Các khóa học bên dưới đã sẵn sàng trong tài khoản của bạn.
                    </p>
                </c:when>

                <c:when test="${order.status == 'PENDING' && order.paymentMethod == 'BANK_TRANSFER'}">
                    <div class="w-12 h-12 rounded-lg bg-amber-soft text-amber-pro grid place-items-center mb-4">
                        <i data-lucide="clock" class="w-7 h-7"></i>
                    </div>
                    <h1 class="text-[28px] font-extrabold text-ink">Đơn hàng đang chờ chuyển khoản</h1>
                    <p class="text-[15px] text-ink-muted mt-1.5">
                        Vui lòng chuyển khoản đúng số tiền và nội dung bên dưới. Khóa học sẽ tự động kích hoạt ngay sau khi bộ phận hỗ trợ xác nhận giao dịch.
                    </p>
                    <div class="mt-5 grid grid-cols-1 md:grid-cols-12 gap-5 items-center p-4 sm:p-5 rounded-lg bg-paper-soft border border-rule">
                        <c:if test="${not empty vietQrUrl}">
                            <div class="md:col-span-5 flex flex-col items-center">
                                <div class="bg-sheet p-2.5 rounded-lg border-[1.5px] border-ink shadow-sm">
                                    <img src="${vietQrUrl}" alt="Mã QR chuyển khoản VietQR cho đơn ${order.orderCode}"
                                         class="w-52 h-auto object-contain rounded">
                                </div>
                                <span class="text-[11.5px] font-semibold text-ink-muted mt-2 text-center">Quét bằng ứng dụng ngân hàng để tự điền sẵn số tiền &amp; nội dung</span>
                            </div>
                        </c:if>
                        <div class="${not empty vietQrUrl ? 'md:col-span-7' : 'md:col-span-12'} space-y-2.5 text-[13.5px]">
                            <div class="p-2.5 rounded bg-sheet border border-rule">
                                <div class="text-[11.5px] text-ink-muted">Ngân hàng</div>
                                <div class="font-bold text-ink mt-0.5"><c:out value="${siteSettings['bank.name']}"/></div>
                            </div>
                            <div class="p-2.5 rounded bg-sheet border border-rule flex items-center justify-between gap-2">
                                <div class="min-w-0">
                                    <div class="text-[11.5px] text-ink-muted">Số tài khoản · Chủ tài khoản</div>
                                    <div class="font-mono font-bold text-ink mt-0.5"><c:out value="${siteSettings['bank.account_number']}"/></div>
                                    <div class="text-[12px] font-semibold text-ink-muted"><c:out value="${siteSettings['bank.account_holder']}"/></div>
                                </div>
                                <button type="button" onclick="copyText('<c:out value="${siteSettings['bank.account_number']}"/>', 'số tài khoản')"
                                        class="btn-outline-ink px-2.5 py-1.5 text-[12px] shrink-0">Sao chép</button>
                            </div>
                            <div class="p-2.5 rounded bg-sheet border border-rule flex items-center justify-between gap-2">
                                <div>
                                    <div class="text-[11.5px] text-ink-muted">Số tiền chính xác</div>
                                    <div class="font-mono font-extrabold text-[16px] text-amber-pro tabular-nums mt-0.5">${order.formattedTotal}</div>
                                </div>
                                <button type="button" onclick="copyText('${order.totalAmount.longValue()}', 'số tiền')"
                                        class="btn-outline-ink px-2.5 py-1.5 text-[12px] shrink-0">Sao chép</button>
                            </div>
                            <div class="p-2.5 rounded bg-sheet border border-rule flex items-center justify-between gap-2">
                                <div>
                                    <div class="text-[11.5px] text-ink-muted">Nội dung chuyển khoản (bắt buộc)</div>
                                    <div class="font-mono font-extrabold text-[15px] text-blueprint mt-0.5">${order.orderCode}</div>
                                </div>
                                <button type="button" onclick="copyText('${order.orderCode}', 'nội dung chuyển khoản')"
                                        class="btn-blueprint px-2.5 py-1.5 text-[12px] shrink-0">Sao chép</button>
                            </div>
                        </div>
                    </div>
                </c:when>

                <c:when test="${order.status == 'PENDING'}">
                    <div class="w-12 h-12 rounded-lg bg-amber-soft text-amber-pro grid place-items-center mb-4">
                        <i data-lucide="clock" class="w-7 h-7"></i>
                    </div>
                    <h1 class="text-[28px] font-extrabold text-ink">Giao dịch đang được xử lý</h1>
                    <p class="text-[15px] text-ink-muted mt-1.5">
                        Đơn hàng <strong class="font-mono text-ink">#${order.orderCode}</strong> đang chờ xác nhận từ cổng thanh toán. Bạn có thể tải lại trang sau vài giây để cập nhật trạng thái.
                    </p>
                </c:when>

                <c:when test="${order.status == 'CANCELLED'}">
                    <div class="w-12 h-12 rounded-lg bg-danger-soft text-danger grid place-items-center mb-4">
                        <i data-lucide="ban" class="w-7 h-7"></i>
                    </div>
                    <h1 class="text-[28px] font-extrabold text-ink">Giao dịch đã bị hủy</h1>
                    <p class="text-[15px] text-ink-muted mt-1.5">
                        Đơn hàng <strong class="font-mono text-ink">#${order.orderCode}</strong> đã bị hủy và chưa phát sinh thanh toán. Bạn có thể quay lại giỏ hàng để đặt lại bất kỳ lúc nào.
                    </p>
                </c:when>

                <c:otherwise>
                    <div class="w-12 h-12 rounded-lg bg-danger-soft text-danger grid place-items-center mb-4">
                        <i data-lucide="x-circle" class="w-7 h-7"></i>
                    </div>
                    <h1 class="text-[28px] font-extrabold text-ink">Thanh toán không thành công</h1>
                    <p class="text-[15px] text-ink-muted mt-1.5">
                        Giao dịch cho đơn hàng <strong class="font-mono text-ink">#${order.orderCode}</strong> chưa thể hoàn tất. Vui lòng kiểm tra thông tin thanh toán hoặc chọn phương thức khác tại giỏ hàng.
                    </p>
                </c:otherwise>
            </c:choose>

            <!-- Ordered Courses -->
            <div class="mt-7 pt-6 border-t border-rule">
                <h2 class="font-bold text-[15px] text-ink mb-3">Danh sách khóa học trong đơn</h2>
                <ul class="divide-y divide-rule border border-rule rounded-lg overflow-hidden">
                    <c:forEach var="item" items="${order.items}">
                        <li class="p-4 bg-paper-soft flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                            <div>
                                <div class="font-mono text-[11px] font-bold text-amber-pro">${item.courseCode}</div>
                                <div class="font-bold text-[15px] text-ink"><c:out value="${item.courseTitle}"/></div>
                            </div>
                            <div class="flex items-center gap-3">
                                <span class="font-mono text-[14px] font-bold text-ink tabular-nums">${item.formattedPrice}</span>
                                <c:if test="${order.status == 'PAID'}">
                                    <a href="${pageContext.request.contextPath}/learn?courseId=${item.courseId}"
                                       class="btn-blueprint px-3.5 py-1.5 text-[13px]">
                                        <i data-lucide="play" class="w-3.5 h-3.5"></i>
                                        <span>Vào học ngay</span>
                                    </a>
                                </c:if>
                            </div>
                        </li>
                    </c:forEach>
                </ul>
            </div>

            <div class="mt-7 flex flex-wrap gap-3">
                <c:choose>
                    <c:when test="${order.status == 'PAID'}">
                        <a href="${pageContext.request.contextPath}/my-courses" class="btn-ink px-5 py-2.5 text-[14px]">
                            Tới Khóa học của tôi
                        </a>
                    </c:when>
                    <c:when test="${order.status == 'PENDING'}">
                        <a href="${pageContext.request.contextPath}/payment/result?orderCode=${order.orderCode}" class="btn-blueprint px-5 py-2.5 text-[14px]">
                            Cập nhật trạng thái
                        </a>
                        <a href="${pageContext.request.contextPath}/my-courses" class="btn-outline-ink px-5 py-2.5 text-[14px]">
                            Lịch sử đơn hàng
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/cart" class="btn-pro px-5 py-2.5 text-[14px]">
                            Quay lại giỏ hàng
                        </a>
                    </c:otherwise>
                </c:choose>
                <a href="${pageContext.request.contextPath}/home" class="btn-outline-ink px-5 py-2.5 text-[14px]">
                    Về trang chủ
                </a>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/inc/footer.jsp"/>
</body>
</html>
