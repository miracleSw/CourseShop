<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/navbar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 flex items-center justify-center px-4 py-12">
    <div class="w-full max-w-md binder-sheet rounded-xl overflow-hidden">
        <div class="h-2 bg-blueprint"></div>
        <div class="p-7 sm:p-8">
            <h1 class="text-[26px] font-extrabold text-ink tracking-tight">Tạo tài khoản học viên</h1>
            <p class="text-[14px] text-ink-muted mt-1.5">Mở ngay 4 khóa học nền tảng miễn phí và lưu tiến độ bài giảng.</p>

            <c:if test="${not empty error}">
                <div class="mt-4 px-4 py-3 rounded-lg bg-danger-soft border border-danger/30 text-[13.5px] font-semibold text-danger">
                    <c:out value="${error}"/>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/register" method="post" class="mt-6 space-y-4">
                <div>
                    <label for="fullName" class="block text-[13.5px] font-bold text-ink mb-1.5">Họ và tên</label>
                    <input id="fullName" type="text" name="fullName" value="<c:out value='${fullName}'/>" required
                           placeholder="Nguyễn Văn An" class="lab-input">
                </div>
                <div>
                    <label for="email" class="block text-[13.5px] font-bold text-ink mb-1.5">Địa chỉ Email</label>
                    <input id="email" type="email" name="email" value="<c:out value='${email}'/>" required
                           placeholder="an.nguyen@gmail.com" class="lab-input">
                </div>
                <div>
                    <label for="phone" class="block text-[13.5px] font-bold text-ink mb-1.5">Số điện thoại (tùy chọn)</label>
                    <input id="phone" type="tel" name="phone" value="<c:out value='${phone}'/>"
                           placeholder="0912345678" class="lab-input">
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                    <div>
                        <label for="password" class="block text-[13.5px] font-bold text-ink mb-1.5">Mật khẩu</label>
                        <input id="password" type="password" name="password" required minlength="6"
                               placeholder="Ít nhất 6 ký tự" class="lab-input">
                    </div>
                    <div>
                        <label for="confirmPassword" class="block text-[13.5px] font-bold text-ink mb-1.5">Nhập lại mật khẩu</label>
                        <input id="confirmPassword" type="password" name="confirmPassword" required minlength="6"
                               placeholder="Khớp mật khẩu" class="lab-input">
                    </div>
                </div>
                <button type="submit" class="btn-blueprint w-full py-3 text-[15px] mt-1">
                    Đăng ký tài khoản
                </button>
            </form>

            <p class="mt-6 text-center text-[13.5px] text-ink-muted">
                Đã có tài khoản?
                <a href="${pageContext.request.contextPath}/login" class="font-bold text-blueprint hover:underline">Đăng nhập</a>
            </p>
        </div>
    </div>
</main>

<jsp:include page="/inc/footer.jsp"/>
</body>
</html>
