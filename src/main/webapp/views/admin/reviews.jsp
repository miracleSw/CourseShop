<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="bodyClass" value="bg-paper text-ink antialiased min-h-screen flex flex-col lg:flex-row" scope="request"/>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/admin-sidebar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 p-5 sm:p-8 lg:p-10 min-w-0 space-y-6">
    <div class="pb-4 border-b-[1.5px] border-ink">
        <h1 class="text-[26px] sm:text-[32px] font-extrabold tracking-tight text-ink">Kiểm duyệt Đánh giá</h1>
        <p class="text-[14px] text-ink-muted mt-1">Theo dõi nhận xét của học viên theo khóa học và gỡ bỏ nội dung không phù hợp.</p>
    </div>

    <!-- Filter Bar -->
    <form action="${pageContext.request.contextPath}/admin/reviews" method="get"
          class="binder-sheet rounded-xl p-4 grid grid-cols-1 sm:grid-cols-12 gap-3 items-center">
        <div class="sm:col-span-4">
            <input type="search" name="q" value="<c:out value='${q}'/>" placeholder="Tìm học viên, email, nội dung..."
                   class="lab-input h-10 text-[13.5px]">
        </div>
        <div class="sm:col-span-4">
            <select name="courseId" class="lab-input h-10 text-[13.5px]">
                <option value="">Tất cả khóa học</option>
                <c:forEach var="c" items="${courses}">
                    <option value="${c.id}" ${filterCourseId == c.id ? 'selected' : ''}>${c.code} · <c:out value="${c.title}"/></option>
                </c:forEach>
            </select>
        </div>
        <div class="sm:col-span-2">
            <select name="rating" class="lab-input h-10 text-[13.5px]">
                <option value="">Mọi số sao</option>
                <c:forEach begin="1" end="5" var="s">
                    <option value="${s}" ${filterRating == s ? 'selected' : ''}>${s} sao</option>
                </c:forEach>
            </select>
        </div>
        <div class="sm:col-span-2 flex gap-2">
            <button type="submit" class="btn-ink h-10 px-4 text-[13px] flex-1">Lọc</button>
            <c:if test="${not empty q || not empty filterCourseId || not empty filterRating}">
                <a href="${pageContext.request.contextPath}/admin/reviews" class="btn-outline-ink h-10 px-3 text-[13px]">Xóa</a>
            </c:if>
        </div>
    </form>

    <!-- Reviews Table -->
    <section class="binder-sheet rounded-xl overflow-hidden">
        <c:choose>
            <c:when test="${empty reviews}">
                <div class="p-10 text-center text-[14px] text-ink-muted">Chưa có đánh giá nào phù hợp bộ lọc hiện tại.</div>
            </c:when>
            <c:otherwise>
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-[13.5px] border-collapse">
                        <thead>
                            <tr class="bg-paper-soft border-b border-ink font-mono text-[11.5px] uppercase text-ink-muted">
                                <th class="px-4 py-3.5">Học viên</th>
                                <th class="px-4 py-3.5">Khóa học</th>
                                <th class="px-4 py-3.5">Số sao</th>
                                <th class="px-4 py-3.5">Nội dung nhận xét</th>
                                <th class="px-4 py-3.5">Ngày gửi</th>
                                <th class="px-4 py-3.5 text-right">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-rule">
                            <c:forEach var="rv" items="${reviews}">
                                <tr class="hover:bg-paper-soft/60">
                                    <td class="px-4 py-3.5">
                                        <div class="font-bold text-ink"><c:out value="${rv.userName}"/></div>
                                        <div class="font-mono text-[11.5px] text-ink-muted"><c:out value="${rv.userEmail}"/></div>
                                    </td>
                                    <td class="px-4 py-3.5">
                                        <span class="font-mono text-[11.5px] font-bold text-blueprint">${rv.courseCode}</span>
                                        <div class="font-semibold text-ink max-w-xs truncate"><c:out value="${rv.courseTitle}"/></div>
                                    </td>
                                    <td class="px-4 py-3.5 font-mono font-bold text-amber-pro whitespace-nowrap">${rv.rating} / 5 sao</td>
                                    <td class="px-4 py-3.5 max-w-md text-ink-muted leading-snug"><c:out value="${rv.comment}"/></td>
                                    <td class="px-4 py-3.5 font-mono text-[12px] text-ink-muted whitespace-nowrap">
                                        <fmt:formatDate value="${rv.createdAt}" pattern="dd/MM/yyyy"/>
                                    </td>
                                    <td class="px-4 py-3.5 text-right whitespace-nowrap">
                                        <form action="${pageContext.request.contextPath}/admin/reviews" method="post" class="inline"
                                              onsubmit="return confirm('Xác nhận xóa đánh giá này?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${rv.id}">
                                            <button type="submit" class="font-bold text-danger hover:underline text-[12.5px]">Xóa</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</main>
</body>
</html>
