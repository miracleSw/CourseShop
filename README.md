# CourseShop — Nền tảng E-Learning & E-Commerce (Java 21 / Jakarta EE 10)

## Yêu cầu môi trường trên máy mới
- **JDK 21** (LTS)
- **Apache Tomcat 10.1.x** (Jakarta EE 10)
- **MySQL 8.x hoặc MariaDB 10.4+** (ví dụ XAMPP)
- **Apache Maven 3.9+** hoặc **Apache NetBeans 22+** (đã tích hợp sẵn Maven)
- *(Tùy chọn)* **Node.js 20+** chỉ cần khi chỉnh sửa lại CSS Tailwind nguồn trong `frontend/app.css` (file CSS đã được biên dịch sẵn tại `src/main/webapp/assets/css/app.css`).

---

## Bước 1: Import Cơ sở dữ liệu MySQL
1. Khởi động **MySQL** trong XAMPP Control Panel (cổng `3306`).
2. Import file `database/course_shop.sql` (gồm 19 bảng + dữ liệu khóa học, lộ trình, bài học, mã giảm giá, cài đặt):
   - **Cách A (phpMyAdmin)**: Mở `http://localhost/phpmyadmin` → tab **Import** → chọn `database/course_shop.sql` (UTF-8) → bấm **Go / Thực hiện**.
   - **Cách B (Command Line)**:
     ```bash
     mysql -u root --default-character-set=utf8mb4 < database/course_shop.sql
     ```

---

## Bước 2: Cấu hình kết nối DB & API Keys (Stripe + Google Gemini)
Ứng dụng ưu tiên đọc **Biến môi trường (Environment Variables)** trước, sau đó mới tới `src/main/resources/config.properties` (tạo từ `config.properties.example`):

| Biến môi trường | Giá trị mặc định / Mô tả |
|---|---|
| `COURSESHOP_DB_URL` | `jdbc:mysql://localhost:3306/course_shop?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh&allowPublicKeyRetrieval=true&useSSL=false` |
| `COURSESHOP_DB_USER` | `root` |
| `COURSESHOP_DB_PASSWORD` | *(trống với XAMPP mặc định)* |
| `STRIPE_SECRET_KEY` | Khóa bí mật Stripe (`sk_test_...` hoặc `sk_live_...`) |
| `STRIPE_PUBLISHABLE_KEY` | *(tùy chọn)* `pk_test_...` |
| `STRIPE_WEBHOOK_SECRET` | Khóa ký Webhook (`whsec_...`) cho endpoint `POST /CourseShop/webhooks/stripe` |
| `GEMINI_API_KEY` | API Key lấy từ Google AI Studio |
| `GEMINI_MODEL` | `gemini-3.8-flash` |

> Bạn cũng có thể đăng nhập Admin và nhập/kiểm tra kết nối trực tiếp tại `/CourseShop/admin/settings` nếu chưa khai báo biến môi trường.

---

## Bước 3: Chạy dự án
- **Cách 1 (Apache NetBeans)**: `File → Open Project` → chọn thư mục `CourseShop` → cấu hình Server là **Apache Tomcat 10.1** → chuột phải chọn **Run**.
- **Cách 2 (Maven CLI)**:
  ```bash
  mvn clean package
  ```
  Sau đó copy file `target/CourseShop.war` vào thư mục `webapps/` của Apache Tomcat 10.1 và khởi động Tomcat.
- Truy cập: `http://localhost:8080/CourseShop/home`

---

## Tài khoản khởi tạo sẵn trong MySQL
- **Quản trị viên (Admin)**: `admin@courseshop.vn` / `Admin@123`
- **Học viên 1**: `student@courseshop.vn` / `Student@123`
- **Học viên 2**: `linh@courseshop.vn` / `Student@123`

## Nếu chỉnh sửa giao diện Tailwind CSS
```bash
npm install
npm run css:build
```
