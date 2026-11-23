# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Stack

Java 21 + Jakarta EE 10 (Servlet / JSP / JSTL 3.0.1) + Apache NetBeans 32 (**Java with Maven Web Application**, `pom.xml`) + Apache Tomcat 10.1.62 + MySQL/MariaDB 10.4 (XAMPP) + Gson 2.11.0 + **Tailwind CSS v4 (`@tailwindcss/cli` → static minified CSS) + Alpine.js 3 (self-hosted) + Lucide Icons + Chart.js 4** (không dùng Bootstrap). Deploy target: local Apache Tomcat 10.1 (`/CourseShop`) backed by local XAMPP MySQL (`course_shop`).

## Users

- **Học viên chính (Learners)**: Sinh viên ngành CNTT và người mới bắt đầu chuyển ngành muốn học lập trình bài bản theo lộ trình để đi làm. Họ cần thấy rõ mình nên học gì trước — học gì sau, trải nghiệm học thử miễn phí trước khi trả tiền, và học tập trung có theo dõi tiến độ & ghi chú.
- **Quản trị viên (Admins)**: Người vận hành nền tảng cần quản lý danh mục, khóa học (Pro & Miễn phí), chương/bài học, duyệt đơn chuyển khoản, quản lý tài khoản, theo dõi doanh thu và cấu hình/kiểm tra kết nối API (Stripe, Google AI Studio).

## Product Purpose

CourseShop là nền tảng bán khóa học và học lập trình trực tuyến kết hợp đầy đủ nghiệp vụ E-Commerce và E-Learning:
- Giúp người mới tiếp cận lộ trình học lập trình rõ ràng (kết hợp khóa Miễn phí 0đ đăng ký 1-click và khóa Pro trả phí).
- Cung cấp trải nghiệm mua khóa học mượt mà (giỏ hàng, mã giảm giá, giả lập thanh toán Stripe Sandbox / Mock UI, chuyển khoản duyệt tay) và tự động cấp quyền học (`enrollments`).
- Cung cấp không gian học tập thực dụng (video, chương/bài học, theo dõi % tiến độ, ghi chú theo mốc thời gian video, đánh giá sau khi mua) kết hợp trợ lý AI (Google AI Studio / Gemini API) tư vấn khóa học và giải đáp bài giảng theo ngữ cảnh.

## Positioning

Kết hợp mô hình lộ trình học đi làm kiểu F8 (Free + Pro + Lộ trình nghề nghiệp + Ghi chú theo timestamp trong trang học) với luồng thương mại chuẩn (Stripe Dual-Mode Sandbox/Mock) và AI Chatbot hai vai trò (Tư vấn viên gắn dữ liệu khóa học thật từ MySQL + Trợ giảng AI gắn bài học đang xem), chạy hoàn toàn trên nền tảng Java Servlet/JSP thuần không phụ thuộc framework nặng.

## Operating Context

- Học viên truy cập bằng trình duyệt desktop (khi code song song xem bài giảng) và mobile (khi tìm khóa học hoặc ôn ghi chú).
- Quản trị viên vận hành qua `/admin/*` riêng biệt, có trang `/admin/settings` để nhập, ẩn/che và kiểm tra kết nối `GEMINI_API_KEY` và `STRIPE_SECRET_KEY` trực tiếp khi demo.
- Dữ liệu ban đầu dùng bộ mockdata có cấu trúc thật (lộ trình, 12 khóa học Pro & Miễn phí, chương/bài học dùng video YouTube embed công khai, đơn hàng mẫu, đánh giá mẫu, coupon mẫu) import vào MySQL XAMPP.

## Capabilities and Constraints

