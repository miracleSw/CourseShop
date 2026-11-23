<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="bodyClass" value="bg-paper text-ink antialiased min-h-screen flex flex-col lg:flex-row" scope="request"/>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/admin-sidebar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 p-5 sm:p-8 lg:p-10 min-w-0 space-y-6">
    <div class="pb-4 border-b-[1.5px] border-ink">
        <h1 class="text-[26px] sm:text-[32px] font-extrabold tracking-tight text-ink">Quản lý Người dùng</h1>
        <p class="text-[14px] text-ink-muted mt-1">Xem danh sách tài khoản, phân quyền Quản trị/Học viên và khóa tạm thời khi cần.</p>
    </div>

    <form action="${pageContext.request.contextPath}/admin/users" method="get"
          class="binder-sheet rounded-xl p-4 flex flex-col sm:flex-row gap-3 items-stretch sm:items-center">
        <input type="search" name="q" value="<c:out value='${q}'/>"
               placeholder="Tìm theo họ tên, email hoặc số điện thoại..."
               class="lab-input h-10 text-[13.5px] flex-1">
        <div class="flex gap-2 shrink-0">
            <button type="submit" class="btn-ink h-10 px-4 text-[13px]">Tìm người dùng</button>
            <c:if test="${not empty q}">
                <a href="${pageContext.request.contextPath}/admin/users" class="btn-outline-ink h-10 px-3.5 text-[13px]">Xóa lọc</a>
            </c:if>
        </div>
    </form>

    <section class="binder-sheet rounded-xl overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-[13.5px] border-collapse">
                <thead>
                    <tr class="bg-paper-soft border-b border-ink font-mono text-[11.5px] uppercase text-ink-muted">
                        <th class="px-5 py-3.5">ID</th>
                        <th class="px-5 py-3.5">Họ tên &amp; Email</th>
                        <th class="px-5 py-3.5">Số điện thoại</th>
                        <th class="px-5 py-3.5">Vai trò</th>
                        <th class="px-5 py-3.5">Trạng thái</th>
                        <th class="px-5 py-3.5 text-right">Thao tác</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-rule">
                    <c:forEach var="u" items="${users}">
                        <tr class="hover:bg-paper-soft/60">
                            <td class="px-5 py-3.5 font-mono font-bold text-ink-muted">#${u.id}</td>
                            <td class="px-5 py-3.5">
                                <div class="font-bold text-ink"><c:out value="${u.fullName}"/></div>
                                <div class="font-mono text-[12px] text-ink-muted"><c:out value="${u.email}"/></div>
                            </td>
                            <td class="px-5 py-3.5 font-mono text-[12.5px] text-ink-muted"><c:out value="${not empty u.phone ? u.phone : '—'}"/></td>
                            <td class="px-5 py-3.5 whitespace-nowrap">
                                <span class="inline-block whitespace-nowrap text-[11.5px] font-bold px-2 py-0.5 rounded ${u.admin ? 'bg-amber-soft text-amber-ink' : 'bg-blueprint-soft text-blueprint'}">
                                    ${u.admin ? 'Quản trị' : 'Học viên'}
                                </span>
                            </td>
                            <td class="px-5 py-3.5 whitespace-nowrap">
                                <span class="inline-block whitespace-nowrap text-[11.5px] font-bold px-2 py-0.5 rounded ${u.status ? 'bg-emerald-soft text-emerald-ok' : 'bg-danger-soft text-danger'}">
                                    ${u.status ? 'Hoạt động' : 'Đã khóa'}
                                </span>
                            </td>
                            <td class="px-5 py-3.5 text-right whitespace-nowrap space-x-2">
                                <c:if test="${u.id != sessionScope.user.id}">
                                    <form action="${pageContext.request.contextPath}/admin/users" method="post" class="inline">
                                        <input type="hidden" name="userId" value="${u.id}">
                                        <input type="hidden" name="action" value="toggleRole">
                                        <input type="hidden" name="nextRole" value="${u.admin ? 'USER' : 'ADMIN'}">
                                        <button type="submit" class="px-2.5 py-1 rounded border border-rule bg-sheet font-bold text-[12px] text-ink hover:border-ink">
                                            ${u.admin ? 'Chuyển Học viên' : 'Cấp Quản trị'}
                                        </button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/admin/users" method="post" class="inline">
                                        <input type="hidden" name="userId" value="${u.id}">
                                        <input type="hidden" name="action" value="toggleStatus">
                                        <input type="hidden" name="nextStatus" value="${u.status ? '0' : '1'}">
                                        <button type="submit" class="px-2.5 py-1 rounded font-bold text-[12px] ${u.status ? 'text-danger hover:underline' : 'text-emerald-ok hover:underline'}">
                                            ${u.status ? 'Khóa' : 'Mở khóa'}
                                        </button>
                                    </form>
                                </c:if>
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
