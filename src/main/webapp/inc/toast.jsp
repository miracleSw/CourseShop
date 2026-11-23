<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="flashSuccess" value="${sessionScope.flashSuccess}"/>
<c:set var="flashError" value="${sessionScope.flashError}"/>
<c:remove var="flashSuccess" scope="session"/>
<c:remove var="flashError" scope="session"/>

<div x-data="{
        toasts: [],
        add(type, message) {
            if (!message) return;
            const id = Date.now() + Math.random();
            this.toasts.push({ id, type, message });
            setTimeout(() => this.remove(id), 4200);
        },
        remove(id) {
            this.toasts = this.toasts.filter(t => t.id !== id);
        }
     }"
     x-init="
        const s = $el.dataset.flashSuccess;
        const e = $el.dataset.flashError;
        if (s) add('success', s);
        if (e) add('error', e);
     "
     @cs-toast.window="add($event.detail.type, $event.detail.message)"
     data-flash-success="<c:out value='${flashSuccess}'/>"
     data-flash-error="<c:out value='${flashError}'/>"
     class="fixed bottom-5 left-4 sm:left-5 z-50 flex flex-col gap-2.5 max-w-sm w-[calc(100vw-2rem)] sm:w-full pointer-events-none">
    <template x-for="t in toasts" :key="t.id">
        <div x-transition:enter="transition ease-out duration-200"
             x-transition:enter-start="opacity-0 translate-y-2"
             x-transition:enter-end="opacity-100 translate-y-0"
             x-transition:leave="transition ease-in duration-150"
             x-transition:leave-start="opacity-100"
             x-transition:leave-end="opacity-0"
             class="pointer-events-auto flex items-start gap-3 px-4 py-3 rounded-lg border-[1.5px] border-ink bg-sheet shadow-lg text-[13px]">
            <span class="w-2.5 h-2.5 rounded-full mt-1 shrink-0"
                  :class="t.type === 'error' ? 'bg-danger' : 'bg-emerald-ok'"></span>
            <p class="font-semibold text-ink flex-1 leading-snug" x-text="t.message"></p>
            <button type="button" @click="remove(t.id)" class="text-ink-muted hover:text-ink font-mono text-xs px-1" aria-label="Đóng thông báo">×</button>
        </div>
    </template>
</div>
