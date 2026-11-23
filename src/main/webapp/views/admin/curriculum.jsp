<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="bodyClass" value="bg-paper text-ink antialiased min-h-screen flex flex-col lg:flex-row" scope="request"/>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/admin-sidebar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 p-5 sm:p-8 lg:p-10 min-w-0 space-y-8">
    <div class="flex flex-wrap items-end justify-between gap-4 pb-4 border-b-[1.5px] border-ink">
        <div>
            <a href="${pageContext.request.contextPath}/admin/courses" class="text-[13px] font-bold text-blueprint hover:underline inline-flex items-center gap-1 mb-1">
                <i data-lucide="arrow-left" class="w-3.5 h-3.5"></i>
                <span>Quay lại danh sách khóa học</span>
            </a>
            <h1 class="text-[24px] sm:text-[30px] font-extrabold tracking-tight text-ink">
                Giáo trình: <span class="font-mono text-blueprint">${course.code}</span> · <c:out value="${course.title}"/>
            </h1>
        </div>
        <a href="${pageContext.request.contextPath}/learn?courseId=${course.id}" class="btn-outline-ink px-4 py-2 text-[13px]">
            <i data-lucide="play" class="w-4 h-4"></i>
            <span>Xem trang học</span>
        </a>
    </div>

    <!-- Add Section Form -->
    <section class="binder-sheet rounded-xl p-6">
        <h2 class="text-[16px] font-extrabold text-ink mb-3">Thêm chương mới</h2>
        <form action="${pageContext.request.contextPath}/admin/curriculum" method="post" class="flex flex-col sm:flex-row gap-3">
            <input type="hidden" name="courseId" value="${course.id}">
            <input type="hidden" name="action" value="addSection">
            <input type="text" name="title" required placeholder="VD: Chương 3: Triển khai & Kiểm thử" class="lab-input flex-1">
            <input type="number" name="sortOrder" value="${sections.size() + 1}" min="1" class="lab-input sm:w-24 font-mono text-center" aria-label="Thứ tự">
            <button type="submit" class="btn-blueprint px-5 py-2 text-[13.5px] shrink-0">Thêm chương</button>
        </form>
    </section>

    <!-- Sections & Lessons Builder -->
    <div class="space-y-6">
        <c:forEach var="sec" items="${sections}">
            <section class="binder-sheet rounded-xl overflow-hidden">
                <div class="px-5 py-3.5 bg-paper-soft border-b-[1.5px] border-ink flex items-center justify-between gap-3">
                    <h3 class="font-extrabold text-[15.5px] text-ink"><c:out value="${sec.title}"/></h3>
                    <form action="${pageContext.request.contextPath}/admin/curriculum" method="post"
                          onsubmit="return confirm('Xóa chương này cùng toàn bộ bài học bên trong?');">
                        <input type="hidden" name="courseId" value="${course.id}">
                        <input type="hidden" name="action" value="deleteSection">
                        <input type="hidden" name="sectionId" value="${sec.id}">
                        <button type="submit" class="text-[12.5px] font-bold text-danger hover:underline">Xóa chương</button>
                    </form>
                </div>

                <ul class="divide-y divide-rule">
                    <c:forEach var="l" items="${sec.lessons}">
                        <li class="px-5 py-3 flex items-center justify-between gap-3 text-[13.5px]">
                            <div class="min-w-0">
                                <span class="font-bold text-ink"><c:out value="${l.title}"/></span>
                                <c:if test="${l.preview}">
                                    <span class="ml-2 font-mono text-[10.5px] font-bold px-2 py-0.5 rounded bg-blueprint-soft text-blueprint">HỌC THỬ</span>
                                </c:if>
                                <div class="font-mono text-[11.5px] text-ink-muted truncate">${l.videoUrl} · ${l.formattedDuration}</div>
                            </div>
                            <form action="${pageContext.request.contextPath}/admin/curriculum" method="post">
                                <input type="hidden" name="courseId" value="${course.id}">
                                <input type="hidden" name="action" value="deleteLesson">
                                <input type="hidden" name="lessonId" value="${l.id}">
                                <button type="submit" class="text-[12px] font-bold text-danger hover:underline shrink-0">Xóa</button>
                            </form>
                        </li>
                    </c:forEach>
                </ul>

                <!-- Add Lesson into Section -->
                <form action="${pageContext.request.contextPath}/admin/curriculum" method="post"
                      class="p-5 bg-paper-soft border-t border-rule grid grid-cols-1 md:grid-cols-12 gap-3">
                    <input type="hidden" name="courseId" value="${course.id}">
                    <input type="hidden" name="action" value="addLesson">
                    <input type="hidden" name="sectionId" value="${sec.id}">
                    <input type="hidden" name="sortOrder" value="${sec.lessons.size() + 1}">

                    <div class="md:col-span-4">
                        <input type="text" name="title" required placeholder="Tên bài học mới..." class="lab-input text-[13px]">
                    </div>
                    <div class="md:col-span-4">
                        <input type="url" name="videoUrl" required placeholder="https://www.youtube.com/watch?v=..." class="lab-input font-mono text-[12.5px]">
                    </div>
                    <div class="md:col-span-2">
                        <input type="number" name="durationMinutes" value="15" min="1" placeholder="Phút" class="lab-input font-mono text-[13px]">
                    </div>
                    <div class="md:col-span-2 flex items-center justify-between gap-2">
                        <label class="inline-flex items-center gap-1.5 text-[12px] font-bold text-ink">
                            <input type="checkbox" name="isPreview" value="1" class="accent-blueprint">
                            <span>Thử</span>
                        </label>
                        <button type="submit" class="btn-ink px-3 py-2 text-[12.5px]">+ Bài</button>
                    </div>
                    <div class="md:col-span-12">
                        <input type="text" name="contentText" placeholder="Tóm tắt nội dung bài học (dùng cho học viên & Trợ giảng AI)..." class="lab-input text-[13px]">
                    </div>
                </form>
            </section>
        </c:forEach>
    </div>
</main>
</body>
</html>
