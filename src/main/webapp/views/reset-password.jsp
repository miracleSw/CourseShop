<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/navbar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 flex items-center justify-center px-4 py-12">
    <div class="w-full max-w-md binder-sheet rounded-xl overflow-hidden">
        <div class="h-2 bg-blueprint"></div>
        <div class="p-7 sm:p-8">
            <h1 class="text-[24px] font-extrabold text-ink tracking-tight">Đặt lại mật khẩu mới</h1>

            <c:choose>
                <c:when test="${!tokenValid}">
                    <div class="mt-4 px-4 py-3 rounded-lg bg-danger-soft border border-danger/30 text-[13.5px] font-semibold text-danger leading-relaxed">
                        Liên kết đặt lại mật khẩu không hợp lệ hoặc đã hết hạn (hiệu lực 30 phút). Vui lòng gửi lại yêu cầu mới.
                    </div>
                    <a href="${pageContext.request.contextPath}/forgot-password" class="btn-blueprint w-full py-2.5 text-[14px] mt-5">
                        Yêu cầu liên kết mới
                    </a>
                </c:when>
                <c:otherwise>
                    <p class="text-[14px] text-ink-muted mt-1.5">Nhập mật khẩu mới cho tài khoản học viên của bạn.</p>

                    <c:if test="${not empty error}">
                        <div class="mt-4 px-4 py-3 rounded-lg bg-danger-soft border border-danger/30 text-[13.5px] font-semibold text-danger">
                            <c:out value="${error}"/>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/reset-password" method="post" class="mt-6 space-y-4">
                        <input type="hidden" name="token" value="<c:out value='${token}'/>">
                        <div>
                            <label for="password" class="block text-[13.5px] font-bold text-ink mb-1.5">Mật khẩu mới</label>
                            <input id="password" type="password" name="password" required minlength="6" autofocus
                                   placeholder="Ít nhất 6 ký tự" class="lab-input">
                        </div>
                        <div>
                            <label for="confirmPassword" class="block text-[13.5px] font-bold text-ink mb-1.5">Xác nhận mật khẩu mới</label>
                            <input id="confirmPassword" type="password" name="confirmPassword" required minlength="6"
                                   placeholder="Nhập lại mật khẩu mới" class="lab-input">
                        </div>
                        <button type="submit" class="btn-blueprint w-full py-3 text-[14.5px]">
                            Lưu mật khẩu mới
                        </button>
                    </form>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

<jsp:include page="/inc/footer.jsp"/>
</body>
</html>
