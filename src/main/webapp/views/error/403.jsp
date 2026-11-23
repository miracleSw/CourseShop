<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/navbar.jsp"/>

<main class="flex-1 flex items-center justify-center px-4 py-16">
    <div class="binder-sheet rounded-xl max-w-md w-full p-8 text-center">
        <div class="font-mono text-[42px] font-extrabold text-danger leading-none">403</div>
        <h1 class="text-[22px] font-extrabold text-ink mt-3">Không có quyền truy cập</h1>
        <p class="text-[14px] text-ink-muted mt-2 mb-6">Khu vực này chỉ dành cho tài khoản Quản trị viên (ADMIN).</p>
        <a href="${pageContext.request.contextPath}/home" class="btn-blueprint px-5 py-2.5 text-[14px]">Quay về trang chủ</a>
    </div>
</main>

<jsp:include page="/inc/footer.jsp"/>
</body>
</html>
