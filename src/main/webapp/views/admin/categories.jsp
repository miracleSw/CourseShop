<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="bodyClass" value="bg-paper text-ink antialiased min-h-screen flex flex-col lg:flex-row" scope="request"/>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/admin-sidebar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 p-5 sm:p-8 lg:p-10 min-w-0 space-y-8">
    <div class="pb-4 border-b-[1.5px] border-ink">
        <h1 class="text-[26px] sm:text-[32px] font-extrabold tracking-tight text-ink">Quản lý Danh mục</h1>
        <p class="text-[14px] text-ink-muted mt-1">Tổ chức nhóm chủ đề hiển thị trên bộ lọc trang chủ.</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        <section class="lg:col-span-5 binder-sheet rounded-xl p-6">
            <h2 class="text-[17px] font-extrabold text-ink mb-4">
                ${not empty editCategory ? 'Cập nhật danh mục' : 'Thêm danh mục mới'}
            </h2>
            <form action="${pageContext.request.contextPath}/admin/categories" method="post" class="space-y-4">
                <input type="hidden" name="id" value="${not empty editCategory ? editCategory.id : 0}">
                <div>
                    <label class="block text-[13px] font-bold mb-1">Tên danh mục</label>
                    <input type="text" name="name" required value="<c:out value='${editCategory.name}'/>" class="lab-input">
                </div>
                <div>
                    <label class="block text-[13px] font-bold mb-1">Mô tả</label>
                    <textarea name="description" rows="3" class="lab-input"><c:out value="${editCategory.description}"/></textarea>
                </div>
                <div class="flex gap-2">
                    <button type="submit" class="btn-blueprint px-5 py-2.5 text-[14px]">
                        ${not empty editCategory ? 'Lưu cập nhật' : 'Thêm danh mục'}
                    </button>
                    <c:if test="${not empty editCategory}">
                        <a href="${pageContext.request.contextPath}/admin/categories" class="btn-outline-ink px-4 py-2.5 text-[14px]">Hủy</a>
                    </c:if>
                </div>
            </form>
        </section>

        <section class="lg:col-span-7 binder-sheet rounded-xl overflow-hidden">
            <table class="w-full text-left text-[13.5px] border-collapse">
                <thead>
                    <tr class="bg-paper-soft border-b border-ink font-mono text-[11.5px] uppercase text-ink-muted">
                        <th class="px-5 py-3.5">Danh mục</th>
                        <th class="px-5 py-3.5 text-center">Số khóa</th>
                        <th class="px-5 py-3.5 text-right">Thao tác</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-rule">
                    <c:forEach var="cat" items="${categories}">
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="font-bold text-ink"><c:out value="${cat.name}"/></div>
                                <div class="text-[12px] text-ink-muted"><c:out value="${cat.description}"/></div>
                            </td>
                            <td class="px-5 py-3.5 text-center font-mono font-bold tabular-nums">${cat.courseCount}</td>
                            <td class="px-5 py-3.5 text-right whitespace-nowrap space-x-2">
                                <a href="${pageContext.request.contextPath}/admin/categories?edit=${cat.id}" class="font-bold text-blueprint hover:underline">Sửa</a>
                                <form action="${pageContext.request.contextPath}/admin/categories" method="post" class="inline"
                                      onsubmit="return confirm('Xóa danh mục này?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${cat.id}">
                                    <button type="submit" class="font-bold text-danger hover:underline">Xóa</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </section>
    </div>
</main>
</body>
</html>
