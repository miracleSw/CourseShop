<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="includeLearnJs" value="true" scope="request"/>
<c:set var="bodyClass" value="bg-paper text-ink antialiased overflow-hidden" scope="request"/>
<c:set var="chatCourseId" value="${course.id}" scope="request"/>
<c:set var="chatLessonId" value="${not empty activeLesson ? activeLesson.id : 0}" scope="request"/>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

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
window.__LESSON_EXERCISE__ = ${not empty exerciseJson ? exerciseJson : 'null'};
window.__COURSE_QUIZZES__ = ${not empty quizzesJson ? quizzesJson : '[]'};
window.__LESSON_DISCUSSIONS__ = ${not empty discussionsJson ? discussionsJson : '[]'};
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
        certificateCode: '${not empty certificateCode ? certificateCode : ''}',
        initialNotes: window.__INITIAL_NOTES__,
        exercise: window.__LESSON_EXERCISE__,
        quizzes: window.__COURSE_QUIZZES__,
        discussions: window.__LESSON_DISCUSSIONS__
     })"
     @keydown.escape.window="if (window.innerWidth < 1024) sidebarOpen = false"
     class="h-screen flex flex-col">

    <!-- Dark Top Header -->
    <header class="h-14 bg-theatre text-[#F4F6F9] border-b border-theatre-border px-3 sm:px-4 flex items-center justify-between gap-2 sm:gap-4 shrink-0">
        <div class="flex items-center gap-2 sm:gap-3 min-w-0">
            <a href="${pageContext.request.contextPath}/my-courses"
               class="inline-flex items-center gap-1.5 px-2.5 py-1.5 rounded bg-theatre-panel border border-theatre-border hover:border-[#4A5568] text-[13px] font-semibold shrink-0">
                <i data-lucide="chevron-left" class="w-4 h-4"></i>
                <span class="hidden sm:inline">Khóa của tôi</span>
            </a>
            <div class="min-w-0">
                <div class="font-bold text-[14px] sm:text-[14.5px] truncate">
                    <span class="font-mono text-[#93C5FD] mr-1.5">${course.code}</span>
                    <c:out value="${course.title}"/>
                </div>
            </div>
        </div>

        <div class="flex items-center gap-2 sm:gap-3 shrink-0">
            <a x-show="certificateCode" x-cloak
               :href="contextPath + '/certificate/' + certificateCode"
               class="inline-flex items-center gap-1.5 px-2.5 py-1.5 rounded bg-amber-pro hover:bg-amber-pro-hover text-white text-[12px] font-bold shrink-0">
                <i data-lucide="award" class="w-3.5 h-3.5"></i>
                <span class="hidden sm:inline">Nhận chứng chỉ</span>
            </a>

            <span class="md:hidden font-mono text-[11.5px] font-bold text-[#86EFAC] tabular-nums" x-text="percent + '%'"></span>
            <div class="hidden md:flex items-center gap-2.5 font-mono text-[12px] tabular-nums">
                <div class="w-24 h-2 bg-theatre-panel rounded-full overflow-hidden border border-theatre-border">
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
        <!-- Main Video & Workspace Column -->
        <div class="flex-1 overflow-y-auto bg-paper pb-20">
            <c:choose>
                <c:when test="${empty activeLesson}">
                    <div class="p-12 text-center">
                        <h1 class="text-[22px] font-extrabold text-ink">Khóa học này chưa có bài giảng nào</h1>
                        <p class="text-[14px] text-ink-muted mt-2">Nội dung bài học sẽ sớm được cập nhật.</p>
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

                    <!-- Lesson Info + Complete Toggle + 4 Interactive Tabs -->
                    <div class="max-w-[1020px] mx-auto px-4 sm:px-8 py-6 space-y-6">
                        <div class="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
                            <div>
                                <h1 class="text-[22px] sm:text-[26px] font-extrabold text-ink leading-snug">
                                    <c:out value="${activeLesson.title}"/>
                                </h1>
                                <div class="mt-1.5 flex flex-wrap items-center gap-x-3 gap-y-1 font-mono text-[12px] text-ink-muted tabular-nums">
                                    <span>Thời lượng: ${activeLesson.formattedDuration}</span>
                                    <span>·</span>
                                    <span>GV. <c:out value="${course.instructorName}"/></span>
                                </div>
                            </div>

                            <button type="button" @click="toggleComplete()" :disabled="savingProgress"
                                    :class="completed
                                        ? 'bg-emerald-ok border-emerald-ok text-white hover:bg-[#166534]'
                                        : 'bg-sheet border-ink text-ink hover:bg-paper-tab'"
                                    class="shrink-0 inline-flex items-center gap-2 px-4 py-2.5 rounded-md border-[1.5px] font-bold text-[13.5px] transition-colors self-start">
                                <i data-lucide="check-circle-2" class="w-4 h-4"></i>
                                <span x-text="completed ? 'Đã hoàn thành' : 'Đánh dấu hoàn thành'"></span>
                            </button>
                        </div>

                        <!-- Workspace Tabs -->
                        <div class="flex items-center gap-1.5 sm:gap-2 border-b-[1.5px] border-ink overflow-x-auto no-scrollbar">
                            <button type="button" @click="activeTab = 'overview'"
                                    :class="activeTab === 'overview' ? 'bg-sheet text-ink border-ink -mb-[1.5px]' : 'bg-paper-tab text-ink-muted border-transparent'"
                                    class="shrink-0 px-3.5 sm:px-4 py-2.5 text-[13px] sm:text-[13.5px] font-extrabold rounded-t-md border-[1.5px] border-b-0">
                                Nội dung
                            </button>
                            <button type="button" @click="activeTab = 'practice'"
                                    :class="activeTab === 'practice' ? 'bg-sheet text-ink border-ink -mb-[1.5px]' : 'bg-paper-tab text-ink-muted border-transparent'"
                                    class="shrink-0 px-3.5 sm:px-4 py-2.5 text-[13px] sm:text-[13.5px] font-extrabold rounded-t-md border-[1.5px] border-b-0 inline-flex items-center gap-1.5">
                                <span>Thực hành &amp; Kiểm tra</span>
                                <span x-show="exercise || quizzes.length > 0"
                                      class="font-mono text-[11px] px-1.5 py-0.5 rounded bg-amber-soft text-amber-ink tabular-nums"
                                      x-text="(exercise ? 1 : 0) + quizzes.length"></span>
                            </button>
                            <button type="button" @click="activeTab = 'notes'"
                                    :class="activeTab === 'notes' ? 'bg-sheet text-ink border-ink -mb-[1.5px]' : 'bg-paper-tab text-ink-muted border-transparent'"
                                    class="shrink-0 px-3.5 sm:px-4 py-2.5 text-[13px] sm:text-[13.5px] font-extrabold rounded-t-md border-[1.5px] border-b-0 inline-flex items-center gap-1.5">
                                <span>Ghi chú</span>
                                <span class="font-mono text-[11px] px-1.5 py-0.5 rounded bg-blueprint-soft text-blueprint tabular-nums" x-text="notes.length"></span>
                            </button>
                            <button type="button" @click="activeTab = 'qa'"
                                    :class="activeTab === 'qa' ? 'bg-sheet text-ink border-ink -mb-[1.5px]' : 'bg-paper-tab text-ink-muted border-transparent'"
                                    class="shrink-0 px-3.5 sm:px-4 py-2.5 text-[13px] sm:text-[13.5px] font-extrabold rounded-t-md border-[1.5px] border-b-0 inline-flex items-center gap-1.5">
                                <span>Hỏi đáp</span>
                                <span class="font-mono text-[11px] px-1.5 py-0.5 rounded bg-paper border border-rule text-ink tabular-nums" x-text="discussions.length"></span>
                            </button>
                        </div>

                        <!-- Tab 1: Overview -->
                        <div x-show="activeTab === 'overview'" class="binder-sheet rounded-lg p-6 space-y-4">
                            <p class="text-[15px] text-ink leading-relaxed max-w-[70ch]">
                                <c:out value="${not empty activeLesson.contentText ? activeLesson.contentText : 'Theo dõi kỹ video hướng dẫn, làm bài tập thực hành và ghi chú lại các mốc quan trọng để dễ ôn tập.'}"/>
                            </p>
                            <div class="pt-4 border-t border-rule flex flex-wrap items-center justify-between gap-3 text-[13px] text-ink-muted">
                                <span>Cần giải thích thêm về bài học? Mở <strong class="text-ink">Trợ lý AI</strong> ở góc dưới phải hoặc đặt câu hỏi trong tab <strong class="text-ink">Hỏi đáp</strong>.</span>
                            </div>
                        </div>

                        <!-- Tab 2: Interactive Coding Practice + Multiple-Choice Quizzes -->
                        <div x-show="activeTab === 'practice'" x-cloak class="space-y-6">
                            <!-- Coding Exercise Section -->
                            <template x-if="exercise">
                                <section class="binder-sheet rounded-xl overflow-hidden">
                                    <div class="px-5 py-3.5 bg-paper-soft border-b-[1.5px] border-ink flex flex-wrap items-center justify-between gap-2">
                                        <div>
                                            <span class="font-mono text-[11px] font-bold px-2 py-0.5 rounded bg-blueprint-soft text-blueprint uppercase" x-text="'Bài tập viết mã · ' + exercise.language"></span>
                                            <h2 class="text-[17px] font-extrabold text-ink mt-1" x-text="exercise.title"></h2>
                                        </div>
                                        <span x-show="exercisePassed" class="font-mono text-[11.5px] font-bold px-2.5 py-1 rounded bg-emerald-soft text-emerald-ok">
                                            ĐÃ HOÀN THÀNH
                                        </span>
                                    </div>
                                    <div class="p-5 space-y-4">
                                        <p class="text-[14px] text-ink leading-relaxed" x-text="exercise.promptText"></p>

                                        <div class="space-y-2">
                                            <div class="flex items-center justify-between text-[12px] font-bold text-ink-muted">
                                                <span>Trình soạn mã của bạn</span>
                                                <button type="button" @click="resetStarterCode()" class="text-blueprint hover:underline">Khôi phục mã mẫu</button>
                                            </div>
                                            <textarea x-model="exerciseCode" rows="8" spellcheck="false"
                                                      class="w-full p-3.5 rounded-lg bg-theatre text-[#F4F6F9] font-mono text-[13px] leading-relaxed border-[1.5px] border-ink focus:outline-none focus:border-blueprint"></textarea>
                                        </div>

                                        <div class="flex flex-wrap items-center gap-2.5">
                                            <button type="button" @click="submitExercise()" :disabled="submittingCode"
                                                    class="btn-blueprint px-4 py-2 text-[13.5px] disabled:opacity-50">
                                                <i data-lucide="play" class="w-4 h-4"></i>
                                                <span x-text="submittingCode ? 'Đang kiểm tra...' : 'Kiểm tra lời giải'"></span>
                                            </button>
                                            <template x-if="exercise.language === 'html' || exercise.language === 'css' || exercise.language === 'javascript'">
                                                <button type="button" @click="runPreview()" class="btn-outline-ink px-4 py-2 text-[13.5px]">
                                                    Chạy thử kết quả
                                                </button>
                                            </template>
                                            <template x-if="exercise.hintText">
                                                <button type="button" @click="showHint = !showHint" class="text-[13px] font-bold text-blueprint hover:underline px-2">
                                                    <span x-text="showHint ? 'Ẩn gợi ý' : 'Xem gợi ý'"></span>
                                                </button>
                                            </template>
                                            <template x-if="exercise.solutionCode">
                                                <button type="button" @click="showSolution = !showSolution" class="text-[13px] font-bold text-amber-pro hover:underline px-2">
                                                    <span x-text="showSolution ? 'Ẩn đáp án mẫu' : 'Xem đáp án mẫu'"></span>
                                                </button>
                                            </template>
                                        </div>

                                        <template x-if="exerciseFeedback">
                                            <div class="p-3.5 rounded-lg border text-[13.5px] font-semibold"
                                                 :class="exercisePassed ? 'bg-emerald-soft border-emerald-ok/40 text-emerald-ok' : 'bg-danger-soft border-danger/30 text-danger'"
                                                 x-text="exerciseFeedback"></div>
                                        </template>

                                        <template x-if="showHint && exercise.hintText">
                                            <div class="p-3.5 rounded-lg bg-amber-soft/70 border border-rule text-[13px] text-amber-ink">
                                                <strong>Gợi ý:</strong> <span x-text="exercise.hintText"></span>
                                            </div>
                                        </template>

                                        <template x-if="showSolution && exercise.solutionCode">
                                            <pre class="p-3.5 rounded-lg bg-paper-soft border border-rule font-mono text-[12.5px] text-ink overflow-x-auto" x-text="exercise.solutionCode"></pre>
                                        </template>

                                        <!-- Sandboxed HTML/CSS Preview -->
                                        <template x-if="(exercise.language === 'html' || exercise.language === 'css') && previewSrcdoc">
                                            <div class="space-y-1.5">
                                                <div class="text-[12px] font-bold text-ink-muted">Khung xem trước trực tiếp</div>
                                                <iframe sandbox="allow-scripts" :srcdoc="previewSrcdoc" title="Kết quả xem trước"
                                                        class="w-full h-40 rounded-lg border-[1.5px] border-ink bg-white"></iframe>
                                            </div>
                                        </template>

                                        <!-- JavaScript Console Output -->
                                        <template x-if="exercise.language === 'javascript' && jsLogs.length > 0">
                                            <div class="p-3.5 rounded-lg bg-theatre text-[#86EFAC] font-mono text-[12.5px] space-y-1">
                                                <div class="text-[#A8B3C5] text-[11px] uppercase">Kết quả chạy thử</div>
                                                <template x-for="(line, li) in jsLogs" :key="li">
                                                    <div x-text="'> ' + line"></div>
                                                </template>
                                            </div>
                                        </template>
                                    </div>
                                </section>
                            </template>

                            <!-- Chapter & Course Multiple-Choice Quizzes -->
                            <template x-if="quizzes.length > 0">
                                <section class="binder-sheet rounded-xl overflow-hidden">
                                    <div class="px-5 py-3.5 bg-paper-soft border-b-[1.5px] border-ink flex flex-wrap items-center justify-between gap-3">
                                        <h2 class="text-[17px] font-extrabold text-ink">Bài kiểm tra trắc nghiệm</h2>
                                        <div class="flex flex-wrap gap-1.5">
                                            <template x-for="qz in quizzes" :key="qz.id">
                                                <button type="button" @click="selectedQuizId = qz.id"
                                                        :class="selectedQuizId === qz.id ? 'bg-ink text-paper-soft border-ink' : 'bg-sheet text-ink border-rule hover:border-ink'"
                                                        class="px-2.5 py-1 rounded border text-[12px] font-bold inline-flex items-center gap-1.5">
                                                    <span x-text="qz.title"></span>
                                                    <span x-show="qz.passed" class="text-emerald-ok">✓</span>
                                                </button>
                                            </template>
                                        </div>
                                    </div>

                                    <template x-if="activeQuiz">
                                        <div class="p-5 space-y-5">
                                            <div class="flex flex-wrap items-center justify-between gap-2 pb-3 border-b border-rule">
                                                <div>
                                                    <div class="font-extrabold text-[15.5px] text-ink" x-text="activeQuiz.title"></div>
                                                    <p class="text-[13px] text-ink-muted mt-0.5" x-text="activeQuiz.description"></p>
                                                </div>
                                                <div class="font-mono text-[12px] font-bold tabular-nums flex items-center gap-2">
                                                    <span class="px-2 py-0.5 rounded bg-paper border border-rule text-ink-muted" x-text="'Mức đạt: ' + activeQuiz.passScore + '%'"></span>
                                                    <template x-if="activeQuiz.bestScore !== null && activeQuiz.bestScore !== undefined">
                                                        <span class="px-2 py-0.5 rounded"
                                                              :class="activeQuiz.passed ? 'bg-emerald-soft text-emerald-ok' : 'bg-amber-soft text-amber-ink'"
                                                              x-text="'Cao nhất: ' + activeQuiz.bestScore + '%'"></span>
                                                    </template>
                                                </div>
                                            </div>

                                            <div class="space-y-4">
                                                <template x-for="(qq, qi) in activeQuiz.questions" :key="qq.id">
                                                    <div class="p-4 rounded-lg bg-paper-soft border border-rule space-y-3">
                                                        <div class="font-bold text-[14.5px] text-ink leading-snug">
                                                            <span class="font-mono text-blueprint mr-1.5" x-text="'Câu ' + (qi + 1) + '.'"></span>
                                                            <span x-text="qq.questionText"></span>
                                                        </div>
                                                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
                                                            <template x-for="opt in [
                                                                { key: 'A', val: qq.optionA },
                                                                { key: 'B', val: qq.optionB },
                                                                { key: 'C', val: qq.optionC },
                                                                { key: 'D', val: qq.optionD }
                                                            ]" :key="opt.key">
                                                                <button type="button"
                                                                        @click="selectAnswer(qq.id, opt.key)"
                                                                        :disabled="!!quizResults[activeQuiz.id]"
                                                                        :class="(() => {
                                                                            const fb = getQuestionFeedback(activeQuiz.id, qq.id);
                                                                            if (fb) {
                                                                                if (fb.correctOption === opt.key) return 'border-emerald-ok bg-emerald-soft text-ink font-bold';
                                                                                if (fb.chosen === opt.key && !fb.correct) return 'border-danger bg-danger-soft text-danger font-bold';
                                                                                return 'border-rule bg-sheet text-ink-muted opacity-75';
                                                                            }
                                                                            return quizAnswers[String(qq.id)] === opt.key
                                                                                ? 'border-blueprint bg-blueprint-soft text-ink font-bold'
                                                                                : 'border-rule bg-sheet text-ink hover:border-ink';
                                                                        })()"
                                                                        class="p-3 rounded-md border-[1.5px] text-left text-[13.5px] transition-colors flex items-start gap-2">
                                                                    <span class="font-mono font-bold text-[12px] px-1.5 py-0.5 rounded bg-paper border border-rule shrink-0" x-text="opt.key"></span>
                                                                    <span class="leading-snug" x-text="opt.val"></span>
                                                                </button>
                                                            </template>
                                                        </div>
                                                        <template x-if="getQuestionFeedback(activeQuiz.id, qq.id) && getQuestionFeedback(activeQuiz.id, qq.id).explanation">
                                                            <div class="text-[12.5px] p-2.5 rounded bg-sheet border border-rule text-ink-muted leading-relaxed">
                                                                <strong class="text-ink">Giải thích:</strong>
                                                                <span x-text="getQuestionFeedback(activeQuiz.id, qq.id).explanation"></span>
                                                            </div>
                                                        </template>
                                                    </div>
                                                </template>
                                            </div>

                                            <div class="flex flex-wrap items-center justify-between gap-3 pt-2">
                                                <template x-if="!quizResults[activeQuiz.id]">
                                                    <button type="button" @click="submitQuiz(activeQuiz.id)" :disabled="submittingQuiz"
                                                            class="btn-blueprint px-5 py-2.5 text-[14px] disabled:opacity-50">
                                                        <span x-text="submittingQuiz ? 'Đang chấm điểm...' : 'Nộp bài kiểm tra'"></span>
                                                    </button>
                                                </template>
                                                <template x-if="quizResults[activeQuiz.id]">
                                                    <div class="w-full flex flex-wrap items-center justify-between gap-3 p-4 rounded-lg border"
                                                         :class="quizResults[activeQuiz.id].passed ? 'bg-emerald-soft border-emerald-ok/40 text-emerald-ok' : 'bg-amber-soft border-amber-bar/40 text-amber-ink'">
                                                        <div class="font-bold text-[14px]">
                                                            Kết quả: <span class="font-mono" x-text="quizResults[activeQuiz.id].correctCount + '/' + quizResults[activeQuiz.id].totalQuestions + ' câu (' + quizResults[activeQuiz.id].scorePercent + '%)'"></span>
                                                            — <span x-text="quizResults[activeQuiz.id].passed ? 'Đạt yêu cầu' : 'Chưa đạt, hãy ôn tập và làm lại'"></span>
                                                        </div>
                                                        <button type="button" @click="retakeQuiz(activeQuiz.id)" class="btn-outline-ink px-3.5 py-1.5 text-[12.5px]">
                                                            Làm lại
                                                        </button>
                                                    </div>
                                                </template>
                                            </div>
                                        </div>
                                    </template>
                                </section>
                            </template>

                            <template x-if="!exercise && quizzes.length === 0">
                                <div class="binder-sheet rounded-lg p-8 text-center text-[14px] text-ink-muted">
                                    Bài học này chưa có bài tập thực hành hoặc trắc nghiệm đính kèm.
                                </div>
                            </template>
                        </div>

                        <!-- Tab 3: Timestamp Notes -->
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

                        <!-- Tab 4: Lesson Q&A Discussions -->
                        <div x-show="activeTab === 'qa'" x-cloak class="space-y-5">
                            <form @submit.prevent="postQuestion()" class="binder-sheet rounded-lg p-5 space-y-3">
                                <label class="block font-bold text-[14px] text-ink">Đặt câu hỏi thảo luận cho bài giảng này</label>
                                <textarea x-model="newQuestion" rows="3" required minlength="3"
                                          placeholder="Chia sẻ thắc mắc hoặc đoạn mã bạn đang gặp lỗi để giảng viên và các bạn học viên hỗ trợ..."
                                          class="lab-input text-[14px]"></textarea>
                                <div class="flex justify-end">
                                    <button type="submit" :disabled="postingDiscussion || newQuestion.trim().length < 3"
                                            class="btn-blueprint px-4 py-2 text-[13.5px] disabled:opacity-50">
                                        <span x-text="postingDiscussion ? 'Đang gửi...' : 'Đăng câu hỏi'"></span>
                                    </button>
                                </div>
                            </form>

                            <template x-if="discussions.length === 0">
                                <div class="p-8 text-center bg-sheet border border-rule rounded-lg text-[14px] text-ink-muted">
                                    Chưa có câu hỏi thảo luận nào ở bài học này. Hãy là người đầu tiên đặt câu hỏi!
                                </div>
                            </template>

                            <div class="space-y-4">
                                <template x-for="d in discussions" :key="d.id">
                                    <article class="bg-sheet border-[1.5px] border-ink rounded-lg p-4 sm:p-5 space-y-3">
                                        <div class="flex items-start justify-between gap-3">
                                            <div class="flex items-center gap-2.5 min-w-0">
                                                <span class="w-8 h-8 rounded-md font-mono text-[12px] font-bold grid place-items-center shrink-0"
                                                      :class="d.instructor ? 'bg-amber-pro text-white' : 'bg-blueprint-soft text-blueprint'"
                                                      x-text="d.userInitials"></span>
                                                <div class="min-w-0">
                                                    <div class="flex flex-wrap items-center gap-2">
                                                        <span class="font-bold text-[14px] text-ink" x-text="d.userName"></span>
                                                        <span x-show="d.instructor" class="font-mono text-[10.5px] font-bold px-2 py-0.5 rounded bg-amber-soft text-amber-ink">Giảng viên</span>
                                                    </div>
                                                    <div class="font-mono text-[11px] text-ink-muted" x-text="d.createdAt"></div>
                                                </div>
                                            </div>
                                            <div class="flex items-center gap-2 shrink-0">
                                                <button type="button" @click="replyingToId = (replyingToId === d.id ? null : d.id); replyText = ''"
                                                        class="text-[12px] font-bold text-blueprint hover:underline">Trả lời</button>
                                                <button type="button" x-show="d.canDelete" @click="deleteDiscussion(d.id, null)"
                                                        class="text-[12px] font-bold text-danger hover:underline">Xóa</button>
                                            </div>
                                        </div>

                                        <p class="text-[14px] text-ink leading-relaxed whitespace-pre-line break-words" x-text="d.content"></p>

                                        <!-- Replies -->
                                        <template x-if="d.replies && d.replies.length > 0">
                                            <div class="pl-4 sm:pl-6 border-l-2 border-rule space-y-3 pt-1">
                                                <template x-for="r in d.replies" :key="r.id">
                                                    <div class="p-3 rounded-lg bg-paper-soft border border-rule space-y-1.5">
                                                        <div class="flex items-center justify-between gap-2">
                                                            <div class="flex flex-wrap items-center gap-2">
                                                                <span class="font-bold text-[13px] text-ink" x-text="r.userName"></span>
                                                                <span x-show="r.instructor" class="font-mono text-[10px] font-bold px-1.5 py-0.5 rounded bg-amber-soft text-amber-ink">Giảng viên</span>
                                                                <span class="font-mono text-[11px] text-ink-muted" x-text="r.createdAt"></span>
                                                            </div>
                                                            <button type="button" x-show="r.canDelete" @click="deleteDiscussion(r.id, d.id)"
                                                                    class="text-[11.5px] font-bold text-danger hover:underline">Xóa</button>
                                                        </div>
                                                        <p class="text-[13.5px] text-ink leading-relaxed whitespace-pre-line break-words" x-text="r.content"></p>
                                                    </div>
                                                </template>
                                            </div>
                                        </template>

                                        <!-- Reply Input -->
                                        <template x-if="replyingToId === d.id">
                                            <form @submit.prevent="postReply(d.id)" class="pt-2 flex flex-col sm:flex-row gap-2">
                                                <input type="text" x-model="replyText" required minlength="3"
                                                       placeholder="Viết phản hồi của bạn..." class="lab-input h-10 text-[13.5px] flex-1">
                                                <div class="flex gap-2 shrink-0">
                                                    <button type="submit" :disabled="postingDiscussion" class="btn-blueprint px-4 h-10 text-[13px]">Gửi</button>
                                                    <button type="button" @click="replyingToId = null" class="btn-outline-ink px-3 h-10 text-[13px]">Hủy</button>
                                                </div>
                                            </form>
                                        </template>
                                    </article>
                                </template>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Mobile Drawer Backdrop -->
        <div x-show="sidebarOpen" x-cloak
             x-transition.opacity.duration.150ms
             @click="sidebarOpen = false"
             class="fixed inset-0 bg-ink/50 z-20 lg:hidden"
             aria-hidden="true"></div>

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

    <!-- Sticky Bottom Lesson Navigation Bar -->
    <footer class="h-14 bg-paper-soft border-t-[1.5px] border-ink pl-3 pr-16 sm:px-4 flex items-center justify-start sm:justify-center gap-2.5 sm:gap-3 shrink-0 z-20">
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
