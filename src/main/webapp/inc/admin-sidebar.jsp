<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<aside class="w-full lg:w-64 shrink-0 bg-paper-soft border-b-[1.5px] lg:border-b-0 lg:border-r-[1.5px] border-ink flex flex-col">
    <div class="px-5 h-[66px] border-b-[1.5px] border-ink flex items-center justify-between">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="flex items-center gap-2.5">
            <span class="w-3 h-6 rounded-[3px] bg-amber-bar block"></span>
            <span class="font-extrabold text-[17px] text-ink">CourseShop Admin</span>
        </a>
        <a href="${pageContext.request.contextPath}/home" title="Về trang học viên"
           class="text-ink-muted hover:text-ink p-1.5 rounded border border-rule bg-sheet">
            <i data-lucide="external-link" class="w-4 h-4"></i>
        </a>
    </div>

    <nav class="p-3.5 flex flex-row lg:flex-col gap-1.5 overflow-x-auto" aria-label="Điều hướng quản trị">
        <a href="${pageContext.request.contextPath}/admin/dashboard"
           class="shrink-0 flex items-center gap-2.5 px-3 py-2.5 rounded-md text-[13.5px] font-bold transition-colors ${adminNav == 'dashboard' ? 'bg-ink text-paper-soft' : 'text-ink-muted hover:bg-paper-tab hover:text-ink'}">
            <i data-lucide="bar-chart-3" class="w-4 h-4"></i>
            <span>Tổng quan</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/courses"
           class="shrink-0 flex items-center gap-2.5 px-3 py-2.5 rounded-md text-[13.5px] font-bold transition-colors ${adminNav == 'courses' ? 'bg-ink text-paper-soft' : 'text-ink-muted hover:bg-paper-tab hover:text-ink'}">
            <i data-lucide="book-open" class="w-4 h-4"></i>
            <span>Khóa học &amp; Giáo trình</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/categories"
           class="shrink-0 flex items-center gap-2.5 px-3 py-2.5 rounded-md text-[13.5px] font-bold transition-colors ${adminNav == 'categories' ? 'bg-ink text-paper-soft' : 'text-ink-muted hover:bg-paper-tab hover:text-ink'}">
            <i data-lucide="folder-kanban" class="w-4 h-4"></i>
            <span>Danh mục</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/paths"
           class="shrink-0 flex items-center gap-2.5 px-3 py-2.5 rounded-md text-[13.5px] font-bold transition-colors ${adminNav == 'paths' ? 'bg-ink text-paper-soft' : 'text-ink-muted hover:bg-paper-tab hover:text-ink'}">
            <i data-lucide="route" class="w-4 h-4"></i>
            <span>Lộ trình học</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/orders"
           class="shrink-0 flex items-center gap-2.5 px-3 py-2.5 rounded-md text-[13.5px] font-bold transition-colors ${adminNav == 'orders' ? 'bg-ink text-paper-soft' : 'text-ink-muted hover:bg-paper-tab hover:text-ink'}">
            <i data-lucide="receipt" class="w-4 h-4"></i>
            <span>Đơn hàng</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/coupons"
           class="shrink-0 flex items-center gap-2.5 px-3 py-2.5 rounded-md text-[13.5px] font-bold transition-colors ${adminNav == 'coupons' ? 'bg-ink text-paper-soft' : 'text-ink-muted hover:bg-paper-tab hover:text-ink'}">
            <i data-lucide="tag" class="w-4 h-4"></i>
            <span>Mã giảm giá</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/reviews"
           class="shrink-0 flex items-center gap-2.5 px-3 py-2.5 rounded-md text-[13.5px] font-bold transition-colors ${adminNav == 'reviews' ? 'bg-ink text-paper-soft' : 'text-ink-muted hover:bg-paper-tab hover:text-ink'}">
            <i data-lucide="message-square-quote" class="w-4 h-4"></i>
            <span>Đánh giá</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/users"
           class="shrink-0 flex items-center gap-2.5 px-3 py-2.5 rounded-md text-[13.5px] font-bold transition-colors ${adminNav == 'users' ? 'bg-ink text-paper-soft' : 'text-ink-muted hover:bg-paper-tab hover:text-ink'}">
            <i data-lucide="users" class="w-4 h-4"></i>
            <span>Người dùng</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/settings"
           class="shrink-0 flex items-center gap-2.5 px-3 py-2.5 rounded-md text-[13.5px] font-bold transition-colors ${adminNav == 'settings' ? 'bg-ink text-paper-soft' : 'text-ink-muted hover:bg-paper-tab hover:text-ink'}">
            <i data-lucide="sliders-horizontal" class="w-4 h-4"></i>
            <span>Cài đặt hệ thống</span>
        </a>
    </nav>

    <div class="hidden lg:block mt-auto p-4 border-t border-rule text-[12.5px] space-y-2">
        <div class="font-bold text-ink truncate"><c:out value="${sessionScope.user.fullName}"/></div>
        <div class="font-mono text-[11px] text-ink-muted truncate"><c:out value="${sessionScope.user.email}"/></div>
        <form action="${pageContext.request.contextPath}/logout" method="post" class="pt-1">
            <button type="submit" class="w-full btn-outline-ink py-1.5 text-[12.5px]">
                <i data-lucide="log-out" class="w-3.5 h-3.5"></i>
                Đăng xuất
            </button>
        </form>
    </div>
</aside>
