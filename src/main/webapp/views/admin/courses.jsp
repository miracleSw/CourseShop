<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="bodyClass" value="bg-paper text-ink antialiased min-h-screen flex flex-col lg:flex-row" scope="request"/>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/admin-sidebar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 p-5 sm:p-8 lg:p-10 min-w-0 space-y-8">
    <div class="flex flex-wrap items-end justify-between gap-4 pb-4 border-b-[1.5px] border-ink">
        <div>
            <h1 class="text-[26px] sm:text-[32px] font-extrabold tracking-tight text-ink">Quản lý Khóa học</h1>
            <p class="text-[14px] text-ink-muted mt-1">Tạo mới, chỉnh sửa học phí, upload ảnh bìa và biên tập chương/bài học.</p>
        </div>
        <c:if test="${not empty editCourse}">
            <a href="${pageContext.request.contextPath}/admin/courses" class="btn-outline-ink px-4 py-2 text-[13px]">
                + Tạo khóa học mới
            </a>
        </c:if>
    </div>

    <!-- Course Create / Edit Form -->
    <section class="binder-sheet rounded-xl p-6">
        <h2 class="text-[18px] font-extrabold text-ink mb-5">
            ${not empty editCourse ? 'Chỉnh sửa khóa học: '.concat(editCourse.code) : 'Thêm khóa học mới'}
        </h2>
        <form action="${pageContext.request.contextPath}/admin/courses" method="post" enctype="multipart/form-data"
              class="grid grid-cols-1 md:grid-cols-12 gap-4">
            <input type="hidden" name="id" value="${not empty editCourse ? editCourse.id : 0}">

            <div class="md:col-span-3">
                <label class="block text-[13px] font-bold mb-1">Mã học phần</label>
                <input type="text" name="code" required value="<c:out value='${editCourse.code}'/>"
                       placeholder="PRO-09 hoặc LAB-05" class="lab-input font-mono uppercase">
            </div>
            <div class="md:col-span-6">
                <label class="block text-[13px] font-bold mb-1">Tên khóa học</label>
                <input type="text" name="title" required value="<c:out value='${editCourse.title}'/>"
                       placeholder="VD: Java Web & Thanh toán Stripe" class="lab-input">
            </div>
            <div class="md:col-span-3">
                <label class="block text-[13px] font-bold mb-1">Danh mục</label>
                <select name="categoryId" class="lab-input">
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.id}" ${not empty editCourse && editCourse.categoryId == cat.id ? 'selected' : ''}>
                            <c:out value="${cat.name}"/>
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="md:col-span-4">
                <label class="block text-[13px] font-bold mb-1">Giảng viên</label>
                <input type="text" name="instructorName" required value="<c:out value='${not empty editCourse ? editCourse.instructorName : "KS. Nguyễn Hoàng Nam"}'/>"
                       class="lab-input">
            </div>
            <div class="md:col-span-2">
                <label class="block text-[13px] font-bold mb-1">Loại khóa</label>
                <select name="isPro" class="lab-input">
                    <option value="1" ${empty editCourse || editCourse.pro ? 'selected' : ''}>Khóa Pro</option>
                    <option value="0" ${not empty editCourse && !editCourse.pro ? 'selected' : ''}>Miễn phí (0đ)</option>
                </select>
            </div>
            <div class="md:col-span-3">
                <label class="block text-[13px] font-bold mb-1">Giá gốc (VNĐ)</label>
                <input type="number" name="price" min="0" step="1000" value="${not empty editCourse ? editCourse.price : 1290000}"
                       class="lab-input font-mono tabular-nums">
            </div>
            <div class="md:col-span-3">
                <label class="block text-[13px] font-bold mb-1">Giá ưu đãi (để trống nếu không)</label>
                <input type="number" name="salePrice" min="0" step="1000" value="${not empty editCourse && not empty editCourse.salePrice ? editCourse.salePrice : ''}"
                       class="lab-input font-mono tabular-nums">
            </div>

            <div class="md:col-span-3">
                <label class="block text-[13px] font-bold mb-1">Trình độ</label>
                <select name="level" class="lab-input">
                    <option value="BEGINNER" ${editCourse.level == 'BEGINNER' ? 'selected' : ''}>Người mới</option>
                    <option value="INTERMEDIATE" ${editCourse.level == 'INTERMEDIATE' ? 'selected' : ''}>Trung cấp</option>
                    <option value="ADVANCED" ${editCourse.level == 'ADVANCED' ? 'selected' : ''}>Đi làm / Nâng cao</option>
                </select>
            </div>
            <div class="md:col-span-2">
                <label class="block text-[13px] font-bold mb-1">Trạng thái</label>
                <select name="status" class="lab-input">
                    <option value="PUBLISHED" ${empty editCourse || editCourse.status == 'PUBLISHED' ? 'selected' : ''}>Đang mở</option>
                    <option value="DRAFT" ${editCourse.status == 'DRAFT' ? 'selected' : ''}>Bản nháp</option>
                    <option value="HIDDEN" ${editCourse.status == 'HIDDEN' ? 'selected' : ''}>Tạm ẩn</option>
                </select>
            </div>
            <div class="md:col-span-2">
                <label class="block text-[13px] font-bold mb-1">Thứ tự ưu tiên</label>
                <input type="number" name="featuredOrder" min="1" max="999"
                       value="${not empty editCourse ? editCourse.featuredOrder : 100}"
                       class="lab-input font-mono tabular-nums">
            </div>
            <div class="md:col-span-2">
                <label class="block text-[13px] font-bold mb-1">Upload ảnh bìa</label>
                <input type="file" name="thumbnailFile" accept=".png,.jpg,.jpeg,.webp"
                       class="w-full text-[13px] file:mr-2 file:py-1.5 file:px-2.5 file:rounded file:border file:border-ink file:bg-paper-soft file:font-bold">
            </div>
            <div class="md:col-span-3">
                <label class="block text-[13px] font-bold mb-1">Hoặc đường dẫn ảnh</label>
                <input type="text" name="thumbnail" value="<c:out value='${editCourse.thumbnail}'/>"
                       placeholder="assets/images/courses/pro-01.png" class="lab-input font-mono text-[13px]">
            </div>

            <div class="md:col-span-6">
                <label class="block text-[13px] font-bold mb-1">Mô tả ngắn (hiển thị trên thẻ)</label>
                <input type="text" name="shortDesc" required value="<c:out value='${editCourse.shortDesc}'/>" class="lab-input">
            </div>
            <div class="md:col-span-6">
                <label class="block text-[13px] font-bold mb-1">Stripe Product ID (tùy chọn)</label>
                <input type="text" name="stripeProductId" value="<c:out value='${editCourse.stripeProductId}'/>"
                       placeholder="prod_..." class="lab-input font-mono text-[13px]">
            </div>
            <div class="md:col-span-6">
                <label class="block text-[13px] font-bold mb-1">Mô tả chi tiết</label>
                <textarea name="description" rows="3" required class="lab-input"><c:out value="${editCourse.description}"/></textarea>
            </div>
            <div class="md:col-span-6">
                <label class="block text-[13px] font-bold mb-1">Kết quả đạt được (mỗi dòng 1 ý)</label>
                <textarea name="outcomes" rows="3" class="lab-input"><c:out value="${editCourse.outcomesRaw}"/></textarea>
            </div>

            <div class="md:col-span-12 flex justify-end gap-2.5 pt-2">
                <c:if test="${not empty editCourse}">
                    <a href="${pageContext.request.contextPath}/admin/courses" class="btn-outline-ink px-4 py-2 text-[13.5px]">Hủy sửa</a>
                </c:if>
                <button type="submit" class="btn-blueprint px-5 py-2.5 text-[14px]">
                    <i data-lucide="save" class="w-4 h-4"></i>
                    <span>${not empty editCourse ? 'Lưu thay đổi' : 'Tạo khóa học'}</span>
                </button>
            </div>
        </form>
    </section>

    <!-- Courses Table -->
    <section class="binder-sheet rounded-xl overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-[13.5px] border-collapse">
                <thead>
                    <tr class="bg-paper-soft border-b border-ink font-mono text-[11.5px] uppercase text-ink-muted">
                        <th class="px-4 py-3.5">Mã</th>
                        <th class="px-4 py-3.5">Khóa học</th>
                        <th class="px-4 py-3.5">Học phí</th>
                        <th class="px-4 py-3.5">Bài / HV</th>
                        <th class="px-4 py-3.5">Trạng thái</th>
                        <th class="px-4 py-3.5 text-right">Thao tác</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-rule">
                    <c:forEach var="c" items="${courses}">
                        <tr class="hover:bg-paper-soft/60">
                            <td class="px-4 py-3.5 font-mono font-bold ${c.pro ? 'text-amber-pro' : 'text-blueprint'}">${c.code}</td>
                            <td class="px-4 py-3.5">
                                <div class="font-bold text-ink"><c:out value="${c.title}"/></div>
                                <div class="text-[12px] text-ink-muted">
                                    <c:out value="${c.categoryName}"/> · <c:out value="${c.instructorName}"/>
                                    <c:if test="${not empty c.stripeProductId}">
                                        · <span class="font-mono text-[11px] text-blueprint"><c:out value="${c.stripeProductId}"/></span>
                                    </c:if>
                                </div>
                            </td>
                            <td class="px-4 py-3.5 font-mono font-bold tabular-nums">${c.formattedEffectivePrice}</td>
                            <td class="px-4 py-3.5 font-mono text-[12.5px] text-ink-muted tabular-nums">${c.lessonCount} bài · ${c.studentCount} HV</td>
                            <td class="px-4 py-3.5">
                                <span class="text-[11.5px] font-bold px-2 py-0.5 rounded ${c.status == 'PUBLISHED' ? 'bg-emerald-soft text-emerald-ok' : 'bg-paper border border-rule text-ink-muted'}">
                                    ${c.status == 'PUBLISHED' ? 'Đang mở' : (c.status == 'DRAFT' ? 'Bản nháp' : 'Tạm ẩn')}
                                </span>
                            </td>
                            <td class="px-4 py-3.5 text-right whitespace-nowrap space-x-2">
                                <a href="${pageContext.request.contextPath}/admin/curriculum?courseId=${c.id}"
                                   class="inline-flex items-center gap-1 px-2.5 py-1 rounded bg-blueprint-soft text-blueprint font-bold text-[12px] hover:underline">
                                    Giáo trình
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/courses?edit=${c.id}"
                                   class="inline-flex items-center gap-1 px-2.5 py-1 rounded border border-rule bg-sheet font-bold text-[12px] text-ink hover:border-ink">
                                    Sửa
                                </a>
                                <form action="${pageContext.request.contextPath}/admin/courses" method="post" class="inline"
                                      onsubmit="return confirm('Xác nhận xóa khóa học ${c.code}?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${c.id}">
                                    <button type="submit" class="px-2 py-1 text-[12px] font-bold text-danger hover:underline">Xóa</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </section>
</main>
</body>
</html>
