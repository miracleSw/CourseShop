<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="bodyClass" value="bg-paper text-ink antialiased min-h-screen flex flex-col lg:flex-row" scope="request"/>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/admin-sidebar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 p-5 sm:p-8 lg:p-10 min-w-0 space-y-8">
    <div class="flex flex-wrap items-end justify-between gap-4 pb-4 border-b-[1.5px] border-ink">
        <div>
            <h1 class="text-[26px] sm:text-[32px] font-extrabold tracking-tight text-ink">Quản lý Lộ trình học</h1>
            <p class="text-[14px] text-ink-muted mt-1">Tạo mới, chỉnh sửa mục tiêu nghề nghiệp và chọn các khóa học thuộc từng lộ trình.</p>
        </div>
        <c:if test="${not empty editPath}">
            <a href="${pageContext.request.contextPath}/admin/paths" class="btn-outline-ink px-4 py-2 text-[13px]">
                + Tạo lộ trình mới
            </a>
        </c:if>
    </div>

    <div class="grid grid-cols-1 xl:grid-cols-12 gap-8 items-start">
        <!-- Create / Edit Form -->
        <section class="xl:col-span-5 binder-sheet rounded-xl p-6">
            <h2 class="text-[17px] font-extrabold text-ink mb-4">
                ${not empty editPath ? 'Chỉnh sửa lộ trình' : 'Thêm lộ trình mới'}
            </h2>
            <form action="${pageContext.request.contextPath}/admin/paths" method="post" class="space-y-4">
                <input type="hidden" name="id" value="${not empty editPath ? editPath.id : 0}">
                <div>
                    <label class="block text-[13px] font-bold mb-1">Tên lộ trình</label>
                    <input type="text" name="title" required value="<c:out value='${editPath.title}'/>"
                           placeholder="VD: Lộ trình Fullstack Web" class="lab-input">
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div class="sm:col-span-2">
                        <label class="block text-[13px] font-bold mb-1">Vị trí mục tiêu</label>
                        <input type="text" name="targetRole" required value="<c:out value='${editPath.targetRole}'/>"
                               placeholder="VD: Kỹ sư Web Fullstack" class="lab-input">
                    </div>
                    <div>
                        <label class="block text-[13px] font-bold mb-1">Thứ tự</label>
                        <input type="number" name="sortOrder" min="1" value="${not empty editPath ? editPath.sortOrder : paths.size() + 1}"
                               class="lab-input font-mono text-center">
                    </div>
                </div>
                <div>
                    <label class="block text-[13px] font-bold mb-1">Mô tả ngắn</label>
                    <textarea name="summary" rows="3" class="lab-input"><c:out value="${editPath.summary}"/></textarea>
                </div>
                <div>
                    <label class="block text-[13px] font-bold mb-1.5">Các khóa học trong lộ trình</label>
                    <div class="max-h-60 overflow-y-auto p-3 rounded-lg bg-paper-soft border border-rule space-y-2">
                        <c:forEach var="c" items="${allCourses}">
                            <c:set var="checked" value="false"/>
                            <c:if test="${not empty editPath}">
                                <c:forEach var="ec" items="${editPath.courses}">
                                    <c:if test="${ec.id == c.id}"><c:set var="checked" value="true"/></c:if>
                                </c:forEach>
                            </c:if>
                            <label class="flex items-start gap-2.5 text-[13px] cursor-pointer">
                                <input type="checkbox" name="courseIds" value="${c.id}" ${checked ? 'checked' : ''} class="mt-0.5 accent-blueprint">
                                <span class="leading-snug">
                                    <strong class="font-mono text-[11.5px] ${c.pro ? 'text-amber-pro' : 'text-blueprint'}">${c.code}</strong>
                                    <c:out value="${c.title}"/>
                                </span>
                            </label>
                        </c:forEach>
                    </div>
                </div>
                <div class="flex gap-2 pt-1">
                    <button type="submit" class="btn-blueprint px-5 py-2.5 text-[14px]">
                        ${not empty editPath ? 'Lưu thay đổi' : 'Tạo lộ trình'}
                    </button>
                    <c:if test="${not empty editPath}">
                        <a href="${pageContext.request.contextPath}/admin/paths" class="btn-outline-ink px-4 py-2.5 text-[14px]">Hủy</a>
                    </c:if>
                </div>
            </form>
        </section>

        <!-- Paths Table -->
        <section class="xl:col-span-7 binder-sheet rounded-xl overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-[13.5px] border-collapse">
                    <thead>
                        <tr class="bg-paper-soft border-b border-ink font-mono text-[11.5px] uppercase text-ink-muted">
                            <th class="px-4 py-3.5">Mã</th>
                            <th class="px-4 py-3.5">Lộ trình &amp; Học phần</th>
                            <th class="px-4 py-3.5 text-right">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-rule">
                        <c:forEach var="lp" items="${paths}">
                            <tr class="hover:bg-paper-soft/60">
                                <td class="px-4 py-3.5 font-mono font-extrabold text-blueprint align-top">${lp.code}</td>
                                <td class="px-4 py-3.5">
                                    <div class="font-extrabold text-ink"><c:out value="${lp.title}"/></div>
                                    <div class="text-[12px] text-ink-muted mt-0.5"><c:out value="${lp.targetRole}"/> · ${lp.courses.size()} khóa học</div>
                                    <div class="mt-2 flex flex-wrap gap-1">
                                        <c:forEach var="pc" items="${lp.courses}">
                                            <span class="font-mono text-[11px] font-bold px-2 py-0.5 rounded bg-paper border border-rule text-ink">${pc.code}</span>
                                        </c:forEach>
                                    </div>
                                </td>
                                <td class="px-4 py-3.5 text-right whitespace-nowrap align-top space-x-2">
                                    <a href="${pageContext.request.contextPath}/admin/paths?edit=${lp.id}"
                                       class="font-bold text-blueprint hover:underline">Sửa</a>
                                    <form action="${pageContext.request.contextPath}/admin/paths" method="post" class="inline"
                                          onsubmit="return confirm('Xác nhận xóa lộ trình này?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="${lp.id}">
                                        <button type="submit" class="font-bold text-danger hover:underline">Xóa</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </section>
    </div>
</main>
</body>
</html>
