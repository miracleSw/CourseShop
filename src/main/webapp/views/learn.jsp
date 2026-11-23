<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="includeLearnJs" value="true" scope="request"/>
<c:set var="bodyClass" value="bg-paper text-ink antialiased overflow-hidden" scope="request"/>
<c:set var="chatCourseId" value="${course.id}" scope="request"/>
<c:set var="chatLessonId" value="${not empty activeLesson ? activeLesson.id : 0}" scope="request"/>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<!-- Build initial notes JSON safely for Alpine -->
<script>
window.__INITIAL_NOTES__ = [
<c:forEach var="n" items="${lessonNotes}" varStatus="st">
  {
    id: ${n.id},
    lessonId: ${n.lessonId},
    timestampSeconds: ${n.timestampSeconds},
    formattedTimestamp: "<c:out value='${n.formattedTimestamp}'/>",
    noteText: "<c:out value='${n.noteText}'/>"
  }<c:if test="${!st.last}">,</c:if>
</c:forEach>
];
</script>

<div x-data="learnWorkspace({
        courseId: ${course.id},
        lessonId: ${not empty activeLesson ? activeLesson.id : 0},
        youtubeId: '${not empty activeLesson ? activeLesson.youtubeId : ''}',
        contextPath: '${pageContext.request.contextPath}',
        completed: ${not empty activeLesson && activeLesson.completed ? 'true' : 'false'},
        doneCount: ${completedCount},
        totalCount: ${totalLessons},
        percent: ${progressPercent},
        initialNotes: window.__INITIAL_NOTES__
     })"
     class="h-screen flex flex-col">

    <!-- Dark Top Header (Operate Mode — F8 inspired) -->
    <header class="h-14 bg-theatre text-[#F4F6F9] border-b border-theatre-border px-4 flex items-center justify-between gap-4 shrink-0">
        <div class="flex items-center gap-3 min-w-0">
            <a href="${pageContext.request.contextPath}/my-courses"
               class="inline-flex items-center gap-1.5 px-2.5 py-1.5 rounded bg-theatre-panel border border-theatre-border hover:border-[#4A5568] text-[13px] font-semibold shrink-0">
                <i data-lucide="chevron-left" class="w-4 h-4"></i>
                <span class="hidden sm:inline">Khóa của tôi</span>
            </a>
            <div class="min-w-0">
                <div class="font-bold text-[14.5px] truncate">
                    <span class="font-mono text-[#93C5FD] mr-1.5">${course.code}</span>
                    <c:out value="${course.title}"/>
                </div>
            </div>
        </div>

        <div class="flex items-center gap-4 shrink-0">
            <!-- Progress Indicator -->
            <div class="hidden md:flex items-center gap-3 font-mono text-[12px] tabular-nums">
                <div class="w-28 h-2 bg-theatre-panel rounded-full overflow-hidden border border-theatre-border">
                    <div class="h-full bg-[#22C55E] transition-all duration-300" :style="'width:' + percent + '%'"></div>
                </div>
                <span class="font-bold text-[#86EFAC]" x-text="percent + '%'"></span>
                <span class="text-[#A8B3C5]" x-text="doneCount + '/' + totalCount + ' bài'"></span>
            </div>

            <button type="button" @click="sidebarOpen = !sidebarOpen"
                    class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded bg-theatre-panel border border-theatre-border hover:border-[#4A5568] text-[13px] font-bold">
                <i data-lucide="list-tree" class="w-4 h-4"></i>
                <span class="hidden sm:inline">Giáo trình</span>
            </button>
        </div>
    </header>

    <!-- Middle Split Workspace -->
    <div class="flex-1 flex min-h-0 overflow-hidden relative">
        <!-- Main Video & Notes Column -->
        <div class="flex-1 overflow-y-auto bg-paper pb-20">
            <c:choose>
                <c:when test="${empty activeLesson}">
                    <div class="p-12 text-center">
                        <h1 class="text-[22px] font-extrabold text-ink">Khóa học này chưa có bài giảng nào</h1>
                        <p class="text-[14px] text-ink-muted mt-2">Quản trị viên sẽ sớm cập nhật video bài học.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Video Theatre -->
                    <div class="bg-[#0B0E13] w-full flex justify-center border-b-[1.5px] border-ink">
                        <div class="w-full max-w-[1060px] aspect-video bg-black">
                            <c:choose>
                                <c:when test="${not empty activeLesson.youtubeId}">
                                    <iframe x-ref="ytPlayer" class="w-full h-full"
                                            :src="embedUrl"
                                            title="<c:out value='${activeLesson.title}'/>"
                                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                            allowfullscreen></iframe>
                                </c:when>
                                <c:otherwise>
                                    <div class="w-full h-full grid place-items-center text-[#94A3B8] text-sm p-6 text-center">
                                        Bài học dạng văn bản thực hành (không đính kèm video).
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- Lesson Info + Complete Toggle + Tabs -->
                    <div class="max-w-[1020px] mx-auto px-4 sm:px-8 py-6 space-y-6">
                        <div class="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
                            <div>
                                <h1 class="text-[22px] sm:text-[26px] font-extrabold text-ink leading-snug">
                                    <c:out value="${activeLesson.title}"/>
                                </h1>
                                <div class="mt-1.5 flex items-center gap-3 font-mono text-[12px] text-ink-muted tabular-nums">
                                    <span>Thời lượng: ${activeLesson.formattedDuration}</span>
                                    <span>·</span>
                                    <span>GV. <c:out value="${course.instructorName}"/></span>
                                </div>
                            </div>

                            <button type="button" @click="toggleComplete()" :disabled="savingProgress"
                                    :class="completed
                                        ? 'bg-emerald-ok border-emerald-ok text-white hover:bg-[#166534]'
                                        : 'bg-sheet border-ink text-ink hover:bg-paper-tab'"
                                    class="shrink-0 inline-flex items-center gap-2 px-4 py-2.5 rounded-md border-[1.5px] font-bold text-[13.5px] transition-colors">
                                <i data-lucide="check-circle-2" class="w-4 h-4"></i>
                                <span x-text="completed ? 'Đã hoàn thành' : 'Đánh dấu hoàn thành'"></span>
                            </button>
                        </div>

                        <!-- Workspace Tabs -->
                        <div class="flex items-center gap-2 border-b-[1.5px] border-ink">
                            <button type="button" @click="activeTab = 'overview'"
                                    :class="activeTab === 'overview' ? 'bg-sheet text-ink border-ink -mb-[1.5px]' : 'bg-paper-tab text-ink-muted border-transparent'"
                                    class="px-4 py-2.5 text-[13.5px] font-extrabold rounded-t-md border-[1.5px] border-b-0">
                                Nội dung bài học
                            </button>
                            <button type="button" @click="activeTab = 'notes'"
                                    :class="activeTab === 'notes' ? 'bg-sheet text-ink border-ink -mb-[1.5px]' : 'bg-paper-tab text-ink-muted border-transparent'"
                                    class="px-4 py-2.5 text-[13.5px] font-extrabold rounded-t-md border-[1.5px] border-b-0 inline-flex items-center gap-1.5">
                                <span>Ghi chú theo mốc</span>
                                <span class="font-mono text-[11px] px-1.5 py-0.5 rounded bg-blueprint-soft text-blueprint tabular-nums" x-text="notes.length"></span>
                            </button>
                        </div>

                        <!-- Tab 1: Overview -->
                        <div x-show="activeTab === 'overview'" class="binder-sheet rounded-lg p-6 space-y-4">
                            <p class="text-[15px] text-ink leading-relaxed max-w-[70ch]">
                                <c:out value="${not empty activeLesson.contentText ? activeLesson.contentText : 'Theo dõi kỹ video hướng dẫn và ghi chú lại các mốc quan trọng để dễ ôn tập.'}"/>
                            </p>
                            <div class="pt-4 border-t border-rule flex flex-wrap items-center justify-between gap-3 text-[13px] text-ink-muted">
                                <span>Cần giải thích thêm về bài học? Mở <strong class="text-ink">Trợ lý AI</strong> ở góc dưới phải để đặt câu hỏi trực tiếp.</span>
                            </div>
                        </div>

                        <!-- Tab 2: F8-style Timestamp Notes -->
                        <div x-show="activeTab === 'notes'" x-cloak class="space-y-5">
                            <form @submit.prevent="addNote()" class="binder-sheet rounded-lg p-5 space-y-3">
                                <div class="flex flex-wrap items-center justify-between gap-2">
                                    <label class="font-bold text-[14px] text-ink">Thêm ghi chú theo mốc thời gian video</label>
                                    <div class="flex items-center gap-1.5 font-mono text-[13px]">
                                        <span class="text-ink-muted">Mốc:</span>
                                        <input type="number" min="0" max="180" x-model="noteMin" aria-label="Phút"
                                               class="w-16 h-8 px-2 text-center border-[1.5px] border-ink rounded bg-paper-soft font-bold tabular-nums">
                                        <span class="font-bold">:</span>
                                        <input type="number" min="0" max="59" x-model="noteSec" aria-label="Giây"
                                               class="w-16 h-8 px-2 text-center border-[1.5px] border-ink rounded bg-paper-soft font-bold tabular-nums">
                                    </div>
                                </div>
                                <textarea x-model="noteText" rows="3" required
                                          placeholder="Ghi lại ý chính, câu lệnh hoặc lưu ý cần nhớ tại mốc video này..."
                                          class="lab-input text-[14px]"></textarea>
                                <div class="flex justify-end">
                                    <button type="submit" :disabled="savingNote || !noteText.trim()"
                                            class="btn-blueprint px-4 py-2 text-[13.5px] disabled:opacity-50">
                                        <i data-lucide="plus" class="w-4 h-4"></i>
                                        <span x-text="savingNote ? 'Đang lưu...' : 'Lưu ghi chú'"></span>
                                    </button>
                                </div>
                            </form>

                            <template x-if="notes.length === 0">
                                <div class="p-8 text-center bg-sheet border border-rule rounded-lg text-[14px] text-ink-muted">
                                    Chưa có ghi chú nào cho bài học này. Hãy nhập mốc phút:giây phía trên để lưu lại kiến thức quan trọng.
                                </div>
                            </template>

                            <div class="space-y-3">
                                <template x-for="n in notes" :key="n.id">
                                    <div class="bg-sheet border-[1.5px] border-ink rounded-lg p-4 flex items-start justify-between gap-3">
                                        <div class="space-y-1.5 min-w-0">
                                            <button type="button" @click="seekTo(n.timestampSeconds)"
                                                    class="inline-flex items-center gap-1 font-mono text-[12px] font-bold px-2.5 py-0.5 rounded bg-blueprint-soft text-blueprint hover:bg-blueprint hover:text-white transition-colors tabular-nums">
                                                <i data-lucide="play" class="w-3 h-3"></i>
                                                <span x-text="n.formattedTimestamp"></span>
                                            </button>
                                            <p class="text-[14px] text-ink leading-relaxed break-words" x-text="n.noteText"></p>
                                        </div>
                                        <button type="button" @click="deleteNote(n.id)" title="Xóa ghi chú"
                                                class="p-1.5 text-ink-muted hover:text-danger shrink-0">
                                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                                        </button>
                                    </div>
                                </template>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Right Collapsible Syllabus Sidebar -->
        <aside x-show="sidebarOpen" x-cloak
               class="w-[340px] max-w-[85vw] bg-sheet border-l-[1.5px] border-ink flex flex-col shrink-0 overflow-hidden absolute lg:static inset-y-0 right-0 z-30 shadow-2xl lg:shadow-none">
            <div class="px-4 py-3.5 bg-paper-soft border-b border-rule flex items-center justify-between shrink-0">
                <h2 class="font-extrabold text-[14.5px] text-ink">Nội dung khóa học</h2>
                <button type="button" @click="sidebarOpen = false" class="lg:hidden p-1 text-ink-muted hover:text-ink">
                    <i data-lucide="x" class="w-4 h-4"></i>
                </button>
            </div>
            <div class="flex-1 overflow-y-auto divide-y divide-rule pb-16">
                <c:forEach var="sec" items="${sections}">
                    <div x-data="{ open: true }">
                        <button type="button" @click="open = !open"
                                class="w-full px-4 py-3 bg-paper-soft hover:bg-paper-tab flex items-center justify-between gap-2 text-left">
                            <span class="font-bold text-[13px] text-ink leading-snug"><c:out value="${sec.title}"/></span>
                            <i data-lucide="chevron-down" class="w-4 h-4 text-ink-muted shrink-0 transition-transform" :class="open ? 'rotate-180' : ''"></i>
                        </button>
                        <ul x-show="open" class="divide-y divide-rule/60">
                            <c:forEach var="l" items="${sec.lessons}">
                                <c:set var="isCurr" value="${not empty activeLesson && activeLesson.id == l.id}"/>
                                <li>
                                    <a href="${pageContext.request.contextPath}/learn?courseId=${course.id}&lessonId=${l.id}"
                                       class="px-4 py-3 flex items-start gap-2.5 text-[13px] transition-colors ${isCurr ? 'bg-blueprint-soft/70 font-bold text-blueprint' : 'hover:bg-paper-soft text-ink'}">
                                        <span data-lesson-check="${l.id}"
                                              class="w-4 h-4 mt-0.5 rounded-full border grid place-items-center shrink-0 ${l.completed ? 'bg-emerald-ok border-emerald-ok text-white' : 'border-ink-subtle text-transparent'}">
                                            <i data-lucide="check" class="w-2.5 h-2.5"></i>
                                        </span>
                                        <div class="min-w-0 flex-1">
                                            <div class="leading-snug"><c:out value="${l.title}"/></div>
                                            <div class="font-mono text-[11px] text-ink-muted mt-0.5 tabular-nums">${l.formattedDuration}</div>
                                        </div>
                                    </a>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:forEach>
            </div>
        </aside>
    </div>

    <!-- F8-style Sticky Bottom Lesson Navigation Bar -->
    <footer class="h-14 bg-paper-soft border-t-[1.5px] border-ink px-4 flex items-center justify-center gap-3 shrink-0 z-20">
        <c:choose>
            <c:when test="${not empty prevLesson}">
                <a href="${pageContext.request.contextPath}/learn?courseId=${course.id}&lessonId=${prevLesson.id}"
                   class="btn-outline-ink px-4 py-2 text-[13px]">
                    <i data-lucide="arrow-left" class="w-4 h-4"></i>
                    <span>Bài trước</span>
                </a>
            </c:when>
            <c:otherwise>
                <span class="px-4 py-2 text-[13px] font-bold text-ink-subtle border border-rule rounded-[6px] opacity-60 cursor-not-allowed inline-flex items-center gap-1.5">
                    <i data-lucide="arrow-left" class="w-4 h-4"></i>
                    <span>Bài trước</span>
                </span>
            </c:otherwise>
        </c:choose>

        <c:choose>
            <c:when test="${not empty nextLesson}">
                <a href="${pageContext.request.contextPath}/learn?courseId=${course.id}&lessonId=${nextLesson.id}"
                   class="btn-blueprint px-4 py-2 text-[13px]">
                    <span>Bài tiếp theo</span>
                    <i data-lucide="arrow-right" class="w-4 h-4"></i>
                </a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/course?slug=${course.slug}#reviews"
                   class="btn-pro px-4 py-2 text-[13px]">
                    <i data-lucide="award" class="w-4 h-4"></i>
                    <span>Hoàn thành &amp; Đánh giá</span>
                </a>
            </c:otherwise>
        </c:choose>
    </footer>
</div>

<jsp:include page="/inc/chat-widget.jsp"/>
</body>
</html>
