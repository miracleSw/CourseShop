<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/navbar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 flex items-center justify-center px-4 py-12">
    <div class="w-full max-w-md binder-sheet rounded-xl overflow-hidden">
        <div class="h-2 bg-blueprint"></div>
        <div class="p-7 sm:p-8">
            <h1 class="text-[26px] font-extrabold text-ink tracking-tight">Đăng nhập CourseShop</h1>
            <p class="text-[14px] text-ink-muted mt-1.5">Tiếp tục lộ trình học và quản lý các khóa học đã sở hữu.</p>

            <c:if test="${not empty error}">
                <div class="mt-4 px-4 py-3 rounded-lg bg-danger-soft border border-danger/30 text-[13.5px] font-semibold text-danger">
                    <c:out value="${error}"/>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/login" method="post" class="mt-6 space-y-4">
                <div>
                    <label for="identifier" class="block text-[13.5px] font-bold text-ink mb-1.5">Email hoặc Số điện thoại</label>
                    <input id="identifier" type="text" name="identifier" value="<c:out value='${identifier}'/>" required autofocus
                           placeholder="Nhập email hoặc số điện thoại"
                           class="lab-input">
                </div>
                <div>
                    <div class="flex items-center justify-between mb-1.5">
                        <label for="password" class="block text-[13.5px] font-bold text-ink">Mật khẩu</label>
                        <a href="${pageContext.request.contextPath}/forgot-password" class="text-[12.5px] font-bold text-blueprint hover:underline">Quên mật khẩu?</a>
                    </div>
                    <input id="password" type="password" name="password" required
                           placeholder="Nhập mật khẩu"
                           class="lab-input">
                </div>
                <button type="submit" class="btn-blueprint w-full py-3 text-[15px]">
                    Đăng nhập
                </button>
            </form>

            <p class="mt-6 text-center text-[13.5px] text-ink-muted">
                Chưa có tài khoản?
                <a href="${pageContext.request.contextPath}/register" class="font-bold text-blueprint hover:underline">Đăng ký miễn phí</a>
            </p>
        </div>
    </div>
</main>

<jsp:include page="/inc/footer.jsp"/>
</body>
</html>
