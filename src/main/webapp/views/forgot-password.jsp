<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/navbar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 flex items-center justify-center px-4 py-12">
    <div class="w-full max-w-md binder-sheet rounded-xl overflow-hidden">
        <div class="h-2 bg-blueprint"></div>
        <div class="p-7 sm:p-8">
            <h1 class="text-[24px] font-extrabold text-ink tracking-tight">Khôi phục mật khẩu</h1>
            <p class="text-[14px] text-ink-muted mt-1.5">Nhập địa chỉ email đã đăng ký để nhận liên kết đặt lại mật khẩu mới.</p>

            <c:choose>
                <c:when test="${sent}">
                    <div class="mt-5 p-4 rounded-lg bg-emerald-soft border border-emerald-ok/30 text-[13.5px] text-emerald-ok font-semibold leading-relaxed">
                        Nếu địa chỉ email tồn tại trong hệ thống, liên kết đặt lại mật khẩu đã được gửi tới hộp thư của bạn. Vui lòng kiểm tra cả mục Thư rác (Spam).
                    </div>
                    <a href="${pageContext.request.contextPath}/login" class="btn-blueprint w-full py-2.5 text-[14px] mt-5">
                        Quay lại đăng nhập
                    </a>
                </c:when>
                <c:otherwise>
                    <c:if test="${not empty error}">
                        <div class="mt-4 px-4 py-3 rounded-lg bg-danger-soft border border-danger/30 text-[13.5px] font-semibold text-danger">
                            <c:out value="${error}"/>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/forgot-password" method="post" class="mt-6 space-y-4">
                        <div>
                            <label for="email" class="block text-[13.5px] font-bold text-ink mb-1.5">Địa chỉ Email</label>
                            <input id="email" type="email" name="email" value="<c:out value='${email}'/>" required autofocus
                                   placeholder="email@example.com" class="lab-input">
                        </div>
                        <button type="submit" class="btn-blueprint w-full py-3 text-[14.5px]">
                            Gửi liên kết đặt lại mật khẩu
                        </button>
                    </form>

                    <p class="mt-6 text-center text-[13.5px] text-ink-muted">
                        Nhớ mật khẩu rồi?
                        <a href="${pageContext.request.contextPath}/login" class="font-bold text-blueprint hover:underline">Đăng nhập</a>
                    </p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

<jsp:include page="/inc/footer.jsp"/>
</body>
</html>
