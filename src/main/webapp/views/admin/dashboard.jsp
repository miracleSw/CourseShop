<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="includeChartJs" value="true" scope="request"/>
<c:set var="bodyClass" value="bg-paper text-ink antialiased min-h-screen flex flex-col lg:flex-row" scope="request"/>
<jsp:include page="/inc/head.jsp"/>
<jsp:include page="/inc/admin-sidebar.jsp"/>
<jsp:include page="/inc/toast.jsp"/>

<main class="flex-1 p-5 sm:p-8 lg:p-10 min-w-0 space-y-8">
    <div class="flex flex-wrap items-end justify-between gap-4 pb-4 border-b-[1.5px] border-ink">
        <div>
            <h1 class="text-[26px] sm:text-[32px] font-extrabold tracking-tight text-ink">Tổng quan vận hành</h1>
            <p class="text-[14px] text-ink-muted mt-1">Theo dõi doanh thu, đơn hàng chờ duyệt và hiệu suất khóa học theo thời gian thực.</p>
        </div>
        <div class="flex flex-wrap gap-2.5">
            <a href="${pageContext.request.contextPath}/admin/dashboard?export=csv<c:if test='${not empty fromDate}'>&from=${fromDate}</c:if><c:if test='${not empty toDate}'>&to=${toDate}</c:if>"
               class="btn-outline-ink px-4 py-2 text-[13.5px]">
                <i data-lucide="download" class="w-4 h-4"></i>
                <span>Xuất báo cáo CSV</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/courses" class="btn-blueprint px-4 py-2 text-[13.5px]">
                <i data-lucide="plus" class="w-4 h-4"></i>
                <span>Thêm khóa học</span>
            </a>
        </div>
    </div>

    <!-- Date Range Filter -->
    <form action="${pageContext.request.contextPath}/admin/dashboard" method="get"
          class="binder-sheet rounded-xl p-4 flex flex-wrap items-end gap-3">
        <div>
            <label for="fromDate" class="block text-[12px] font-bold text-ink-muted mb-1">Từ ngày</label>
            <input id="fromDate" type="date" name="from" value="<c:out value='${fromDate}'/>" class="lab-input h-9 text-[13px] font-mono w-40">
        </div>
        <div>
            <label for="toDate" class="block text-[12px] font-bold text-ink-muted mb-1">Đến ngày</label>
            <input id="toDate" type="date" name="to" value="<c:out value='${toDate}'/>" class="lab-input h-9 text-[13px] font-mono w-40">
        </div>
        <button type="submit" class="btn-ink h-9 px-4 text-[13px]">Áp dụng lọc</button>
        <c:if test="${not empty fromDate || not empty toDate}">
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn-outline-ink h-9 px-3.5 text-[13px]">Xem tất cả</a>
        </c:if>
    </form>

    <!-- KPI Strip -->
    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <div class="binder-sheet rounded-lg p-5">
            <div class="flex items-center justify-between text-[13px] font-bold text-ink-muted">
                <span>Doanh thu đã xác nhận</span>
                <i data-lucide="wallet" class="w-4 h-4 text-emerald-ok"></i>
            </div>
            <div class="font-mono text-[26px] font-extrabold text-ink mt-2 tabular-nums">${formattedRevenue}</div>
            <div class="text-[12px] text-ink-muted mt-1 font-mono tabular-nums">${stats.paidOrders} đơn thành công</div>
        </div>

        <div class="binder-sheet rounded-lg p-5">
            <div class="flex items-center justify-between text-[13px] font-bold text-ink-muted">
                <span>Đơn chờ xác nhận</span>
                <i data-lucide="clock" class="w-4 h-4 text-amber-pro"></i>
            </div>
            <div class="font-mono text-[26px] font-extrabold text-amber-pro mt-2 tabular-nums">${stats.pendingOrders}</div>
            <a href="${pageContext.request.contextPath}/admin/orders?status=PENDING" class="text-[12px] font-bold text-blueprint hover:underline mt-1 inline-block">
                Mở hàng chờ duyệt →
            </a>
        </div>

        <div class="binder-sheet rounded-lg p-5">
            <div class="flex items-center justify-between text-[13px] font-bold text-ink-muted">
                <span>Tổng khóa học</span>
                <i data-lucide="book-open" class="w-4 h-4 text-blueprint"></i>
            </div>
            <div class="font-mono text-[26px] font-extrabold text-ink mt-2 tabular-nums">${stats.totalCourses}</div>
            <div class="text-[12px] text-ink-muted mt-1 font-mono tabular-nums">${stats.totalEnrollments} lượt ghi danh</div>
        </div>

        <div class="binder-sheet rounded-lg p-5">
            <div class="flex items-center justify-between text-[13px] font-bold text-ink-muted">
                <span>Học viên đăng ký</span>
                <i data-lucide="users" class="w-4 h-4 text-ink"></i>
            </div>
            <div class="font-mono text-[26px] font-extrabold text-ink mt-2 tabular-nums">${stats.totalUsers}</div>
            <a href="${pageContext.request.contextPath}/admin/users" class="text-[12px] font-bold text-blueprint hover:underline mt-1 inline-block">
                Quản lý tài khoản →
            </a>
        </div>
    </div>

    <!-- Chart + Top Courses -->
    <div class="grid grid-cols-1 xl:grid-cols-12 gap-6">
        <section class="xl:col-span-7 binder-sheet rounded-xl p-6">
            <div class="flex items-center justify-between mb-4">
                <h2 class="text-[17px] font-extrabold text-ink">Biểu đồ doanh thu theo ngày (VNĐ)</h2>
                <span class="text-[12px] font-semibold text-ink-muted">Đơn đã thanh toán</span>
            </div>
            <div class="h-64">
                <canvas id="revenueChart"></canvas>
            </div>
        </section>

        <section class="xl:col-span-5 binder-sheet rounded-xl p-6">
            <h2 class="text-[17px] font-extrabold text-ink mb-4">Top khóa học nổi bật</h2>
            <ul class="divide-y divide-rule text-[13.5px]">
                <c:forEach var="tc" items="${stats.topCourses}">
                    <li class="py-3 flex items-center justify-between gap-3">
                        <div class="min-w-0">
                            <div class="font-mono text-[11px] font-bold ${tc.pro ? 'text-amber-pro' : 'text-blueprint'}">${tc.code}</div>
                            <div class="font-bold text-ink truncate"><c:out value="${tc.title}"/></div>
                        </div>
                        <div class="text-right shrink-0 font-mono tabular-nums">
                            <div class="text-[13px] font-extrabold text-ink">${tc.enrollments} HV</div>
                        </div>
                    </li>
                </c:forEach>
            </ul>
        </section>
    </div>

    <!-- Recent Orders Table -->
    <section class="binder-sheet rounded-xl overflow-hidden">
        <div class="px-6 py-4 bg-paper-soft border-b border-rule flex items-center justify-between">
            <h2 class="text-[17px] font-extrabold text-ink">Đơn hàng mới nhất</h2>
            <a href="${pageContext.request.contextPath}/admin/orders" class="text-[13px] font-bold text-blueprint hover:underline">Xem tất cả</a>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-left text-[13.5px] border-collapse">
                <thead>
                    <tr class="bg-paper-soft border-b border-rule font-mono text-[11.5px] uppercase text-ink-muted">
                        <th class="px-5 py-3">Mã đơn</th>
                        <th class="px-5 py-3">Học viên</th>
                        <th class="px-5 py-3">Cổng TT</th>
                        <th class="px-5 py-3 text-right">Tổng tiền</th>
                        <th class="px-5 py-3">Trạng thái</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-rule">
                    <c:forEach var="o" items="${recentOrders}">
                        <tr class="hover:bg-paper-soft/60">
                            <td class="px-5 py-3 font-mono font-bold">#${o.orderCode}</td>
                            <td class="px-5 py-3">
                                <div class="font-bold text-ink"><c:out value="${o.userName}"/></div>
                                <div class="font-mono text-[11.5px] text-ink-muted"><c:out value="${o.userEmail}"/></div>
                            </td>
                            <td class="px-5 py-3 text-[13px] text-ink-muted"><c:out value="${o.paymentMethodLabel}"/></td>
                            <td class="px-5 py-3 text-right font-mono font-bold tabular-nums">${o.formattedTotal}</td>
                            <td class="px-5 py-3">
                                <span class="text-[11.5px] font-bold px-2 py-0.5 rounded
                                    ${o.status == 'PAID' ? 'bg-emerald-soft text-emerald-ok' : (o.status == 'PENDING' ? 'bg-amber-soft text-amber-ink' : 'bg-danger-soft text-danger')}">
                                    <c:out value="${o.statusLabel}"/>
                                </span>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </section>
</main>

<script>
document.addEventListener('DOMContentLoaded', () => {
  const ctx = document.getElementById('revenueChart');
  if (!ctx || typeof Chart === 'undefined') return;
  const labels = ${chartLabelsJson};
  const values = ${chartValuesJson};
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: labels.length ? labels : ['Hôm nay'],
      datasets: [{
        label: 'Doanh thu (VNĐ)',
        data: values.length ? values : [0],
        backgroundColor: '#23469E',
        borderColor: '#16181D',
        borderWidth: 1.5,
        borderRadius: 4
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        y: {
          beginAtZero: true,
          grid: { color: '#E5E0D5' },
          ticks: {
            callback: (v) => Number(v).toLocaleString('vi-VN') + 'đ'
          }
        },
        x: { grid: { display: false } }
      }
    }
  });
});
</script>
</body>
</html>
