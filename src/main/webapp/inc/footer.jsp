<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<footer class="mt-auto border-t-[1.5px] border-ink bg-paper-soft">
    <div class="max-w-[1360px] mx-auto px-4 sm:px-6 lg:px-10 pt-12 pb-20 sm:pb-24">
        <div class="grid grid-cols-1 md:grid-cols-12 gap-8 pb-10 border-b border-rule">
            <div class="md:col-span-5 space-y-3">
                <a href="${pageContext.request.contextPath}/home" class="inline-flex items-center gap-2.5">
                    <span class="w-3 h-6 rounded-[3px] bg-blueprint block"></span>
                    <span class="font-extrabold text-[18px] text-ink">
                        <c:out value="${not empty siteSettings['site.name'] ? siteSettings['site.name'] : 'CourseShop'}"/>
                    </span>
                </a>
                <p class="text-[14px] text-ink-muted leading-relaxed max-w-md">
                    <c:out value="${siteSettings['site.tagline']}"/>
                </p>
            </div>

            <div class="md:col-span-2 space-y-2.5">
                <h3 class="font-bold text-[14px] text-ink">Lộ trình</h3>
                <ul class="space-y-2 text-[14px] text-ink-muted">
                    <c:forEach var="fp" items="${footerPaths}">
                        <li>
                            <a href="${pageContext.request.contextPath}/paths#${fp.slug}" class="hover:text-ink hover:underline">
                                <c:out value="${fp.title}"/>
                            </a>
                        </li>
                    </c:forEach>
                </ul>
            </div>

            <div class="md:col-span-2 space-y-2.5">
                <h3 class="font-bold text-[14px] text-ink">Học tập</h3>
                <ul class="space-y-2 text-[14px] text-ink-muted">
                    <li><a href="${pageContext.request.contextPath}/home?type=free#catalog" class="hover:text-ink hover:underline">Khóa Miễn phí</a></li>
                    <li><a href="${pageContext.request.contextPath}/home?type=pro#catalog" class="hover:text-ink hover:underline">Khóa học Pro</a></li>
                    <li><a href="${pageContext.request.contextPath}/my-courses" class="hover:text-ink hover:underline">Khóa học của tôi</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart" class="hover:text-ink hover:underline">Giỏ hàng</a></li>
                </ul>
            </div>

            <div class="md:col-span-3 space-y-2.5">
                <h3 class="font-bold text-[14px] text-ink">Liên hệ &amp; Ưu đãi</h3>
                <div class="text-[13px] text-ink-muted space-y-1.5 bg-sheet border border-rule rounded-md p-3">
                    <c:if test="${not empty siteSettings['site.support_email']}">
                        <div>Email: <span class="font-mono text-ink font-semibold"><c:out value="${siteSettings['site.support_email']}"/></span></div>
                    </c:if>
                    <c:if test="${not empty siteSettings['site.hotline']}">
                        <div>Hotline: <span class="font-mono text-ink font-semibold tabular-nums"><c:out value="${siteSettings['site.hotline']}"/></span></div>
                    </c:if>
                    <c:if test="${not empty activeCoupons}">
                        <div class="pt-1 border-t border-rule font-mono text-[12px]">
                            Ưu đãi:
                            <c:forEach var="cp" items="${activeCoupons}" varStatus="cst">
                                <span class="text-amber-pro font-bold"><c:out value="${cp.code}"/></span><c:if test="${!cst.last}"> · </c:if>
                            </c:forEach>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

        <div class="pt-6 flex flex-col sm:flex-row justify-between items-center gap-3 text-[13px] text-ink-muted">
            <p>© 2026 <c:out value="${not empty siteSettings['site.name'] ? siteSettings['site.name'] : 'CourseShop'}"/>. <c:out value="${siteSettings['site.address']}"/></p>
            <div class="flex items-center gap-4">
                <a href="${pageContext.request.contextPath}/paths" class="hover:text-ink hover:underline">Lộ trình học</a>
                <a href="${pageContext.request.contextPath}/my-courses" class="hover:text-ink hover:underline">Khóa học của tôi</a>
            </div>
        </div>
    </div>
</footer>
