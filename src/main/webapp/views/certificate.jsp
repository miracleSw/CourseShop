<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<jsp:include page="/inc/head.jsp"/>
<div class="print:hidden"><jsp:include page="/inc/navbar.jsp"/></div>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 max-w-[1000px] w-full mx-auto px-4 sm:px-6 lg:px-10 py-10 space-y-8">
    <!-- Verification Lookup Bar (hidden when printing) -->
    <div class="print:hidden binder-sheet rounded-xl p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
            <h1 class="text-[20px] font-extrabold text-ink">Xác thực chứng chỉ hoàn thành</h1>
            <p class="text-[13px] text-ink-muted mt-0.5">Nhập mã chứng chỉ để kiểm tra tính hợp lệ trực tuyến.</p>
        </div>
        <form action="${pageContext.request.contextPath}/certificate" method="get" class="flex gap-2 sm:w-80">
            <input type="text" name="code" value="<c:out value='${lookupCode}'/>" required
                   placeholder="VD: CS-2026-XXXXXXXX" class="lab-input h-10 font-mono text-[13px] uppercase">
            <button type="submit" class="btn-ink px-4 h-10 text-[13px] shrink-0">Tra cứu</button>
        </form>
    </div>

    <c:choose>
        <c:when test="${not empty certificate}">
            <!-- Action Bar (hidden when printing) -->
            <div class="print:hidden flex flex-wrap items-center justify-between gap-3">
                <span class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-soft text-emerald-ok text-[13px] font-bold">
                    <i data-lucide="badge-check" class="w-4 h-4"></i>
                    <span>Chứng chỉ hợp lệ · Đã xác thực</span>
                </span>
                <div class="flex flex-wrap gap-2.5">
                    <button type="button" onclick="copyText('${verifyUrl}', 'liên kết xác thực chứng chỉ')"
                            class="btn-outline-ink px-4 py-2 text-[13px]">
                        <i data-lucide="link" class="w-4 h-4"></i>
                        <span>Sao chép liên kết</span>
                    </button>
                    <button type="button" onclick="window.print()"
                            class="btn-blueprint px-4 py-2 text-[13px]">
                        <i data-lucide="printer" class="w-4 h-4"></i>
                        <span>In / Lưu PDF</span>
                    </button>
                </div>
            </div>

            <!-- Printable Certificate Canvas -->
            <article class="bg-sheet border-[3px] border-ink rounded-xl p-6 sm:p-12 shadow-xl print:shadow-none print:border-[2px]">
                <div class="border border-dashed border-ink/40 rounded-lg p-6 sm:p-10 space-y-8 text-center">
                    <div class="flex items-center justify-center gap-2.5">
                        <span class="w-3 h-7 rounded-[3px] bg-blueprint block"></span>
                        <span class="font-extrabold text-[22px] tracking-tight text-ink">
                            <c:out value="${not empty siteSettings['site.name'] ? siteSettings['site.name'] : 'CourseShop'}"/>
                        </span>
                    </div>

                    <div class="space-y-2">
                        <div class="font-mono text-[12px] font-bold uppercase tracking-[0.22em] text-amber-pro">
                            CHỨNG CHỈ HOÀN THÀNH KHÓA HỌC
                        </div>
                        <p class="text-[14px] text-ink-muted">Trân trọng chứng nhận học viên</p>
                    </div>

                    <h2 class="text-[30px] sm:text-[42px] font-extrabold text-ink tracking-tight leading-tight">
                        <c:out value="${certificate.userName}"/>
                    </h2>

                    <div class="max-w-xl mx-auto space-y-2">
                        <p class="text-[14.5px] text-ink-muted">Đã hoàn thành xuất sắc 100% chương trình đào tạo và yêu cầu thực hành của khóa học</p>
                        <div class="text-[20px] sm:text-[24px] font-extrabold text-blueprint leading-snug pt-1">
                            <c:out value="${certificate.courseTitle}"/>
                        </div>
                        <div class="font-mono text-[12.5px] font-bold text-ink-muted">Mã học phần: ${certificate.courseCode}</div>
                    </div>

                    <div class="pt-8 mt-6 border-t border-rule grid grid-cols-1 sm:grid-cols-3 gap-6 text-[13px]">
                        <div>
                            <div class="text-ink-muted">Giảng viên phụ trách</div>
                            <div class="font-extrabold text-ink mt-1"><c:out value="${certificate.instructorName}"/></div>
                        </div>
                        <div>
                            <div class="text-ink-muted">Ngày cấp</div>
                            <div class="font-mono font-bold text-ink mt-1">
                                <fmt:formatDate value="${certificate.issuedAt}" pattern="dd/MM/yyyy"/>
                            </div>
                        </div>
                        <div>
                            <div class="text-ink-muted">Mã xác thực</div>
                            <div class="font-mono font-extrabold text-emerald-ok mt-1">${certificate.certificateCode}</div>
                        </div>
                    </div>
                </div>
            </article>
        </c:when>

        <c:when test="${not empty lookupCode}">
            <div class="binder-sheet rounded-xl p-10 text-center max-w-lg mx-auto">
                <div class="w-12 h-12 rounded-lg bg-danger-soft text-danger grid place-items-center mx-auto mb-3">
                    <i data-lucide="search-x" class="w-6 h-6"></i>
                </div>
                <h2 class="text-[19px] font-extrabold text-ink">Không tìm thấy chứng chỉ</h2>
                <p class="text-[14px] text-ink-muted mt-2">
                    Không có chứng chỉ nào khớp với mã <strong class="font-mono text-ink"><c:out value="${lookupCode}"/></strong>. Vui lòng kiểm tra lại ký tự.
                </p>
            </div>
        </c:when>

        <c:otherwise>
            <div class="binder-sheet rounded-xl p-10 text-center max-w-lg mx-auto">
                <div class="w-12 h-12 rounded-lg bg-blueprint-soft text-blueprint grid place-items-center mx-auto mb-3">
                    <i data-lucide="award" class="w-6 h-6"></i>
                </div>
                <h2 class="text-[19px] font-extrabold text-ink">Cổng tra cứu chứng chỉ trực tuyến</h2>
                <p class="text-[14px] text-ink-muted mt-2">
                    Nhập mã chứng chỉ định dạng <span class="font-mono font-bold text-ink">CS-2026-XXXXXXXX</span> vào ô phía trên để xác minh thông tin người sở hữu và khóa học đã hoàn thành.
                </p>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<div class="print:hidden"><jsp:include page="/inc/footer.jsp"/></div>
</body>
</html>