- **Xác thực & Phân quyền**: Đăng ký, Đăng nhập, Đăng xuất, băm mật khẩu `PBKDF2WithHmacSHA256`, `AuthFilter` bảo vệ luồng mua/học, `AdminFilter` bảo vệ `/admin/*`.
- **Thương mại điện tử**: Lọc/tìm kiếm/sắp xếp/phân trang 100% qua SQL `PreparedStatement`; Giỏ hàng Session chặn mua trùng hoặc mua khóa đã sở hữu; Coupon; Thanh toán Stripe Dual-Mode (`POST /v1/checkout/sessions` & verify `GET /v1/checkout/sessions/{id}` với đơn vị tiền zero-decimal `vnd` khi có `sk_test_...`, hoặc Offline Mock Stripe Checkout UI); JDBC Transaction cấp `enrollments`.
- **E-Learning**: Đăng ký khóa miễn phí 1-click; Trang `/my-courses` hiển thị `%` tiến độ; Trang `/learn` có video player, chuyển bài Trước/Sau, đánh dấu hoàn thành AJAX, ghi chú theo mốc thời gian (`lesson_notes`), và đánh giá chỉ dành cho học viên đã sở hữu.
- **AI Chatbot**: Gọi Gemini REST API (`generateContent` với header `x-goog-api-key`) hoàn toàn từ Backend `/api/chat`, không lộ API key ra trình duyệt.
- **Kỹ thuật bắt buộc**: Tiếng Việt đầy đủ dấu (UTF-8 toàn hệ thống), giá tiền VNĐ chuẩn `tabular-nums`, đóng tài nguyên JDBC bằng `try-with-resources`, quản lý dependency chuẩn Maven (`pom.xml`), cấu trúc `src/main/java` & `src/main/webapp`.
- **Chưa chốt / mở**: Tên thương hiệu chính thức (tạm dùng `CourseShop`, có thể đổi bất kỳ lúc nào); khóa học thực tế & API key thật do người dùng tự nhập ở `/admin/settings` hoặc `config.properties`.

## Evidence on Hand

- Môi trường đã cài sẵn và kiểm chứng: JDK `21.0.11`, Apache NetBeans `32`, Apache Tomcat `10.1.62`, XAMPP `8.2.12` (MariaDB `10.4.32`).
- Dự án tham chiếu cấu trúc Ant: `D:\Workspace\Projects\Java\Shopping` (có sẵn 3 JAR JSTL & MySQL Connector).
- Chưa có dữ liệu thương mại thực tế (doanh số, học viên thật, đánh giá thật) — toàn bộ dữ liệu demo là mockdata có cấu trúc rõ ràng và không bịa đặt chứng nhận hay số liệu khách hàng doanh nghiệp sai sự thật.

## Product Principles

1. **Rõ lộ trình trước khi bán**: Luôn giúp người mới biết họ đang ở bước nào và nên học gì tiếp theo thay vì bày tràn lan hàng loạt thẻ khóa học giống nhau.
2. **Thử trước, tin sau**: Khóa miễn phí đăng ký 1-click và bài học preview phải mượt như sản phẩm chính để tạo niềm tin mua khóa Pro.
3. **Tập trung tối đa khi học & vận hành**: Khu vực `/learn` và `/admin/*` ưu tiên tốc độ, sự rõ ràng và không gây xao nhãng; các thao tác tiến độ và ghi chú phản hồi tức thì.
4. **Minh bạch và an toàn giao dịch**: Mọi thay đổi đơn hàng và cấp quyền khóa học diễn ra trong SQL Transaction; xác minh trạng thái thanh toán phía server; không lộ API key ra client.
5. **Đạt chuẩn xuất bản thực tế**: Đầy đủ trạng thái rỗng/loading/lỗi/404/403, tiếng Việt tự nhiên chuẩn production, hiển thị sạch trên cả desktop lẫn mobile.

## Accessibility & Inclusion

- Hỗ trợ đầy đủ tiếng Việt (UTF-8, font hỗ trợ dấu tiếng Việt rõ nét).
- Đạt chuẩn tương phản màu tối thiểu WCAG AA (`>= 4.5:1`), điều hướng bàn phím có trạng thái focus rõ ràng, và layout responsive từ `375px` đến `1440px+`.
