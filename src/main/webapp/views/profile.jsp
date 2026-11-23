<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/navbar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 max-w-[1160px] w-full mx-auto px-4 sm:px-6 lg:px-10 py-10 space-y-8">
    <div class="pb-5 border-b-[1.5px] border-ink flex flex-col sm:flex-row sm:items-end justify-between gap-3">
        <div>
            <h1 class="text-[28px] sm:text-[34px] font-extrabold tracking-tight text-ink">Hồ sơ cá nhân</h1>
            <p class="text-[14px] text-ink-muted mt-1">Cập nhật thông tin tài khoản, bảo mật mật khẩu và xem chứng chỉ hoàn thành.</p>
        </div>
        <a href="${pageContext.request.contextPath}/my-courses" class="btn-outline-ink px-4 py-2 text-[13.5px] self-start sm:self-auto">
            Khóa học của tôi
        </a>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        <!-- Personal Info -->
        <section class="lg:col-span-6 binder-sheet rounded-xl overflow-hidden">
            <div class="h-2 bg-blueprint"></div>
            <div class="p-6 sm:p-7 space-y-5">
                <div class="flex items-center gap-3.5">
                    <span class="w-12 h-12 rounded-lg bg-blueprint text-white font-mono text-[18px] font-extrabold grid place-items-center shrink-0">
                        <c:out value="${sessionScope.user.initials}"/>
                    </span>
                    <div class="min-w-0">
                        <h2 class="text-[18px] font-extrabold text-ink truncate"><c:out value="${sessionScope.user.fullName}"/></h2>
                        <div class="font-mono text-[12.5px] text-ink-muted truncate"><c:out value="${sessionScope.user.email}"/></div>
                    </div>
                </div>

                <form action="${pageContext.request.contextPath}/profile" method="post" class="space-y-4">
                    <input type="hidden" name="action" value="updateInfo">
                    <div>
                        <label for="fullName" class="block text-[13px] font-bold text-ink mb-1.5">Họ và tên</label>
                        <input id="fullName" type="text" name="fullName" required minlength="2"
                               value="<c:out value='${sessionScope.user.fullName}'/>" class="lab-input">
                    </div>
                    <div>
                        <label for="email" class="block text-[13px] font-bold text-ink mb-1.5">Địa chỉ Email</label>
                        <input id="email" type="email" disabled
                               value="<c:out value='${sessionScope.user.email}'/>"
                               class="lab-input font-mono bg-paper text-ink-muted opacity-80">
                    </div>
                    <div>
                        <label for="phone" class="block text-[13px] font-bold text-ink mb-1.5">Số điện thoại</label>
                        <input id="phone" type="tel" name="phone" placeholder="0912345678"
                               value="<c:out value='${sessionScope.user.phone}'/>" class="lab-input font-mono">
                    </div>
                    <button type="submit" class="btn-blueprint px-5 py-2.5 text-[14px]">
                        <i data-lucide="save" class="w-4 h-4"></i>
                        <span>Lưu thông tin</span>
                    </button>
                </form>
            </div>
        </section>

        <!-- Change Password -->
        <section class="lg:col-span-6 binder-sheet rounded-xl overflow-hidden">
            <div class="h-2 bg-ink"></div>
            <div class="p-6 sm:p-7 space-y-5">
                <div>
                    <h2 class="text-[18px] font-extrabold text-ink">Đổi mật khẩu</h2>
                    <p class="text-[13px] text-ink-muted mt-0.5">Sử dụng mật khẩu tối thiểu 6 ký tự để bảo vệ tài khoản học tập của bạn.</p>
                </div>

                <form action="${pageContext.request.contextPath}/profile" method="post" class="space-y-4">
                    <input type="hidden" name="action" value="changePassword">
                    <div>
                        <label for="currentPassword" class="block text-[13px] font-bold text-ink mb-1.5">Mật khẩu hiện tại</label>
                        <input id="currentPassword" type="password" name="currentPassword" required class="lab-input">
                    </div>
                    <div>
                        <label for="newPassword" class="block text-[13px] font-bold text-ink mb-1.5">Mật khẩu mới</label>
                        <input id="newPassword" type="password" name="newPassword" required minlength="6" placeholder="Ít nhất 6 ký tự" class="lab-input">
                    </div>
                    <div>
                        <label for="confirmPassword" class="block text-[13px] font-bold text-ink mb-1.5">Nhập lại mật khẩu mới</label>
                        <input id="confirmPassword" type="password" name="confirmPassword" required minlength="6" class="lab-input">
                    </div>
                    <button type="submit" class="btn-ink px-5 py-2.5 text-[14px]">
                        <i data-lucide="key-round" class="w-4 h-4"></i>
                        <span>Cập nhật mật khẩu</span>
                    </button>
                </form>
            </div>
        </section>
    </div>

    <!-- Earned Certificates -->
    <section class="binder-sheet rounded-xl p-6 sm:p-7">
        <div class="flex flex-wrap items-center justify-between gap-3 pb-4 mb-5 border-b border-rule">
            <div>
                <h2 class="text-[19px] font-extrabold text-ink">Chứng chỉ đã đạt được</h2>
                <p class="text-[13px] text-ink-muted mt-0.5">Chứng chỉ được cấp tự động khi bạn hoàn thành 100% bài giảng trong khóa học.</p>
            </div>
            <a href="${pageContext.request.contextPath}/certificate" class="text-[13px] font-bold text-blueprint hover:underline">
                Tra cứu chứng chỉ →
            </a>
        </div>

        <c:choose>
            <c:when test="${empty certificates}">
                <p class="text-[14px] text-ink-muted">Bạn chưa có chứng chỉ nào. Hoàn thành toàn bộ bài học trong một khóa để nhận chứng chỉ ngay lập tức.</p>
            </c:when>
            <c:otherwise>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <c:forEach var="ct" items="${certificates}">
                        <div class="p-4 rounded-lg border-[1.5px] border-ink bg-paper-soft flex items-center justify-between gap-4">
                            <div class="min-w-0">
                                <div class="font-mono text-[11.5px] font-bold text-emerald-ok">${ct.certificateCode}</div>
                                <div class="font-extrabold text-[15px] text-ink truncate mt-0.5"><c:out value="${ct.courseTitle}"/></div>
                                <div class="text-[12px] text-ink-muted mt-1">
                                    Ngày cấp: <fmt:formatDate value="${ct.issuedAt}" pattern="dd/MM/yyyy"/>
                                </div>
                            </div>
                            <a href="${pageContext.request.contextPath}/certificate/${ct.certificateCode}"
                               class="btn-blueprint px-3.5 py-2 text-[12.5px] shrink-0">
                                Xem chứng chỉ
                            </a>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</main>

<jsp:include page="/inc/footer.jsp"/>
<jsp:include page="/inc/chat-widget.jsp"/>
</body>
</html>
