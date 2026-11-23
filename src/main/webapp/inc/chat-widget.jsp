<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<div x-data="aiChatWidget({
        contextPath: '${pageContext.request.contextPath}',
        courseId: ${not empty chatCourseId ? chatCourseId : 'null'},
        lessonId: ${not empty chatLessonId ? chatLessonId : 'null'}
     })"
     @keydown.escape.window="open = false"
     class="fixed bottom-4 sm:bottom-5 ${not empty chatCourseId ? 'right-3' : 'right-4 sm:right-5'} z-[9999] isolate"
     style="transform: translateZ(0);">

    <!-- Chat Drawer Panel -->
    <div x-show="open" x-cloak
         x-transition:enter="transition ease-out duration-200"
         x-transition:enter-start="opacity-0 translate-y-3 scale-95"
         x-transition:enter-end="opacity-100 translate-y-0 scale-100"
         x-transition:leave="transition ease-in duration-150"
         x-transition:leave-start="opacity-100 translate-y-0 scale-100"
         x-transition:leave-end="opacity-0 translate-y-3 scale-95"
         class="mb-3 ${not empty chatCourseId ? 'w-[322px]' : 'w-[360px] sm:w-[390px]'} max-w-[calc(100vw-1.5rem)] h-[520px] max-h-[78vh] flex flex-col bg-sheet border-[1.5px] border-ink rounded-xl shadow-2xl overflow-hidden">

        <!-- Header -->
        <div class="px-4 py-3 bg-ink text-paper-soft flex items-center justify-between gap-2 shrink-0">
            <div class="flex items-center gap-2.5 min-w-0">
                <span class="w-8 h-8 rounded-md bg-blueprint text-white grid place-items-center shrink-0">
                    <i data-lucide="sparkles" class="w-4 h-4"></i>
                </span>
                <div class="min-w-0">
                    <div class="font-bold text-[14px] leading-tight truncate">
                        <c:choose>
                            <c:when test="${not empty chatCourseId}">Trợ giảng AI · Bài học</c:when>
                            <c:otherwise>Trợ lý tư vấn học tập</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="text-[11.5px] text-[#C5CBD6] truncate" x-text="statusText"></div>
                </div>
            </div>
            <div class="flex items-center gap-1">
                <button type="button" @click="resetChat()" :disabled="loading" title="Làm mới cuộc trò chuyện"
                        class="p-1.5 rounded hover:bg-white/10 text-[#C5CBD6] hover:text-white transition-colors disabled:opacity-40">
                    <i data-lucide="rotate-ccw" class="w-4 h-4"></i>
                </button>
                <button type="button" @click="open = false" title="Thu gọn"
                        class="p-1.5 rounded hover:bg-white/10 text-[#C5CBD6] hover:text-white transition-colors">
                    <i data-lucide="x" class="w-4 h-4"></i>
                </button>
            </div>
        </div>

        <!-- Honest Unavailable Banner when AI service is not configured -->
        <div x-show="available === false" x-cloak
             class="px-3.5 py-2.5 bg-amber-soft border-b border-rule text-[12.5px] text-amber-ink font-semibold leading-snug">
            Trợ lý AI hiện đang tạm ngưng hoạt động. Vui lòng quay lại sau.
        </div>

        <!-- Messages -->
        <div x-ref="chatBody" class="flex-1 overflow-y-auto p-4 space-y-3 bg-paper-soft">
            <div x-show="loadingHistory" class="flex justify-center py-6">
                <span class="text-[12.5px] text-ink-muted font-medium">Đang tải cuộc trò chuyện...</span>
            </div>

            <template x-for="(msg, idx) in messages" :key="idx">
                <div class="flex" :class="msg.role === 'user' ? 'justify-end' : 'justify-start'">
                    <div class="max-w-[86%] rounded-lg px-3.5 py-2.5 text-[13.5px] leading-relaxed"
                         :class="msg.role === 'user'
                            ? 'bg-blueprint text-white font-medium'
                            : (msg.isError ? 'bg-danger-soft border border-danger/30 text-danger font-medium' : 'bg-sheet border border-rule text-ink')">
                        <div x-html="msg.html"></div>
                        <template x-if="msg.isError && lastFailedText">
                            <button type="button" @click="retryLast()" :disabled="loading"
                                    class="mt-2 inline-flex items-center gap-1 text-[12px] font-bold underline hover:text-ink disabled:opacity-50">
                                <i data-lucide="refresh-cw" class="w-3 h-3"></i>
                                <span>Thử gửi lại</span>
                            </button>
                        </template>
                    </div>
                </div>
            </template>

            <div x-show="loading" class="flex justify-start">
                <div class="bg-sheet border border-rule rounded-lg px-3.5 py-2.5 text-[13px] text-ink-muted inline-flex items-center gap-2">
                    <span class="w-2 h-2 rounded-full bg-blueprint animate-pulse"></span>
                    <span>Đang soạn câu trả lời...</span>
                </div>
            </div>
        </div>

        <!-- Quick Prompts (loaded dynamically from backend) -->
        <div x-show="quickPrompts.length > 0 && available !== false" x-cloak
             class="px-3 py-2 bg-sheet border-t border-rule flex flex-wrap gap-1.5 shrink-0">
            <template x-for="qp in quickPrompts" :key="qp">
                <button type="button" @click="send(qp)" :disabled="loading || available === false"
                        class="text-[11.5px] font-semibold px-2.5 py-1 rounded border border-rule bg-paper-soft hover:border-ink text-ink transition-colors text-left disabled:opacity-40 disabled:cursor-not-allowed"
                        x-text="qp"></button>
            </template>
        </div>

        <!-- Input Bar -->
        <form @submit.prevent="send()" class="p-3 bg-sheet border-t-[1.5px] border-ink flex gap-2 shrink-0">
            <input type="text" x-model="input" :disabled="loading || available === false"
                   :placeholder="available === false ? 'Trợ lý AI hiện tạm ngưng' : 'Nhập câu hỏi về khóa học hoặc bài giảng...'"
                   class="flex-1 h-10 px-3 text-[13.5px] bg-paper-soft border border-rule rounded-md text-ink placeholder:text-ink-subtle focus:outline-none focus:border-blueprint disabled:opacity-50 disabled:cursor-not-allowed">
            <button type="submit" :disabled="loading || available === false || !input.trim()"
                    class="btn-blueprint h-10 px-3.5 text-[13px] disabled:opacity-40 disabled:cursor-not-allowed" aria-label="Gửi câu hỏi">
                <i data-lucide="send" class="w-4 h-4"></i>
            </button>
        </form>
    </div>

    <!-- Floating Trigger Pill (icon-only on mobile to keep content unobstructed) -->
    <button type="button" @click="toggle()"
            :aria-label="open ? 'Thu gọn Trợ lý AI' : 'Mở Trợ lý AI'"
            class="ml-auto flex items-center justify-center sm:justify-start gap-2.5 w-11 h-11 sm:w-auto sm:h-12 sm:px-4 rounded-full border-[1.5px] border-ink bg-ink text-paper-soft font-bold text-[13.5px] shadow-xl hover:bg-[#262B35] transition-colors">
        <span class="w-6 h-6 rounded-full bg-blueprint text-white grid place-items-center shrink-0">
            <i data-lucide="sparkles" class="w-3.5 h-3.5"></i>
        </span>
        <span class="hidden sm:inline" x-text="open ? 'Thu gọn Trợ lý' : 'Hỏi Trợ lý AI'"></span>
    </button>
</div>
