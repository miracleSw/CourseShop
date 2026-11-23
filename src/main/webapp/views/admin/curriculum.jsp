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

    <!-- Sections, Inline Edit Lessons & Coding Exercises -->
    <div class="space-y-6">
        <c:forEach var="sec" items="${sections}">
            <section x-data="{ editingSec: false }" class="binder-sheet rounded-xl overflow-hidden">
                <div class="px-5 py-3.5 bg-paper-soft border-b-[1.5px] border-ink">
                    <div x-show="!editingSec" class="flex items-center justify-between gap-3">
                        <h3 class="font-extrabold text-[15.5px] text-ink">
                            <span class="font-mono text-[12px] text-ink-muted mr-1.5">#${sec.sortOrder}</span>
                            <c:out value="${sec.title}"/>
                        </h3>
                        <div class="flex items-center gap-3 shrink-0">
                            <button type="button" @click="editingSec = true" class="text-[12.5px] font-bold text-blueprint hover:underline">Sửa chương</button>
                            <form action="${pageContext.request.contextPath}/admin/curriculum" method="post"
                                  onsubmit="return confirm('Xóa chương này cùng toàn bộ bài học bên trong?');">
                                <input type="hidden" name="courseId" value="${course.id}">
                                <input type="hidden" name="action" value="deleteSection">
                                <input type="hidden" name="sectionId" value="${sec.id}">
                                <button type="submit" class="text-[12.5px] font-bold text-danger hover:underline">Xóa chương</button>
                            </form>
                        </div>
                    </div>

                    <form x-show="editingSec" x-cloak action="${pageContext.request.contextPath}/admin/curriculum" method="post"
                          class="flex flex-col sm:flex-row gap-2.5 items-center">
                        <input type="hidden" name="courseId" value="${course.id}">
                        <input type="hidden" name="action" value="updateSection">
                        <input type="hidden" name="sectionId" value="${sec.id}">
                        <input type="text" name="title" required value="<c:out value='${sec.title}'/>" class="lab-input flex-1 text-[13.5px]">
                        <input type="number" name="sortOrder" value="${sec.sortOrder}" min="1" class="lab-input sm:w-20 font-mono text-center text-[13px]">
                        <div class="flex gap-2 shrink-0">
                            <button type="submit" class="btn-blueprint px-3.5 py-2 text-[12.5px]">Lưu</button>
                            <button type="button" @click="editingSec = false" class="btn-outline-ink px-3 py-2 text-[12.5px]">Hủy</button>
                        </div>
                    </form>
                </div>

                <ul class="divide-y divide-rule">
                    <c:forEach var="l" items="${sec.lessons}">
                        <c:set var="ex" value="${exercisesMap[l.id]}"/>
                        <li x-data="{ editingLesson: false, editingEx: false }" class="px-5 py-3.5 text-[13.5px] space-y-3">
                            <div x-show="!editingLesson" class="flex flex-col sm:flex-row sm:items-center justify-between gap-2.5">
                                <div class="min-w-0">
                                    <div class="flex flex-wrap items-center gap-2">
                                        <span class="font-mono text-[11.5px] text-ink-muted">#${l.sortOrder}</span>
                                        <span class="font-bold text-ink"><c:out value="${l.title}"/></span>
                                        <c:if test="${l.preview}">
                                            <span class="font-mono text-[10.5px] font-bold px-2 py-0.5 rounded bg-blueprint-soft text-blueprint">HỌC THỬ</span>
                                        </c:if>
                                        <c:if test="${not empty ex}">
                                            <span class="font-mono text-[10.5px] font-bold px-2 py-0.5 rounded bg-emerald-soft text-emerald-ok">CÓ BÀI TẬP MÃ</span>
                                        </c:if>
                                    </div>
                                    <div class="font-mono text-[11.5px] text-ink-muted truncate mt-0.5">${l.videoUrl} · ${l.formattedDuration}</div>
                                </div>
                                <div class="flex items-center gap-3 shrink-0">
                                    <button type="button" @click="editingLesson = true; editingEx = false" class="text-[12px] font-bold text-blueprint hover:underline">Sửa bài</button>
                                    <button type="button" @click="editingEx = !editingEx; editingLesson = false" class="text-[12px] font-bold text-amber-pro hover:underline">
                                        ${not empty ex ? 'Sửa bài tập mã' : '+ Bài tập mã'}
                                    </button>
                                    <form action="${pageContext.request.contextPath}/admin/curriculum" method="post" class="inline"
                                          onsubmit="return confirm('Xác nhận xóa bài học này?');">
                                        <input type="hidden" name="courseId" value="${course.id}">
                                        <input type="hidden" name="action" value="deleteLesson">
                                        <input type="hidden" name="lessonId" value="${l.id}">
                                        <button type="submit" class="text-[12px] font-bold text-danger hover:underline">Xóa</button>
                                    </form>
                                </div>
                            </div>

                            <!-- Inline Edit Lesson Form -->
                            <form x-show="editingLesson" x-cloak action="${pageContext.request.contextPath}/admin/curriculum" method="post"
                                  class="p-4 rounded-lg bg-paper-soft border border-rule grid grid-cols-1 md:grid-cols-12 gap-3">
                                <input type="hidden" name="courseId" value="${course.id}">
                                <input type="hidden" name="action" value="updateLesson">
                                <input type="hidden" name="lessonId" value="${l.id}">

                                <div class="md:col-span-5">
                                    <label class="block text-[11.5px] font-bold text-ink-muted mb-1">Tên bài học</label>
                                    <input type="text" name="title" required value="<c:out value='${l.title}'/>" class="lab-input text-[13px]">
                                </div>
                                <div class="md:col-span-4">
                                    <label class="block text-[11.5px] font-bold text-ink-muted mb-1">Link video YouTube</label>
                                    <input type="url" name="videoUrl" value="<c:out value='${l.videoUrl}'/>" class="lab-input font-mono text-[12.5px]">
                                </div>
                                <div class="md:col-span-1">
                                    <label class="block text-[11.5px] font-bold text-ink-muted mb-1">Phút</label>
                                    <input type="number" name="durationMinutes" min="1" value="${l.durationSeconds / 60}" class="lab-input font-mono text-[13px]">
                                </div>
                                <div class="md:col-span-2">
                                    <label class="block text-[11.5px] font-bold text-ink-muted mb-1">Thứ tự</label>
                                    <input type="number" name="sortOrder" min="1" value="${l.sortOrder}" class="lab-input font-mono text-[13px]">
                                </div>
                                <div class="md:col-span-9">
                                    <label class="block text-[11.5px] font-bold text-ink-muted mb-1">Tóm tắt nội dung</label>
                                    <input type="text" name="contentText" value="<c:out value='${l.contentText}'/>" class="lab-input text-[13px]">
                                </div>
                                <div class="md:col-span-3 flex items-end justify-between gap-2">
                                    <label class="inline-flex items-center gap-1.5 text-[12.5px] font-bold text-ink mb-2">
                                        <input type="checkbox" name="isPreview" value="1" ${l.preview ? 'checked' : ''} class="accent-blueprint">
                                        <span>Học thử</span>
                                    </label>
                                    <div class="flex gap-1.5">
                                        <button type="submit" class="btn-blueprint px-3 py-2 text-[12.5px]">Lưu</button>
                                        <button type="button" @click="editingLesson = false" class="btn-outline-ink px-2.5 py-2 text-[12.5px]">Hủy</button>
                                    </div>
                                </div>
                            </form>

                            <!-- Inline Coding Exercise Form -->
                            <div x-show="editingEx" x-cloak class="p-4 rounded-lg bg-paper-soft border border-rule space-y-3">
                                <div class="flex items-center justify-between">
                                    <h4 class="font-extrabold text-[13.5px] text-ink">Bài tập viết mã cho bài học này</h4>
                                    <c:if test="${not empty ex}">
                                        <form action="${pageContext.request.contextPath}/admin/curriculum" method="post">
                                            <input type="hidden" name="courseId" value="${course.id}">
                                            <input type="hidden" name="action" value="deleteExercise">
                                            <input type="hidden" name="lessonId" value="${l.id}">
                                            <button type="submit" class="text-[12px] font-bold text-danger hover:underline">Gỡ bài tập</button>
                                        </form>
                                    </c:if>
                                </div>
                                <form action="${pageContext.request.contextPath}/admin/curriculum" method="post" class="grid grid-cols-1 md:grid-cols-12 gap-3">
                                    <input type="hidden" name="courseId" value="${course.id}">
                                    <input type="hidden" name="action" value="saveExercise">
                                    <input type="hidden" name="lessonId" value="${l.id}">

                                    <div class="md:col-span-8">
                                        <label class="block text-[11.5px] font-bold text-ink-muted mb-1">Tiêu đề bài tập</label>
                                        <input type="text" name="title" required value="<c:out value='${ex.title}'/>" placeholder="VD: Dựng thẻ HTML5 ngữ nghĩa" class="lab-input text-[13px]">
                                    </div>
                                    <div class="md:col-span-4">
                                        <label class="block text-[11.5px] font-bold text-ink-muted mb-1">Ngôn ngữ</label>
                                        <select name="language" class="lab-input text-[13px] font-mono">
                                            <option value="html" ${ex.language == 'html' ? 'selected' : ''}>html</option>
                                            <option value="css" ${ex.language == 'css' ? 'selected' : ''}>css</option>
                                            <option value="javascript" ${ex.language == 'javascript' ? 'selected' : ''}>javascript</option>
                                            <option value="java" ${ex.language == 'java' ? 'selected' : ''}>java</option>
                                            <option value="sql" ${ex.language == 'sql' ? 'selected' : ''}>sql</option>
                                        </select>
                                    </div>
                                    <div class="md:col-span-12">
                                        <label class="block text-[11.5px] font-bold text-ink-muted mb-1">Yêu cầu đề bài</label>
                                        <textarea name="promptText" rows="2" required class="lab-input text-[13px]"><c:out value="${ex.promptText}"/></textarea>
                                    </div>
                                    <div class="md:col-span-6">
                                        <label class="block text-[11.5px] font-bold text-ink-muted mb-1">Mã khởi tạo cho học viên</label>
                                        <textarea name="starterCode" rows="4" class="lab-input font-mono text-[12px]"><c:out value="${ex.starterCode}"/></textarea>
                                    </div>
                                    <div class="md:col-span-6">
                                        <label class="block text-[11.5px] font-bold text-ink-muted mb-1">Từ khóa bắt buộc để chấm đạt (mỗi dòng 1 chuỗi)</label>
                                        <textarea name="expectedTokens" rows="4" class="lab-input font-mono text-[12px]"><c:out value="${ex.expectedTokens}"/></textarea>
                                    </div>
                                    <div class="md:col-span-6">
                                        <label class="block text-[11.5px] font-bold text-ink-muted mb-1">Gợi ý (tùy chọn)</label>
                                        <input type="text" name="hintText" value="<c:out value='${ex.hintText}'/>" class="lab-input text-[13px]">
                                    </div>
                                    <div class="md:col-span-6">
                                        <label class="block text-[11.5px] font-bold text-ink-muted mb-1">Đáp án mẫu (tùy chọn)</label>
                                        <textarea name="solutionCode" rows="2" class="lab-input font-mono text-[12px]"><c:out value="${ex.solutionCode}"/></textarea>
                                    </div>
                                    <div class="md:col-span-12 flex justify-end gap-2">
                                        <button type="button" @click="editingEx = false" class="btn-outline-ink px-3 py-1.5 text-[12.5px]">Đóng</button>
                                        <button type="submit" class="btn-pro px-4 py-1.5 text-[12.5px]">Lưu bài tập</button>
                                    </div>
                                </form>
                            </div>
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

    <!-- Chapter & Course Quizzes Management -->
    <section class="binder-sheet rounded-xl p-6 space-y-6">
        <div class="border-b border-rule pb-3">
            <h2 class="text-[18px] font-extrabold text-ink">Bài kiểm tra trắc nghiệm cuối chương</h2>
            <p class="text-[13px] text-ink-muted mt-0.5">Tạo bộ câu hỏi trắc nghiệm giúp học viên ôn luyện ngay trong phòng học.</p>
        </div>

        <form action="${pageContext.request.contextPath}/admin/curriculum" method="post" class="grid grid-cols-1 md:grid-cols-12 gap-3 items-end">
            <input type="hidden" name="courseId" value="${course.id}">
            <input type="hidden" name="action" value="addQuiz">
            <div class="md:col-span-4">
                <label class="block text-[12px] font-bold text-ink-muted mb-1">Tên bài kiểm tra</label>
                <input type="text" name="title" required placeholder="VD: Kiểm tra cuối Chương 1" class="lab-input text-[13px]">
            </div>
            <div class="md:col-span-3">
                <label class="block text-[12px] font-bold text-ink-muted mb-1">Thuộc chương (tùy chọn)</label>
                <select name="sectionId" class="lab-input text-[13px]">
                    <option value="0">Toàn khóa học</option>
                    <c:forEach var="s" items="${sections}">
                        <option value="${s.id}"><c:out value="${s.title}"/></option>
                    </c:forEach>
                </select>
            </div>
            <div class="md:col-span-3">
                <label class="block text-[12px] font-bold text-ink-muted mb-1">Mô tả ngắn</label>
                <input type="text" name="description" placeholder="Nội dung đánh giá..." class="lab-input text-[13px]">
            </div>
            <div class="md:col-span-2 flex gap-2">
                <input type="number" name="passScore" value="70" min="10" max="100" class="lab-input w-20 font-mono text-[13px] text-center" title="Điểm đạt (%)">
                <button type="submit" class="btn-blueprint px-3.5 py-2 text-[13px] shrink-0">+ Tạo</button>
            </div>
        </form>

        <c:forEach var="qz" items="${quizzes}">
            <div class="border-[1.5px] border-rule rounded-lg overflow-hidden">
                <div class="px-4 py-3 bg-paper-soft border-b border-rule flex flex-wrap items-center justify-between gap-2">
                    <div>
                        <span class="font-extrabold text-[14.5px] text-ink"><c:out value="${qz.title}"/></span>
                        <span class="ml-2 font-mono text-[11.5px] text-ink-muted">(${qz.questions.size()} câu · Đạt từ ${qz.passScore}%)</span>
                    </div>
                    <form action="${pageContext.request.contextPath}/admin/curriculum" method="post"
                          onsubmit="return confirm('Xóa bài kiểm tra này?');">
                        <input type="hidden" name="courseId" value="${course.id}">
                        <input type="hidden" name="action" value="deleteQuiz">
                        <input type="hidden" name="quizId" value="${qz.id}">
                        <button type="submit" class="text-[12px] font-bold text-danger hover:underline">Xóa bài kiểm tra</button>
                    </form>
                </div>

                <ul class="divide-y divide-rule bg-sheet">
                    <c:forEach var="qq" items="${qz.questions}" varStatus="qst">
                        <li class="px-4 py-3 flex items-start justify-between gap-3 text-[13px]">
                            <div class="min-w-0">
                                <div class="font-bold text-ink">Câu ${qst.count}: <c:out value="${qq.questionText}"/></div>
                                <div class="text-[12px] text-ink-muted mt-1">
                                    A. <c:out value="${qq.optionA}"/> · B. <c:out value="${qq.optionB}"/> · C. <c:out value="${qq.optionC}"/> · D. <c:out value="${qq.optionD}"/>
                                    <span class="ml-2 font-mono font-bold text-emerald-ok">[Đáp án: ${qq.correctOption}]</span>
                                </div>
                            </div>
                            <form action="${pageContext.request.contextPath}/admin/curriculum" method="post" class="shrink-0">
                                <input type="hidden" name="courseId" value="${course.id}">
                                <input type="hidden" name="action" value="deleteQuestion">
                                <input type="hidden" name="questionId" value="${qq.id}">
                                <button type="submit" class="text-[12px] font-bold text-danger hover:underline">Xóa</button>
                            </form>
                        </li>
                    </c:forEach>
                </ul>

                <form action="${pageContext.request.contextPath}/admin/curriculum" method="post"
                      class="p-4 bg-paper-soft border-t border-rule grid grid-cols-1 md:grid-cols-12 gap-2.5">
                    <input type="hidden" name="courseId" value="${course.id}">
                    <input type="hidden" name="action" value="addQuestion">
                    <input type="hidden" name="quizId" value="${qz.id}">
                    <input type="hidden" name="sortOrder" value="${qz.questions.size() + 1}">

                    <div class="md:col-span-12">
                        <input type="text" name="questionText" required placeholder="Nội dung câu hỏi trắc nghiệm mới..." class="lab-input text-[13px]">
                    </div>
                    <div class="md:col-span-3"><input type="text" name="optionA" required placeholder="Đáp án A" class="lab-input text-[12.5px]"></div>
                    <div class="md:col-span-3"><input type="text" name="optionB" required placeholder="Đáp án B" class="lab-input text-[12.5px]"></div>
                    <div class="md:col-span-3"><input type="text" name="optionC" required placeholder="Đáp án C" class="lab-input text-[12.5px]"></div>
                    <div class="md:col-span-3"><input type="text" name="optionD" required placeholder="Đáp án D" class="lab-input text-[12.5px]"></div>
                    <div class="md:col-span-2">
                        <select name="correctOption" class="lab-input text-[12.5px] font-mono">
                            <option value="A">Đúng: A</option>
                            <option value="B">Đúng: B</option>
                            <option value="C">Đúng: C</option>
                            <option value="D">Đúng: D</option>
                        </select>
                    </div>
                    <div class="md:col-span-8">
                        <input type="text" name="explanation" placeholder="Giải thích ngắn gọn sau khi học viên nộp bài..." class="lab-input text-[12.5px]">
                    </div>
                    <div class="md:col-span-2">
                        <button type="submit" class="btn-ink w-full py-2 text-[12.5px]">+ Thêm câu hỏi</button>
                    </div>
                </form>
            </div>
        </c:forEach>
    </section>
</main>
</body>
</html>
