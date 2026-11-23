<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/navbar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 max-w-[1360px] w-full mx-auto px-4 sm:px-6 lg:px-10 py-10">
    <div class="max-w-2xl mb-10">
        <h1 class="text-[32px] sm:text-[40px] font-extrabold tracking-tight text-ink leading-tight">
            Lộ trình học lập trình theo mục tiêu nghề nghiệp
        </h1>
        <p class="text-[15px] text-ink-muted mt-3 leading-relaxed">
            Thay vì học rời rạc từng video, mỗi lộ trình sắp xếp sẵn các học phần từ nền tảng Miễn phí (0đ) đến dự án Pro thực chiến để bạn đi thẳng tới mục tiêu đi làm.
        </p>
    </div>

    <div class="space-y-8">
        <c:forEach var="lp" items="${learningPaths}">
            <section id="${lp.slug}" class="binder-sheet rounded-xl overflow-hidden">
                <div class="px-6 sm:px-8 py-5 bg-paper-soft border-b-[1.5px] border-ink flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                    <div>
                        <h2 class="text-[22px] font-extrabold text-ink">
                            <span class="font-mono text-blueprint mr-2">${lp.code}.</span>
                            <c:out value="${lp.title}"/>
                        </h2>
                        <p class="text-[14px] text-ink-muted mt-1 max-w-3xl"><c:out value="${lp.summary}"/></p>
                    </div>
                    <div class="shrink-0 font-mono text-[12px] font-bold px-3 py-1.5 rounded border border-ink bg-sheet text-ink">
                        <c:out value="${lp.targetRole}"/> · ${lp.courses.size()} học phần
                    </div>
                </div>

                <div class="p-6 sm:p-8">
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
                        <c:forEach var="c" items="${lp.courses}" varStatus="st">
                            <div class="border-[1.5px] border-ink rounded-lg bg-sheet flex flex-col overflow-hidden">
                                <div class="h-1.5 ${c.pro ? 'bg-amber-bar' : 'bg-blueprint'}"></div>
                                <div class="p-4 flex-1 flex flex-col">
                                    <div class="flex items-center justify-between font-mono text-[11px] font-bold mb-2">
                                        <span class="px-2 py-0.5 rounded bg-paper border border-rule text-ink">BƯỚC 0${st.count}</span>
                                        <span class="${c.pro ? 'text-amber-pro' : 'text-blueprint'}">${c.code}</span>
                                    </div>
                                    <h3 class="text-[15px] font-extrabold text-ink leading-snug mb-2">
                                        <a href="${pageContext.request.contextPath}/course?slug=${c.slug}" class="hover:text-blueprint hover:underline">
                                            <c:out value="${c.title}"/>
                                        </a>
                                    </h3>
                                    <p class="text-[12.5px] text-ink-muted line-clamp-2 mb-4"><c:out value="${c.shortDesc}"/></p>

                                    <div class="mt-auto pt-3 border-t border-rule flex items-center justify-between">
                                        <span class="font-mono text-[13.5px] font-bold tabular-nums ${c.free ? 'text-blueprint' : 'text-ink'}">
                                            ${c.formattedEffectivePrice}
                                        </span>
                                        <c:choose>
                                            <c:when test="${ownedIds.contains(c.id)}">
                                                <a href="${pageContext.request.contextPath}/learn?courseId=${c.id}"
                                                   class="text-[12.5px] font-bold text-emerald-ok hover:underline inline-flex items-center gap-1">
                                                    <span>Vào học</span>
                                                    <i data-lucide="arrow-right" class="w-3.5 h-3.5"></i>
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/course?slug=${c.slug}"
                                                   class="text-[12.5px] font-bold text-blueprint hover:underline inline-flex items-center gap-1">
                                                    <span>Xem chi tiết</span>
                                                    <i data-lucide="arrow-right" class="w-3.5 h-3.5"></i>
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </section>
        </c:forEach>
    </div>
</main>

<jsp:include page="/inc/footer.jsp"/>
<jsp:include page="/inc/chat-widget.jsp"/>
</body>
</html>
