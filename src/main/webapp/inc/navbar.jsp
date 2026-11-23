<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="cartSize" value="${not empty globalCartCount ? globalCartCount : (not empty sessionScope.cart ? fn:length(sessionScope.cart) : 0)}"/>

<header x-data="{ mobileOpen: false, userMenu: false }"
        @keydown.escape.window="mobileOpen = false; userMenu = false"
        class="sticky top-0 z-40 bg-paper-soft border-b-[1.5px] border-ink">
    <div class="max-w-[1360px] mx-auto px-3 sm:px-6 lg:px-10 h-[66px] flex items-center justify-between gap-2 sm:gap-4">
        <!-- Brand with Blueprint Spine Tab -->
        <a href="${pageContext.request.contextPath}/home"
           class="flex items-center gap-2 sm:gap-2.5 shrink-0 group">
            <span class="w-2.5 sm:w-3 h-6 sm:h-7 rounded-[3px] bg-blueprint block transition-transform duration-150 group-hover:scale-y-105" aria-hidden="true"></span>
            <span class="font-extrabold text-[17px] sm:text-[19px] tracking-tight text-ink">
                <c:out value="${not empty siteSettings['site.short_name'] ? siteSettings['site.short_name'] : 'CourseShop'}"/>
            </span>
        </a>

        <!-- Desktop Navigation -->
        <nav class="hidden lg:flex items-center gap-7 text-[14px] font-bold text-ink-muted" aria-label="Điều hướng chính">
            <a href="${pageContext.request.contextPath}/home"
               class="py-1 transition-colors hover:text-ink ${activeNav == 'home' ? 'text-ink underline decoration-2 underline-offset-8' : ''}">
                Giáo trình
            </a>
            <a href="${pageContext.request.contextPath}/paths"
               class="py-1 transition-colors hover:text-ink ${activeNav == 'paths' ? 'text-ink underline decoration-2 underline-offset-8' : ''}">
                Lộ trình
            </a>
            <a href="${pageContext.request.contextPath}/home?type=pro#catalog"
               class="py-1 transition-colors hover:text-ink ${filterType == 'pro' ? 'text-amber-pro underline decoration-2 underline-offset-8' : ''}">
                Khóa Pro
            </a>
            <a href="${pageContext.request.contextPath}/home?type=free#catalog"
               class="py-1 transition-colors hover:text-ink ${filterType == 'free' ? 'text-blueprint underline decoration-2 underline-offset-8' : ''}">
                Miễn phí
            </a>
            <c:if test="${not empty sessionScope.user}">
                <a href="${pageContext.request.contextPath}/my-courses"
                   class="py-1 transition-colors hover:text-ink ${activeNav == 'my-courses' ? 'text-ink underline decoration-2 underline-offset-8' : ''}">
                    Khóa của tôi
                </a>
            </c:if>
        </nav>

        <!-- Search + Cart + Auth -->
        <div class="flex items-center gap-1.5 sm:gap-3 shrink-0">
            <form action="${pageContext.request.contextPath}/home" method="get"
                  class="hidden md:flex items-center relative w-56 xl:w-64">
                <i data-lucide="search" class="w-4 h-4 text-ink-subtle absolute left-3 pointer-events-none"></i>
                <input type="search" name="q" value="<c:out value='${filterQ}'/>"
                       placeholder="Tìm Java, React, SQL..."
                       aria-label="Tìm kiếm khóa học"
                       class="w-full h-9 pl-9 pr-3 text-[13px] bg-sheet border-[1.5px] border-ink rounded-[5px] text-ink placeholder:text-ink-subtle focus:outline-none focus:border-blueprint">
            </form>

            <a href="${pageContext.request.contextPath}/cart"
               class="relative inline-flex items-center gap-1.5 h-9 px-2 sm:px-3 rounded-[5px] border-[1.5px] border-ink bg-sheet hover:bg-paper-tab text-[13px] font-bold text-ink transition-colors shrink-0"
               aria-label="Giỏ hàng">
                <i data-lucide="shopping-bag" class="w-4 h-4"></i>
                <span class="hidden sm:inline">Giỏ</span>
                <span data-cart-count
                      class="font-mono text-[11px] font-bold px-1.5 py-0.5 rounded bg-ink text-paper-soft tabular-nums ${cartSize == 0 ? 'hidden' : ''}">
                    ${cartSize}
                </span>
            </a>

            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <div class="relative" @click.outside="userMenu = false">
                        <button type="button" @click="userMenu = !userMenu"
                                class="inline-flex items-center gap-1.5 sm:gap-2 h-9 px-2 sm:px-3 rounded-[5px] border-[1.5px] border-ink bg-ink text-paper-soft text-[13px] font-bold hover:bg-[#2B2F3A] transition-colors">
                            <span class="w-5 h-5 rounded bg-blueprint text-white text-[11px] font-mono font-bold grid place-items-center">
                                <c:out value="${sessionScope.user.initials}"/>
                            </span>
                            <span class="hidden sm:inline max-w-[110px] truncate"><c:out value="${sessionScope.user.shortName}"/></span>
                            <i data-lucide="chevron-down" class="w-3.5 h-3.5"></i>
                        </button>

                        <div x-show="userMenu" x-cloak x-transition.opacity.duration.120ms
                             class="absolute right-0 mt-2 w-56 bg-sheet border-[1.5px] border-ink rounded-lg shadow-lg py-1.5 z-50">
                            <div class="px-3.5 py-2 border-b border-rule">
                                <div class="font-bold text-[13px] text-ink truncate"><c:out value="${sessionScope.user.fullName}"/></div>
                                <div class="font-mono text-[11px] text-ink-muted truncate"><c:out value="${sessionScope.user.email}"/></div>
                            </div>
                            <a href="${pageContext.request.contextPath}/my-courses"
                               class="flex items-center gap-2.5 px-3.5 py-2 text-[13px] font-semibold text-ink hover:bg-paper-soft">
                                <i data-lucide="book-open" class="w-4 h-4 text-blueprint"></i>
                                Khóa học của tôi
                            </a>
                            <a href="${pageContext.request.contextPath}/profile"
                               class="flex items-center gap-2.5 px-3.5 py-2 text-[13px] font-semibold text-ink hover:bg-paper-soft">
                                <i data-lucide="user-round" class="w-4 h-4 text-ink-muted"></i>
                                Hồ sơ cá nhân
                            </a>
                            <c:if test="${sessionScope.user.admin}">
                                <a href="${pageContext.request.contextPath}/admin/dashboard"
                                   class="flex items-center gap-2.5 px-3.5 py-2 text-[13px] font-semibold text-amber-pro hover:bg-amber-soft/50">
                                    <i data-lucide="shield-check" class="w-4 h-4"></i>
                                    Trang Quản trị
                                </a>
                            </c:if>
                            <div class="my-1 border-t border-rule"></div>
                            <form action="${pageContext.request.contextPath}/logout" method="post">
                                <button type="submit"
                                        class="w-full flex items-center gap-2.5 px-3.5 py-2 text-[13px] font-semibold text-danger hover:bg-danger-soft/60 text-left">
                                    <i data-lucide="log-out" class="w-4 h-4"></i>
                                    Đăng xuất
                                </button>
                            </form>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login"
                       class="btn-ink h-9 px-2.5 sm:px-4 text-[12.5px] sm:text-[13px] whitespace-nowrap shrink-0">
                        Đăng nhập
                    </a>
                </c:otherwise>
            </c:choose>

            <!-- Mobile menu button -->
            <button type="button" @click="mobileOpen = !mobileOpen"
                    :aria-expanded="mobileOpen"
                    class="lg:hidden inline-flex items-center justify-center w-9 h-9 rounded-[5px] border-[1.5px] border-ink bg-sheet text-ink shrink-0"
                    aria-label="Mở menu điều hướng">
                <i data-lucide="menu" class="w-4 h-4" x-show="!mobileOpen"></i>
                <i data-lucide="x" class="w-4 h-4" x-show="mobileOpen" x-cloak></i>
            </button>
        </div>
    </div>

    <!-- Mobile Navigation Drawer -->
    <div x-show="mobileOpen" x-cloak x-transition.opacity.duration.150ms
         @click.outside="mobileOpen = false"
         class="lg:hidden border-t-[1.5px] border-ink bg-paper-soft px-4 py-4 space-y-3 shadow-lg">
        <form action="${pageContext.request.contextPath}/home" method="get" class="flex gap-2">
            <input type="search" name="q" value="<c:out value='${filterQ}'/>"
                   placeholder="Tìm khóa học Java, React, SQL..."
                   class="lab-input h-10 text-sm">
            <button type="submit" class="btn-ink px-4 h-10 text-sm shrink-0">Tìm</button>
        </form>
        <div class="grid grid-cols-2 gap-2 text-[14px] font-bold">
            <a href="${pageContext.request.contextPath}/home" class="px-3 py-2 rounded border border-rule bg-sheet">Giáo trình</a>
            <a href="${pageContext.request.contextPath}/paths" class="px-3 py-2 rounded border border-rule bg-sheet">Lộ trình học</a>
            <a href="${pageContext.request.contextPath}/home?type=free#catalog" class="px-3 py-2 rounded border border-rule bg-sheet text-blueprint">Khóa Miễn phí</a>
            <a href="${pageContext.request.contextPath}/home?type=pro#catalog" class="px-3 py-2 rounded border border-rule bg-sheet text-amber-pro">Khóa Pro</a>
            <c:if test="${not empty sessionScope.user}">
                <a href="${pageContext.request.contextPath}/my-courses" class="px-3 py-2 rounded border border-rule bg-sheet">Khóa học của tôi</a>
                <a href="${pageContext.request.contextPath}/profile" class="px-3 py-2 rounded border border-rule bg-sheet">Hồ sơ cá nhân</a>
            </c:if>
        </div>
    </div>
</header>
