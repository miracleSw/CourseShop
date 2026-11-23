<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="bodyClass" value="bg-paper text-ink antialiased min-h-screen flex flex-col lg:flex-row" scope="request"/>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/admin-sidebar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 p-5 sm:p-8 lg:p-10 min-w-0 space-y-8">
    <div class="pb-4 border-b-[1.5px] border-ink">
        <h1 class="text-[26px] sm:text-[32px] font-extrabold tracking-tight text-ink">Cài đặt hệ thống</h1>
        <p class="text-[14px] text-ink-muted mt-1">
            Quản lý kết nối Trợ lý AI, cổng thanh toán Stripe và thông tin hiển thị của nền tảng.
        </p>
    </div>

    <div class="grid grid-cols-1 xl:grid-cols-2 gap-8 items-start">
        <!-- Google Gemini AI Settings -->
        <section class="binder-sheet rounded-xl overflow-hidden">
            <div class="h-2 bg-blueprint"></div>
            <div class="p-6 sm:p-7 space-y-5">
                <div class="flex items-start justify-between gap-3">
                    <div>
                        <h2 class="text-[19px] font-extrabold text-ink">Trợ lý AI (Google Gemini)</h2>
                        <p class="text-[13px] text-ink-muted mt-0.5">Tư vấn lộ trình học và giải đáp câu hỏi trong phòng học.</p>
                    </div>
                    <span class="shrink-0 font-mono text-[11px] font-bold px-2.5 py-1 rounded ${hasGeminiKey ? 'bg-emerald-soft text-emerald-ok' : 'bg-danger-soft text-danger'}">
                        ${hasGeminiKey ? (geminiFromEnv ? 'ĐÃ KẾT NỐI · MÁY CHỦ' : 'ĐÃ KẾT NỐI') : 'CHƯA KÍCH HOẠT'}
                    </span>
                </div>

                <form action="${pageContext.request.contextPath}/admin/settings" method="post" class="space-y-4">
                    <div>
                        <label for="geminiModel" class="block text-[13px] font-bold mb-1.5">Phiên bản mô hình</label>
                        <select id="geminiModel" name="geminiModel" class="lab-input font-mono text-[13px]">
                            <option value="gemini-3.8-flash" ${geminiModel == 'gemini-3.8-flash' ? 'selected' : ''}>gemini-3.8-flash (Nhanh &amp; Cân bằng)</option>
                            <option value="gemini-3.5-flash-lite" ${geminiModel == 'gemini-3.5-flash-lite' ? 'selected' : ''}>gemini-3.5-flash-lite (Tối ưu tốc độ)</option>
                            <option value="gemini-2.5-flash" ${geminiModel == 'gemini-2.5-flash' ? 'selected' : ''}>gemini-2.5-flash (Ổn định)</option>
                            <option value="gemini-2.5-flash-lite" ${geminiModel == 'gemini-2.5-flash-lite' ? 'selected' : ''}>gemini-2.5-flash-lite</option>
                        </select>
                    </div>

                    <div>
                        <label for="geminiApiKey" class="block text-[13px] font-bold mb-1.5">
                            Khóa kết nối Gemini
                            <c:if test="${hasGeminiKey}">
                                <span class="ml-2 font-mono text-[11.5px] font-semibold text-emerald-ok">Hiện tại: ${geminiKeyMasked}</span>
                            </c:if>
                        </label>
                        <input id="geminiApiKey" type="password" name="geminiApiKey" autocomplete="off"
                               ${geminiFromEnv ? 'disabled' : ''}
                               placeholder="${geminiFromEnv ? 'Đã cấu hình an toàn trên máy chủ' : (hasGeminiKey ? 'Để trống nếu giữ nguyên khóa hiện tại' : 'Nhập khóa kết nối Gemini')}"
                               class="lab-input font-mono text-[13.5px] disabled:bg-paper disabled:opacity-70">
                    </div>

                    <c:if test="${hasGeminiKey && !geminiFromEnv}">
                        <label class="inline-flex items-center gap-2 text-[12.5px] font-semibold text-danger">
                            <input type="checkbox" name="clearGeminiKey" value="1" class="accent-danger">
                            <span>Gỡ khóa đã lưu</span>
                        </label>
                    </c:if>

                    <div class="pt-2 flex flex-wrap gap-2.5">
                        <button type="submit" name="action" value="saveGemini" class="btn-blueprint px-4 py-2.5 text-[13.5px]">
                            <i data-lucide="save" class="w-4 h-4"></i>
                            <span>Lưu cấu hình</span>
                        </button>
                        <button type="submit" name="action" value="testGemini" class="btn-outline-ink px-4 py-2.5 text-[13.5px]">
                            <i data-lucide="zap" class="w-4 h-4 text-blueprint"></i>
                            <span>Kiểm tra kết nối</span>
                        </button>
                    </div>
                </form>
            </div>
        </section>

        <!-- Stripe Checkout & Webhook Settings -->
        <section class="binder-sheet rounded-xl overflow-hidden">
            <div class="h-2 bg-amber-bar"></div>
            <div class="p-6 sm:p-7 space-y-5">
                <div class="flex items-start justify-between gap-3">
                    <div>
                        <h2 class="text-[19px] font-extrabold text-ink">Cổng thanh toán Stripe</h2>
                        <p class="text-[13px] text-ink-muted mt-0.5">Ưu tiên nạp khóa từ biến môi trường máy chủ và xác thực chữ ký Webhook.</p>
                    </div>
                    <span class="shrink-0 font-mono text-[11px] font-bold px-2.5 py-1 rounded ${hasStripeSk ? 'bg-emerald-soft text-emerald-ok' : 'bg-danger-soft text-danger'}">
                        ${hasStripeSk ? (stripeFromEnv ? 'SẴN SÀNG · MÁY CHỦ' : 'SẴN SÀNG') : 'CHƯA KÍCH HOẠT'}
                    </span>
                </div>

                <form action="${pageContext.request.contextPath}/admin/settings" method="post" class="space-y-4">
                    <div>
                        <label for="stripeSecretKey" class="block text-[13px] font-bold mb-1.5">
                            Stripe Secret Key
                            <c:if test="${hasStripeSk}">
                                <span class="ml-2 font-mono text-[11.5px] font-semibold text-emerald-ok">Hiện tại: ${stripeSkMasked}</span>
                            </c:if>
                        </label>
                        <input id="stripeSecretKey" type="password" name="stripeSecretKey" autocomplete="off"
                               ${stripeFromEnv ? 'disabled' : ''}
                               placeholder="${stripeFromEnv ? 'Đã cấu hình an toàn trên máy chủ' : (hasStripeSk ? 'Để trống nếu giữ nguyên khóa hiện tại' : 'Nhập Stripe Secret Key')}"
                               class="lab-input font-mono text-[13.5px] disabled:bg-paper disabled:opacity-70">
                    </div>

                    <div>
                        <label for="stripeWebhookSecret" class="block text-[13px] font-bold mb-1.5">
                            Stripe Webhook Secret
                            <c:if test="${hasStripeWh}">
                                <span class="ml-2 font-mono text-[11.5px] font-semibold text-emerald-ok">Hiện tại: ${stripeWhMasked}</span>
                            </c:if>
                        </label>
                        <input id="stripeWebhookSecret" type="password" name="stripeWebhookSecret" autocomplete="off"
                               ${webhookFromEnv ? 'disabled' : ''}
                               placeholder="${webhookFromEnv ? 'Đã cấu hình an toàn trên máy chủ' : (hasStripeWh ? 'Để trống nếu giữ nguyên khóa hiện tại' : 'Nhập Stripe Webhook Secret')}"
                               class="lab-input font-mono text-[13.5px] disabled:bg-paper disabled:opacity-70">
                    </div>

                    <div>
                        <label for="stripePublishableKey" class="block text-[13px] font-bold mb-1.5">
                            Stripe Publishable Key (tùy chọn)
                            <c:if test="${not empty stripePkMasked}">
                                <span class="ml-2 font-mono text-[11.5px] font-semibold text-ink-muted">${stripePkMasked}</span>
                            </c:if>
                        </label>
                        <input id="stripePublishableKey" type="text" name="stripePublishableKey" autocomplete="off"
                               placeholder="Nhập Publishable Key nếu cần" class="lab-input font-mono text-[13.5px]">
                    </div>

                    <c:if test="${(hasStripeSk && !stripeFromEnv) || (hasStripeWh && !webhookFromEnv)}">
                        <label class="inline-flex items-center gap-2 text-[12.5px] font-semibold text-danger">
                            <input type="checkbox" name="clearStripeKey" value="1" class="accent-danger">
                            <span>Gỡ khóa Stripe đã lưu</span>
                        </label>
                    </c:if>

                    <div class="pt-2 flex flex-wrap gap-2.5">
                        <button type="submit" name="action" value="saveStripe" class="btn-pro px-4 py-2.5 text-[13.5px]">
                            <i data-lucide="save" class="w-4 h-4"></i>
                            <span>Lưu cấu hình</span>
                        </button>
                        <button type="submit" name="action" value="testStripe" class="btn-outline-ink px-4 py-2.5 text-[13.5px]">
                            <i data-lucide="shield-check" class="w-4 h-4 text-amber-pro"></i>
                            <span>Kiểm tra kết nối</span>
                        </button>
                    </div>
                </form>
            </div>
        </section>
    </div>

    <!-- Website Identity & Bank Transfer Settings -->
    <section class="binder-sheet rounded-xl overflow-hidden">
        <div class="h-2 bg-ink"></div>
        <div class="p-6 sm:p-7 space-y-5">
            <div>
                <h2 class="text-[19px] font-extrabold text-ink">Thông tin Website &amp; Tài khoản Ngân hàng</h2>
                <p class="text-[13px] text-ink-muted mt-0.5">Cập nhật nội dung trang chủ, liên hệ hỗ trợ và thông tin nhận chuyển khoản ngân hàng.</p>
            </div>

            <form action="${pageContext.request.contextPath}/admin/settings" method="post" class="grid grid-cols-1 md:grid-cols-12 gap-4">
                <div class="md:col-span-4">
                    <label class="block text-[13px] font-bold mb-1">Tên thương hiệu</label>
                    <input type="text" name="siteName" value="<c:out value='${siteSettings["site.name"]}'/>" class="lab-input text-[13.5px]">
                </div>
                <div class="md:col-span-4">
                    <label class="block text-[13px] font-bold mb-1">Email hỗ trợ</label>
                    <input type="email" name="supportEmail" value="<c:out value='${siteSettings["site.support_email"]}'/>" class="lab-input font-mono text-[13.5px]">
                </div>
                <div class="md:col-span-4">
                    <label class="block text-[13px] font-bold mb-1">Hotline</label>
                    <input type="text" name="hotline" value="<c:out value='${siteSettings["site.hotline"]}'/>" class="lab-input font-mono text-[13.5px]">
                </div>
                <div class="md:col-span-6">
                    <label class="block text-[13px] font-bold mb-1">Tiêu đề trang chủ</label>
                    <input type="text" name="heroTitle" value="<c:out value='${siteSettings["site.hero_title"]}'/>" class="lab-input text-[13.5px]">
                </div>
                <div class="md:col-span-6">
                    <label class="block text-[13px] font-bold mb-1">Địa chỉ liên hệ</label>
                    <input type="text" name="address" value="<c:out value='${siteSettings["site.address"]}'/>" class="lab-input text-[13.5px]">
                </div>
                <div class="md:col-span-6">
                    <label class="block text-[13px] font-bold mb-1">Mô tả trang chủ</label>
                    <textarea name="heroSubtitle" rows="2" class="lab-input text-[13.5px]"><c:out value="${siteSettings['site.hero_subtitle']}"/></textarea>
                </div>
                <div class="md:col-span-6">
                    <label class="block text-[13px] font-bold mb-1">Giới thiệu chân trang</label>
                    <textarea name="siteTagline" rows="2" class="lab-input text-[13.5px]"><c:out value="${siteSettings['site.tagline']}"/></textarea>
                </div>
                <div class="md:col-span-3">
                    <label class="block text-[13px] font-bold mb-1">Ngân hàng (mã VietQR)</label>
                    <select name="bankBin" class="lab-input text-[13px]">
                        <option value="970415" ${bankBin == '970415' ? 'selected' : ''}>VietinBank (970415)</option>
                        <option value="970436" ${bankBin == '970436' ? 'selected' : ''}>Vietcombank (970436)</option>
                        <option value="970418" ${bankBin == '970418' ? 'selected' : ''}>BIDV (970418)</option>
                        <option value="970405" ${bankBin == '970405' ? 'selected' : ''}>Agribank (970405)</option>
                        <option value="970407" ${bankBin == '970407' ? 'selected' : ''}>Techcombank (970407)</option>
                        <option value="970422" ${bankBin == '970422' ? 'selected' : ''}>MB Bank (970422)</option>
                        <option value="970416" ${bankBin == '970416' ? 'selected' : ''}>ACB (970416)</option>
                        <option value="970432" ${bankBin == '970432' ? 'selected' : ''}>VPBank (970432)</option>
                        <option value="970423" ${bankBin == '970423' ? 'selected' : ''}>TPBank (970423)</option>
                        <option value="970403" ${bankBin == '970403' ? 'selected' : ''}>Sacombank (970403)</option>
                    </select>
                </div>
                <div class="md:col-span-3">
                    <label class="block text-[13px] font-bold mb-1">Tên chi nhánh hiển thị</label>
                    <input type="text" name="bankName" value="<c:out value='${siteSettings["bank.name"]}'/>" class="lab-input text-[13.5px]">
                </div>
                <div class="md:col-span-3">
                    <label class="block text-[13px] font-bold mb-1">Số tài khoản</label>
                    <input type="text" name="bankAccountNumber" value="<c:out value='${siteSettings["bank.account_number"]}'/>" class="lab-input font-mono text-[13.5px]">
                </div>
                <div class="md:col-span-3">
                    <label class="block text-[13px] font-bold mb-1">Chủ tài khoản</label>
                    <input type="text" name="bankAccountHolder" value="<c:out value='${siteSettings["bank.account_holder"]}'/>" class="lab-input font-mono text-[13.5px]">
                </div>
                <div class="md:col-span-12 flex justify-end pt-1">
                    <button type="submit" name="action" value="saveSite" class="btn-ink px-5 py-2.5 text-[13.5px]">
                        <i data-lucide="save" class="w-4 h-4"></i>
                        <span>Lưu thông tin Website &amp; Ngân hàng</span>
                    </button>
                </div>
            </form>
        </div>
    </section>

    <!-- Automated Email Service (Resend) -->
    <section class="binder-sheet rounded-xl overflow-hidden">
        <div class="h-2 bg-emerald-ok"></div>
        <div class="p-6 sm:p-7 space-y-5">
            <div class="flex items-start justify-between gap-3">
                <div>
                    <h2 class="text-[19px] font-extrabold text-ink">Dịch vụ Email tự động</h2>
                    <p class="text-[13px] text-ink-muted mt-0.5">Gửi liên kết đặt lại mật khẩu và email hóa đơn xác nhận mở khóa học tự động.</p>
                </div>
                <span class="shrink-0 font-mono text-[11px] font-bold px-2.5 py-1 rounded ${hasResendKey ? 'bg-emerald-soft text-emerald-ok' : 'bg-danger-soft text-danger'}">
                    ${hasResendKey ? (resendFromEnv ? 'SẴN SÀNG · MÁY CHỦ' : 'SẴN SÀNG') : 'CHƯA KÍCH HOẠT'}
                </span>
            </div>

            <form action="${pageContext.request.contextPath}/admin/settings" method="post" class="grid grid-cols-1 md:grid-cols-12 gap-4 items-end">
                <div class="md:col-span-4">
                    <label for="mailFrom" class="block text-[13px] font-bold mb-1.5">Địa chỉ gửi đi</label>
                    <input id="mailFrom" type="text" name="mailFrom" value="<c:out value='${mailFrom}'/>"
                           placeholder="CourseShop <onboarding@resend.dev>" class="lab-input font-mono text-[13px]">
                </div>
                <div class="md:col-span-4">
                    <label for="resendApiKey" class="block text-[13px] font-bold mb-1.5">
                        Khóa kết nối gửi thư (Resend)
                        <c:if test="${hasResendKey}">
                            <span class="ml-1.5 font-mono text-[11px] font-semibold text-emerald-ok">${resendKeyMasked}</span>
                        </c:if>
                    </label>
                    <input id="resendApiKey" type="password" name="resendApiKey" autocomplete="off"
                           ${resendFromEnv ? 'disabled' : ''}
                           placeholder="${resendFromEnv ? 'Đã cấu hình an toàn trên máy chủ' : (hasResendKey ? 'Để trống nếu giữ nguyên khóa' : 'Nhập khóa Resend (re_...)')}"
                           class="lab-input font-mono text-[13px] disabled:bg-paper disabled:opacity-70">
                </div>
                <div class="md:col-span-4">
                    <label for="testEmail" class="block text-[13px] font-bold mb-1.5">Email nhận thử nghiệm</label>
                    <input id="testEmail" type="email" name="testEmail" value="<c:out value='${sessionScope.user.email}'/>"
                           placeholder="ban@example.com" class="lab-input font-mono text-[13px]">
                </div>
                <c:if test="${hasResendKey && !resendFromEnv}">
                    <div class="md:col-span-12">
                        <label class="inline-flex items-center gap-2 text-[12.5px] font-semibold text-danger">
                            <input type="checkbox" name="clearResendKey" value="1" class="accent-danger">
                            <span>Gỡ khóa email đã lưu</span>
                        </label>
                    </div>
                </c:if>
                <div class="md:col-span-12 flex flex-wrap gap-2.5 pt-1">
                    <button type="submit" name="action" value="saveMail" class="btn-blueprint px-4 py-2.5 text-[13.5px]">
                        <i data-lucide="save" class="w-4 h-4"></i>
                        <span>Lưu cấu hình Email</span>
                    </button>
                    <button type="submit" name="action" value="testMail" class="btn-outline-ink px-4 py-2.5 text-[13.5px]">
                        <i data-lucide="send" class="w-4 h-4 text-emerald-ok"></i>
                        <span>Gửi email kiểm tra</span>
                    </button>
                </div>
            </form>
        </div>
    </section>
</main>
</body>
</html>
