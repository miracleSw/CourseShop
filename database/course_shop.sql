-- ==========================================================
-- CourseShop: E-Learning + E-Commerce MySQL Database Schema & Initial Data
-- Engine: MySQL / MariaDB 10.4+ (XAMPP)
-- Charset: utf8mb4_unicode_ci
-- ==========================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

CREATE DATABASE IF NOT EXISTS `course_shop`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `course_shop`;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `payment_transactions`;
DROP TABLE IF EXISTS `chat_messages`;
DROP TABLE IF EXISTS `chat_quick_prompts`;
DROP TABLE IF EXISTS `cart_items`;
DROP TABLE IF EXISTS `app_settings`;
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `lesson_notes`;
DROP TABLE IF EXISTS `lesson_progress`;
DROP TABLE IF EXISTS `enrollments`;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `coupons`;
DROP TABLE IF EXISTS `lessons`;
DROP TABLE IF EXISTS `sections`;
DROP TABLE IF EXISTS `learning_path_courses`;
DROP TABLE IF EXISTS `learning_paths`;
DROP TABLE IF EXISTS `courses`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `users`;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. USERS
CREATE TABLE `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `full_name` VARCHAR(120) NOT NULL,
  `email` VARCHAR(160) NOT NULL UNIQUE,
  `phone` VARCHAR(30) DEFAULT '',
  `password_hash` VARCHAR(255) NOT NULL,
  `avatar` VARCHAR(255) DEFAULT '',
  `role` ENUM('USER', 'ADMIN') NOT NULL DEFAULT 'USER',
  `status` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. CATEGORIES
CREATE TABLE `categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(120) NOT NULL,
  `slug` VARCHAR(140) NOT NULL UNIQUE,
  `description` VARCHAR(400) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. COURSES
CREATE TABLE `courses` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `category_id` INT NOT NULL,
  `code` VARCHAR(24) NOT NULL UNIQUE,
  `title` VARCHAR(200) NOT NULL,
  `slug` VARCHAR(220) NOT NULL UNIQUE,
  `short_desc` VARCHAR(360) NOT NULL,
  `description` TEXT NOT NULL,
  `outcomes_text` TEXT NOT NULL,
  `instructor_name` VARCHAR(120) NOT NULL,
  `thumbnail` VARCHAR(255) NOT NULL,
  `price` DECIMAL(12,0) NOT NULL DEFAULT 0,
  `sale_price` DECIMAL(12,0) DEFAULT NULL,
  `is_pro` TINYINT(1) NOT NULL DEFAULT 0,
  `stripe_product_id` VARCHAR(64) DEFAULT NULL,
  `level` ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED') NOT NULL DEFAULT 'BEGINNER',
  `featured_order` INT NOT NULL DEFAULT 100,
  `status` ENUM('DRAFT', 'PUBLISHED', 'HIDDEN') NOT NULL DEFAULT 'PUBLISHED',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_courses_category` FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. LEARNING PATHS
CREATE TABLE `learning_paths` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(160) NOT NULL,
  `slug` VARCHAR(160) NOT NULL UNIQUE,
  `summary` VARCHAR(500) NOT NULL,
  `target_role` VARCHAR(120) NOT NULL,
  `icon` VARCHAR(60) DEFAULT 'layers',
  `sort_order` INT NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. LEARNING PATH COURSES
CREATE TABLE `learning_path_courses` (
  `path_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `step_order` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`path_id`, `course_id`),
  CONSTRAINT `fk_lpc_path` FOREIGN KEY (`path_id`) REFERENCES `learning_paths`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_lpc_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. SECTIONS
CREATE TABLE `sections` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `course_id` INT NOT NULL,
  `title` VARCHAR(220) NOT NULL,
  `sort_order` INT NOT NULL DEFAULT 1,
  CONSTRAINT `fk_sections_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. LESSONS
CREATE TABLE `lessons` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `section_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `title` VARCHAR(240) NOT NULL,
  `video_url` VARCHAR(500) NOT NULL,
  `duration_seconds` INT NOT NULL DEFAULT 600,
  `content_text` TEXT,
  `is_preview` TINYINT(1) NOT NULL DEFAULT 0,
  `sort_order` INT NOT NULL DEFAULT 1,
  CONSTRAINT `fk_lessons_section` FOREIGN KEY (`section_id`) REFERENCES `sections`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_lessons_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. COUPONS
CREATE TABLE `coupons` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(40) NOT NULL UNIQUE,
  `discount_percent` INT NOT NULL,
  `max_discount` DECIMAL(12,0) DEFAULT NULL,
  `usage_limit` INT NOT NULL DEFAULT 0,
  `used_count` INT NOT NULL DEFAULT 0,
  `expired_at` DATETIME DEFAULT NULL,
  `status` TINYINT(1) NOT NULL DEFAULT 1,
  `stripe_coupon_id` VARCHAR(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. ORDERS
CREATE TABLE `orders` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `order_code` VARCHAR(40) NOT NULL UNIQUE,
  `user_id` INT NOT NULL,
  `coupon_id` INT DEFAULT NULL,
  `subtotal` DECIMAL(12,0) NOT NULL DEFAULT 0,
  `discount_amount` DECIMAL(12,0) NOT NULL DEFAULT 0,
  `total_amount` DECIMAL(12,0) NOT NULL DEFAULT 0,
  `payment_method` VARCHAR(40) NOT NULL DEFAULT 'STRIPE',
  `stripe_session_id` VARCHAR(255) DEFAULT NULL,
  `status` ENUM('PENDING', 'PAID', 'FAILED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `paid_at` DATETIME DEFAULT NULL,
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_orders_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupons`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. ORDER ITEMS
CREATE TABLE `order_items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `order_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `unit_price` DECIMAL(12,0) NOT NULL DEFAULT 0,
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_items_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. ENROLLMENTS
CREATE TABLE `enrollments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `order_id` INT DEFAULT NULL,
  `enrolled_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_enrollment_user_course` (`user_id`, `course_id`),
  CONSTRAINT `fk_enroll_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_enroll_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_enroll_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. LESSON PROGRESS
CREATE TABLE `lesson_progress` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `lesson_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `is_completed` TINYINT(1) NOT NULL DEFAULT 1,
  `completed_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_progress_user_lesson` (`user_id`, `lesson_id`),
  CONSTRAINT `fk_prog_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_prog_lesson` FOREIGN KEY (`lesson_id`) REFERENCES `lessons`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_prog_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. LESSON NOTES (Timestamped F8-style Notes)
CREATE TABLE `lesson_notes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `lesson_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `timestamp_seconds` INT NOT NULL DEFAULT 0,
  `note_text` TEXT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_note_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_note_lesson` FOREIGN KEY (`lesson_id`) REFERENCES `lessons`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_note_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. REVIEWS
CREATE TABLE `reviews` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `rating` TINYINT NOT NULL,
  `comment` TEXT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_review_user_course` (`user_id`, `course_id`),
  CONSTRAINT `fk_review_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_review_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 15. APP SETTINGS (Dynamic Site, Banking, Stripe & Gemini config in MySQL)
CREATE TABLE `app_settings` (
  `setting_key` VARCHAR(80) PRIMARY KEY,
  `setting_value` TEXT NOT NULL,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 16. PERSISTENT SHOPPING CART ITEMS
CREATE TABLE `cart_items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `added_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_cart_user_course` (`user_id`, `course_id`),
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cart_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 17. AI CHAT QUICK PROMPTS
CREATE TABLE `chat_quick_prompts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `context_type` ENUM('STOREFRONT', 'LEARN') NOT NULL,
  `prompt_text` VARCHAR(255) NOT NULL,
  `sort_order` INT NOT NULL DEFAULT 1,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 18. AI CHAT MESSAGES HISTORY
CREATE TABLE `chat_messages` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT DEFAULT NULL,
  `session_key` VARCHAR(100) NOT NULL,
  `course_id` INT DEFAULT NULL,
  `lesson_id` INT DEFAULT NULL,
  `role` ENUM('user', 'model') NOT NULL,
  `content` TEXT NOT NULL,
  `model_used` VARCHAR(80) DEFAULT '',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_chat_user_ctx` (`user_id`, `course_id`, `created_at`),
  INDEX `idx_chat_session_ctx` (`session_key`, `course_id`, `created_at`),
  CONSTRAINT `fk_chat_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_chat_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 19. PAYMENT TRANSACTIONS LEDGER
CREATE TABLE `payment_transactions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `order_id` INT NOT NULL,
  `gateway` VARCHAR(40) NOT NULL,
  `transaction_ref` VARCHAR(160) DEFAULT NULL,
  `amount` DECIMAL(12,0) NOT NULL DEFAULT 0,
  `status` ENUM('INITIATED', 'SUCCEEDED', 'FAILED', 'CANCELLED') NOT NULL,
  `message` VARCHAR(400) DEFAULT '',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_pay_tx_order` (`order_id`, `created_at`),
  CONSTRAINT `fk_pay_tx_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================================
-- INITIAL MYSQL DATABASE DATA (Vietnamese Programming Academy)
-- Accounts:
--   Admin:   admin@courseshop.vn   / Admin@123
--   Student: student@courseshop.vn / Student@123
--   Student: linh@courseshop.vn    / Student@123
-- ==========================================================

INSERT INTO `users` (`id`, `full_name`, `email`, `phone`, `password_hash`, `role`, `status`) VALUES
(1, 'Nguyễn Hoàng Nam', 'admin@courseshop.vn', '0901234567', 'pbkdf2:100000:oKhYGZ9IVSVC9pAEWdcCtw==:jiILzXNkr2cE1UShyb0JSMxkTsdBqvuaePG+zsEE7/I=', 'ADMIN', 1),
(2, 'Trần Minh Khôi', 'student@courseshop.vn', '0912345678', 'pbkdf2:100000:EXoLYePioQgT0GMg8zftWA==:GNdld0vowhNEutOchiUS2/weOYqwBkCWKBv88Sxk5go=', 'USER', 1),
(3, 'Lê Khánh Linh', 'linh@courseshop.vn', '0987654321', 'pbkdf2:100000:IGT4vkkB3H5fAhs06iGz/w==:Q8L/RlssKhSENINiio7CrsmRCOa6WUIhVWhBtogIC6o=', 'USER', 1);

INSERT INTO `categories` (`id`, `name`, `slug`, `description`) VALUES
(1, 'Nền tảng Web', 'nen-tang-web', 'HTML5, CSS3, Responsive, Tailwind CSS và tư duy giao diện thực tế'),
(2, 'JavaScript & Frontend', 'javascript-frontend', 'JavaScript ES6+, DOM, TypeScript, React và kiến trúc SPA hiện đại'),
(3, 'Java Backend', 'java-backend', 'Java Core, Jakarta EE Servlet/JSP, JDBC, Spring Boot và Microservices'),
(4, 'Cơ sở dữ liệu & SQL', 'co-so-du-lieu-sql', 'Thiết kế CSDL quan hệ, tối ưu truy vấn MySQL/PostgreSQL và Transaction'),
(5, 'AI & Triển khai Production', 'ai-devops', 'Tích hợp Gemini API, Docker, CI/CD và chuẩn kỹ sư thực chiến');

INSERT INTO `courses`
(`id`, `category_id`, `code`, `title`, `slug`, `short_desc`, `description`, `outcomes_text`, `instructor_name`, `thumbnail`, `price`, `sale_price`, `is_pro`, `level`, `status`) VALUES
-- 4 FREE FOUNDATION COURSES
(1, 1, 'LAB-01', 'HTML5, CSS3 & Responsive từ Zero', 'html-css-responsive-tu-zero',
 'Nắm vững cấu trúc ngữ nghĩa HTML5, Flexbox, CSS Grid và kỹ thuật dựng giao diện đa thiết bị chuẩn chỉnh cho người mới bắt đầu.',
 'Khóa học nền tảng mở miễn phí 100% giúp sinh viên CNTT xây dựng tư duy layout bài bản thay vì học vẹt thuộc tính. Bạn sẽ tự tay cắt 2 trang web hoàn chỉnh từ bản thiết kế và kiểm tra hiển thị trên cả Mobile lẫn Desktop.',
 'Hiểu sâu Box Model, Flexbox và CSS Grid thực chiến\nTự xây dựng giao diện chuẩn Responsive từ 375px đến 1440px\nTổ chức CSS sạch bằng biến tùy chỉnh (CSS Custom Properties)\nBiết cách kiểm tra tương phản và khả năng truy cập cơ bản',
 'ThS. Phạm Minh Quân', 'assets/images/courses/lab-01.png', 0, NULL, 0, 'BEGINNER', 'PUBLISHED'),

(2, 2, 'LAB-02', 'JavaScript ES6+, DOM & Fetch API', 'javascript-es6-dom-fetch-api',
 'Làm chủ tư duy lập trình bất đồng bộ, thao tác DOM gọn sạch và gọi REST API thực tế bằng JavaScript thuần.',
 'Bước đệm quan trọng trước khi học React hay Alpine.js. Bạn sẽ hiểu cơ chế Event Loop, Promise, Async/Await và tự viết các tương tác giỏ hàng, lọc dữ liệu và gọi API JSON không phụ thuộc thư viện nặng.',
 'Thành thạo ES6+: Destructuring, Spread, Modules, Arrow Function\nThao tác DOM, xử lý sự kiện và quản lý state phía trình duyệt\nGọi REST API an toàn với Fetch API và Async/Await\nBiết cách debug hiệu quả bằng Chrome DevTools',
 'ThS. Phạm Minh Quân', 'assets/images/courses/lab-02.png', 0, NULL, 0, 'BEGINNER', 'PUBLISHED'),

(3, 4, 'LAB-03', 'Thiết kế MySQL & Truy vấn Thực chiến', 'thiet-ke-mysql-truy-van-thuc-chien',
 'Học chuẩn hóa ERD, khóa ngoại, JOIN nhiều bảng, Index và Transaction cho hệ thống thương mại điện tử.',
 'Khóa học miễn phí tập trung vào các bài toán CSDL sinh viên hay vấp phải khi làm đồ án: thiết kế quan hệ nhiều-nhiều, tránh lặp dữ liệu, viết câu lệnh tổng hợp báo cáo doanh thu và đảm bảo toàn vẹn giao dịch.',
 'Thiết kế sơ đồ ERD chuẩn 3NF cho web bán hàng và E-Learning\nViết thành thạo JOIN, GROUP BY, Subquery và Window Function cơ bản\nHiểu Index để tăng tốc độ tìm kiếm và phân trang SQL\nÁp dụng Transaction (COMMIT / ROLLBACK) khi thanh toán',
 'KS. Đặng Quốc Bảo', 'assets/images/courses/lab-03.png', 0, NULL, 0, 'BEGINNER', 'PUBLISHED'),

(4, 3, 'LAB-04', 'Java 21 Core & Tư duy Hướng đối tượng', 'java-21-core-oop-nen-tang',
 'Ôn chắc OOP, Collections, Stream API, Record và Exception Handling trên Java 21 LTS trước khi lên Java Web.',
 'Giáo trình súc tích dành cho sinh viên CNTT cần hệ thống hóa kiến thức Java 21 hiện đại: sử dụng Record, Switch Expression, Try-with-resources và cấu trúc phân lớp gọn gàng để làm Backend.',
 'Nắm vững 4 tính chất OOP qua bài toán quản lý thực tế\nSử dụng thành thạo List, Map, Set, Stream API và Optional\nViết code hiện đại với Java 21 Record và Pattern Matching\nQuản lý tài nguyên an toàn bằng try-with-resources',
 'KS. Nguyễn Hoàng Nam', 'assets/images/courses/lab-04.png', 0, NULL, 0, 'BEGINNER', 'PUBLISHED'),

-- 8 PRO PAID COURSES
(5, 3, 'PRO-01', 'Java Web Jakarta EE 10, MVC & Thanh toán Stripe', 'java-web-jakarta-ee-stripe-pro',
 'Xây dựng hoàn chỉnh hệ thống E-Commerce & E-Learning bằng Servlet, JSP/JSTL, JDBC Transaction và cổng Stripe Checkout.',
 'Khóa học Pro trọng tâm giúp bạn hiểu bản chất Web Server (Tomcat 10.1), vòng đời Servlet/Filter, phân quyền RBAC, băm mật khẩu PBKDF2, upload ảnh @MultipartConfig và tích hợp Stripe Checkout API qua Java HttpClient.',
 'Thiết kế kiến trúc MVC + DAO sạch sẽ, không rò rỉ Connection\nCài đặt xác thực mật khẩu PBKDF2 và phân quyền AuthFilter/AdminFilter\nTích hợp thanh toán Stripe Checkout Session & xác minh phía Server\nHoàn thiện đồ án thương mại điện tử sẵn sàng bảo vệ và đưa vào CV',
 'KS. Nguyễn Hoàng Nam', 'assets/images/courses/pro-01.png', 1990000, 1290000, 1, 'INTERMEDIATE', 'PUBLISHED'),

(6, 3, 'PRO-02', 'Spring Boot 3, REST API & Bảo mật JWT', 'spring-boot-3-rest-api-jwt-pro',
 'Từ Jakarta EE bước lên Spring Boot 3 thực chiến: Spring Data JPA, Validation, JWT Refresh Token và OpenAPI Swagger.',
 'Chương trình đào tạo sát tiêu chuẩn tuyển dụng Fresher/Junior Java Backend tại doanh nghiệp. Bạn sẽ xây dựng hệ thống Backend RESTful có phân tầng DTO, xử lý ngoại lệ tập trung và kiểm thử tự động.',
 'Làm chủ Spring IoC, Dependency Injection và Spring Data JPA\nXây dựng xác thực Spring Security 6 + JWT Access/Refresh Token\nChuẩn hóa Response API, GlobalExceptionHandler và Validation\nViết Integration Test và xuất tài liệu Swagger/OpenAPI',
 'KS. Nguyễn Hoàng Nam', 'assets/images/courses/pro-02.png', 2290000, 1490000, 1, 'INTERMEDIATE', 'PUBLISHED'),

(7, 1, 'PRO-03', 'Tailwind CSS v4, Alpine.js & Thiết kế UI Production', 'tailwind-v4-alpine-ui-production-pro',
 'Tạm biệt template Bootstrap mặc định: xây dựng Design System tùy biến bằng Tailwind v4 @theme và tương tác mượt với Alpine.js.',
 'Dành cho lập trình viên muốn sản phẩm của mình có thẩm mỹ đạt chuẩn xuất bản. Học cách chọn bảng màu đạt chuẩn WCAG AA, hệ chữ tiếng Việt sắc nét, bảng dữ liệu thẳng hàng số liệu và micro-interaction tinh tế.',
 'Xây dựng Design Tokens chuẩn hóa với Tailwind CSS v4 @theme\nThiết kế layout phức tạp: Dashboard, Video Player, Drawer, Modal\nKết hợp Alpine.js 3 cho trang Server-Rendered (JSP/Thymeleaf)\nKiểm định Responsive và Accessibility trên mọi khung hình',
 'ThS. Phạm Minh Quân', 'assets/images/courses/pro-03.png', 1490000, 990000, 1, 'INTERMEDIATE', 'PUBLISHED'),

(8, 2, 'PRO-04', 'React 19, TypeScript & Kiến trúc Frontend Thực chiến', 'react-19-typescript-thuc-chien-pro',
 'Làm chủ React hiện đại kết hợp TypeScript chặt chẽ, TanStack Query, quản lý form và tối ưu hiệu năng render.',
 'Khóa học giúp bạn vượt qua giai đoạn viết React tự phát để tổ chức dự án quy mô lớn: tách custom hook hợp lý, gọi API cache thông minh, xử lý loading/error state mượt mà và đóng gói tối ưu.',
 'Sử dụng TypeScript chuẩn chỉnh cho Props, State và API Schema\nQuản lý Server State chuyên nghiệp với TanStack Query\nTối ưu hóa tốc độ tải trang, Code Splitting và Memoization\nXây dựng dự án quản lý học tập SPA hoàn chỉnh',
 'KS. Võ Thanh Tùng', 'assets/images/courses/pro-04.png', 1890000, 1190000, 1, 'INTERMEDIATE', 'PUBLISHED'),

(9, 5, 'PRO-05', 'Tích hợp Google Gemini AI & Xây dựng Chatbot RAG', 'tich-hop-gemini-ai-chatbot-rag-pro',
 'Ứng dụng Google AI Studio API vào ứng dụng Web thực tế: bảo mật API key ở Backend, nhúng dữ liệu DB và xây dựng trợ giảng AI.',
 'Biến ứng dụng web truyền thống thành sản phẩm thông minh có khả năng tư vấn dữ liệu thật từ MySQL, nhớ hội thoại nhiều lượt, kiểm soát hallucination và xử lý fallback an toàn khi vượt quota.',
 'Gọi Gemini REST API trực tiếp từ Java/Node Backend an toàn\nKỹ thuật Mini-RAG cấp ngữ cảnh dữ liệu thật từ MySQL cho AI\nQuản lý hội thoại multi-turn và thiết kế giao diện Chat Widget mượt\nXử lý giới hạn quota (429), timeout và cấu hình đổi model linh hoạt',
 'KS. Nguyễn Hoàng Nam', 'assets/images/courses/pro-05.png', 1590000, 1090000, 1, 'INTERMEDIATE', 'PUBLISHED'),

(10, 4, 'PRO-06', 'Tối ưu MySQL & Hiệu năng Hệ thống Chịu tải cao', 'toi-uu-mysql-hieu-nang-cao-pro',
 'Phân tích EXPLAIN, thiết kế Composite Index, tránh Deadlock và tối ưu truy vấn cho hệ thống triệu bản ghi.',
 'Đi sâu vào cơ chế lưu trữ InnoDB, B-Tree Index, cô lập giao dịch (Isolation Levels) và cách đọc query plan để đưa câu lệnh chậm 3 giây xuống dưới 20ms.',
 'Đọc hiểu EXPLAIN ANALYZE và tối ưu Composite Index đúng thứ tự\nGiải quyết bài toán N+1 query và phân trang sâu (Keyset Pagination)\nXử lý tranh chấp dữ liệu thanh toán với SELECT ... FOR UPDATE\nThiết lập sao lưu, phục hồi và giám sát slow query log',
 'KS. Đặng Quốc Bảo', 'assets/images/courses/pro-06.png', 1690000, 1190000, 1, 'ADVANCED', 'PUBLISHED'),

(11, 5, 'PRO-07', 'Docker, Nginx & Triển khai Java Web lên VPS', 'docker-nginx-deploy-java-vps-pro',
 'Đóng gói ứng dụng Tomcat/Spring Boot + MySQL bằng Docker Compose, cấu hình Reverse Proxy Nginx và SSL HTTPS miễn phí.',
 'Hoàn thiện mảnh ghép cuối cùng của kỹ sư đi làm: đưa ứng dụng từ localhost lên tên miền thật an toàn, tự động build/deploy với GitHub Actions và giám sát log vận hành.',
 'Viết Dockerfile Multi-stage gọn nhẹ cho ứng dụng Java 21\nĐiều phối App + MySQL + Redis bằng Docker Compose\nCấu hình Nginx Reverse Proxy và chứng chỉ HTTPS Let''s Encrypt\nThiết lập quy trình CI/CD tự động mỗi khi push code',
 'KS. Đặng Quốc Bảo', 'assets/images/courses/pro-07.png', 1490000, 890000, 1, 'ADVANCED', 'PUBLISHED'),

(12, 3, 'PRO-08', 'Kiến trúc Microservices & Hệ thống Thanh toán Phân tán', 'microservices-he-thong-thanh-toan-pro',
 'Thiết kế dịch vụ tách biệt, Message Queue, Idempotency Key và xử lý giao dịch tin cậy cho sản phẩm quy mô doanh nghiệp.',
 'Khóa học nâng cao dành cho lập trình viên muốn bứt phá lên vị trí Middle Backend Engineer: hiểu rõ ranh giới dịch vụ, giao tiếp bất đồng bộ và thiết kế cơ chế chống thanh toán trùng lặp.',
 'Phân tách Monolith sang Microservices đúng ranh giới nghiệp vụ\nÁp dụng Idempotency và Outbox Pattern cho đơn hàng & thanh toán\nTriển khai API Gateway, Rate Limiting và Distributed Tracing\nThực hành kiểm thử chịu tải và xử lý sự cố thực tế',
 'KS. Nguyễn Hoàng Nam', 'assets/images/courses/pro-08.png', 2490000, 1790000, 1, 'ADVANCED', 'PUBLISHED');

-- 3 LEARNING PATHS
INSERT INTO `learning_paths` (`id`, `title`, `slug`, `summary`, `target_role`, `icon`, `sort_order`) VALUES
(1, 'Lộ trình Fullstack Web', 'fullstack-web', 'Đi từ nền tảng HTML/CSS, JavaScript miễn phí lên dự án Java Web thương mại điện tử tích hợp thanh toán Stripe & AI Chatbot.', 'Junior Fullstack Developer', 'layers', 1),
(2, 'Java Backend Engineer', 'java-backend', 'Chuyên sâu hệ sinh thái Java 21, MySQL, Jakarta EE, Spring Boot 3 và triển khai Docker chuẩn doanh nghiệp.', 'Junior Java Backend', 'server', 2),
(3, 'Frontend UI & React', 'frontend-react', 'Làm chủ HTML/CSS Responsive, JavaScript ES6+, Tailwind CSS v4 Design System và React 19 TypeScript.', 'Junior Frontend Developer', 'layout-grid', 3);

INSERT INTO `learning_path_courses` (`path_id`, `course_id`, `step_order`) VALUES
(1, 1, 1), (1, 2, 2), (1, 5, 3), (1, 9, 4),
(2, 4, 1), (2, 3, 2), (2, 5, 3), (2, 6, 4), (2, 11, 5),
(3, 1, 1), (3, 2, 2), (3, 7, 3), (3, 8, 4);

-- SECTIONS & LESSONS (Real embeddable public educational programming YouTube videos)
INSERT INTO `sections` (`id`, `course_id`, `title`, `sort_order`) VALUES
(1, 1, 'Chương 1: Cấu trúc HTML5 ngữ nghĩa & Box Model', 1),
(2, 1, 'Chương 2: Flexbox, CSS Grid & Responsive thực chiến', 2),
(3, 2, 'Chương 1: JavaScript ES6+ & Tư duy hàm hiện đại', 1),
(4, 2, 'Chương 2: DOM, Sự kiện & Fetch API bất đồng bộ', 2),
(5, 3, 'Chương 1: Thiết kế ERD & Quan hệ chuẩn hóa', 1),
(6, 3, 'Chương 2: JOIN, Tổng hợp & Transaction thanh toán', 2),
(7, 4, 'Chương 1: Java 21 OOP, Record & Collections', 1),
(8, 4, 'Chương 2: Stream API & Xử lý ngoại lệ an toàn', 2),
(9, 5, 'Chương 1: Kiến trúc Jakarta EE 10, Servlet & JDBC chuẩn', 1),
(10, 5, 'Chương 2: Xác thực PBKDF2, Filter & Giỏ hàng Session', 2),
(11, 5, 'Chương 3: Tích hợp Stripe Checkout & JDBC Transaction', 3),
(12, 6, 'Chương 1: Khởi tạo Spring Boot 3 & Spring Data JPA', 1),
(13, 6, 'Chương 2: Spring Security 6, JWT & OpenAPI', 2),
(14, 7, 'Chương 1: Design Tokens với Tailwind CSS v4 @theme', 1),
(15, 7, 'Chương 2: Xây dựng Modal, Drawer & Tabs với Alpine.js 3', 2),
(16, 8, 'Chương 1: React 19 + TypeScript nền tảng chặt chẽ', 1),
(17, 8, 'Chương 2: TanStack Query & Kiến trúc Production', 2),
(18, 9, 'Chương 1: Kết nối Google AI Studio Gemini API từ Backend', 1),
(19, 9, 'Chương 2: Mini-RAG từ MySQL & Multi-turn Chat Widget', 2),
(20, 10, 'Chương 1: Cơ chế B-Tree Index & EXPLAIN ANALYZE', 1),
(21, 11, 'Chương 1: Dockerfile Multi-stage & Docker Compose', 1),
(22, 12, 'Chương 1: Thiết kế ranh giới Microservices & Idempotency', 1);

INSERT INTO `lessons` (`id`, `section_id`, `course_id`, `title`, `video_url`, `duration_seconds`, `content_text`, `is_preview`, `sort_order`) VALUES
-- Course 1 (LAB-01)
(1, 1, 1, 'Giới thiệu lộ trình HTML5 & Cách trình duyệt render trang web', 'https://www.youtube.com/watch?v=qz0aGYrrlhU', 840, 'Tổng quan cách trình duyệt phân tích DOM Tree, CSSOM và vai trò của thẻ ngữ nghĩa header, main, nav, article, section.', 1, 1),
(2, 1, 1, 'Hiểu bản chất Box Model: Padding, Border, Margin & box-sizing', 'https://www.youtube.com/watch?v=rIO5326FgPE', 920, 'Cách dùng box-sizing: border-box để tính toán kích thước phần tử chính xác và tránh lỗi vỡ khung ngang.', 1, 2),
(3, 2, 1, 'Làm chủ Flexbox cho thanh điều hướng và thẻ sản phẩm', 'https://www.youtube.com/watch?v=fYq5PXgSsbE', 1140, 'Áp dụng display: flex, gap, align-items và justify-content để dựng thanh navbar và bố cục 2 cột linh hoạt.', 0, 3),
(4, 2, 1, 'CSS Grid 12 cột & Media Queries chuẩn 375px → 1440px', 'https://www.youtube.com/watch?v=9zBsdzdE4sM', 1280, 'Xây dựng lưới khóa học tự co giãn 1 cột trên điện thoại, 2 cột tablet và 4 cột màn hình lớn.', 0, 4),

-- Course 2 (LAB-02)
(5, 3, 2, 'Biến let/const, Scope & Arrow Function trong ES6+', 'https://www.youtube.com/watch?v=W6NZfCO5SIk', 960, 'Phân biệt block scope, hoisting và cách viết hàm ngắn gọn dễ đọc trong dự án thực tế.', 1, 1),
(6, 3, 2, 'Array Methods: map, filter, reduce cho dữ liệu giỏ hàng', 'https://www.youtube.com/watch?v=R8rmfD9Y5-c', 1080, 'Thực hành tính tổng tiền giỏ hàng, lọc danh sách khóa học theo trình độ bằng map/filter/reduce.', 0, 2),
(7, 4, 2, 'Thao tác DOM hiện đại & Event Delegation', 'https://www.youtube.com/watch?v=5fb2aPlgoys', 1120, 'Bắt sự kiện sạch cho các phần tử động, modal và phím tắt Escape.', 0, 3),
(8, 4, 2, 'Fetch API, Async/Await & Xử lý JSON từ Java Servlet', 'https://www.youtube.com/watch?v=cuEtnrL9-H0', 1020, 'Gửi request POST JSON tới endpoint /api/progress và cập nhật giao diện không cần tải lại trang.', 0, 4),

-- Course 3 (LAB-03)
(9, 5, 3, 'Phân tích bài toán E-Learning & vẽ ERD chuẩn 3NF', 'https://www.youtube.com/watch?v=HXV3zeQKqGY', 1200, 'Tách bảng courses, sections, lessons, orders, order_items và enrollments để đảm bảo dữ liệu nhất quán.', 1, 1),
(10, 5, 3, 'Khóa ngoại Foreign Key, UNIQUE & ON DELETE CASCADE', 'https://www.youtube.com/watch?v=7S_tz1z_5bA', 980, 'Ngăn chặn học viên sở hữu trùng 1 khóa học bằng UNIQUE(user_id, course_id).', 0, 2),
(11, 6, 3, 'INNER JOIN, LEFT JOIN & Báo cáo doanh thu Dashboard', 'https://www.youtube.com/watch?v=9yeOJ0ZMUYw', 1150, 'Viết truy vấn thống kê tổng doanh thu, đếm số bài học và tính điểm trung bình đánh giá.', 0, 3),
(12, 6, 3, 'Transaction, Row Lock FOR UPDATE & Chống ghi đè', 'https://www.youtube.com/watch?v=P80JsX37g2w', 1060, 'Đảm bảo cập nhật đơn PAID và tạo enrollment cùng thành công hoặc cùng rollback.', 0, 4),

-- Course 4 (LAB-04)
(13, 7, 4, 'Java 21 LTS: Cài đặt, Record & Switch Expression', 'https://www.youtube.com/watch?v=eIrMbAQSU34', 1050, 'Sử dụng Java 21 Record để tạo DTO phản hồi API gọn gàng, bất biến và an toàn kiểu.', 1, 1),
(14, 7, 4, 'Collections Framework: List, Set, Map thực chiến', 'https://www.youtube.com/watch?v=viTHc_4XfCA', 1180, 'Chọn LinkedHashMap cho giỏ hàng giữ đúng thứ tự và HashSet để tra cứu khóa đã sở hữu O(1).', 0, 2),
(15, 8, 4, 'Try-with-resources & Quản lý JDBC không rò rỉ kết nối', 'https://www.youtube.com/watch?v=1XAfapkBQjk', 940, 'Đóng tự động Connection, PreparedStatement và ResultSet kể cả khi gặp SQLException.', 0, 3),

-- Course 5 (PRO-01)
(16, 9, 5, 'Kiến trúc Jakarta EE 10, Tomcat 10.1 & Maven WAR', 'https://www.youtube.com/watch?v=OuBUUkQfBYM', 1140, 'Phân biệt namespace jakarta.servlet với javax.servlet cũ và cấu hình Maven chuẩn cho Tomcat 10.1.', 1, 1),
(17, 9, 5, 'Xây dựng tầng DAO với SQL Filter, Search & Pagination', 'https://www.youtube.com/watch?v=7v2OnUjrDkY', 1420, 'Viết PreparedStatement động cho tìm kiếm từ khóa, lọc danh mục, trình độ và phân trang LIMIT/OFFSET.', 1, 2),
(18, 10, 5, 'Băm mật khẩu PBKDF2WithHmacSHA256 & AuthFilter / AdminFilter', 'https://www.youtube.com/watch?v=8ZtInClXe1Q', 1360, 'Bảo vệ mật khẩu bằng PBKDF2 có salt ngẫu nhiên và chặn truy cập trái phép vào /admin/*.', 0, 3),
(19, 10, 5, 'Giỏ hàng Session, Kiểm tra khóa đã sở hữu & Mã giảm giá', 'https://www.youtube.com/watch?v=BGTx91t8q50', 1290, 'Xây dựng giỏ hàng sạch cho sản phẩm số (mỗi khóa số lượng 1) và tính giảm giá Coupon phía server.', 0, 4),
(20, 11, 5, 'Tích hợp Stripe Checkout Session API bằng Java 21 HttpClient', 'https://www.youtube.com/watch?v=1r-F3FIONl8', 1580, 'Gọi POST /v1/checkout/sessions với đơn vị tiền zero-decimal VND và xác minh lại session_id khi redirect về.', 0, 5),
(21, 11, 5, 'Transaction cấp quyền Enrollment & Trang học /learn chuẩn F8', 'https://www.youtube.com/watch?v=35EQXmHKZYs', 1460, 'Thực thi JDBC Transaction mở khóa học và xây API lưu tiến độ + ghi chú theo timestamp.', 0, 6),

-- Course 6 (PRO-02)
(22, 12, 6, 'Khởi tạo Spring Boot 3, Auto-Configuration & Spring Data JPA', 'https://www.youtube.com/watch?v=9SGDpanrc8U', 1320, 'Cấu trúc tầng Controller, Service, Repository và mapping Entity với MySQL.', 1, 1),
(23, 12, 6, 'Validation, DTO & GlobalExceptionHandler chuẩn REST', 'https://www.youtube.com/watch?v=vtPkZShrvXQ', 1240, 'Chuẩn hóa mã lỗi JSON và xác thực dữ liệu đầu vào với Jakarta Validation.', 0, 2),
(24, 13, 6, 'Spring Security 6 + JWT Access & Refresh Token', 'https://www.youtube.com/watch?v=KxqlJblhzfI', 1640, 'Triển khai chuỗi filter xác thực không trạng thái bằng JWT và phân quyền theo vai trò.', 0, 3),

-- Course 7 (PRO-03)
(25, 14, 7, 'Tailwind CSS v4: @theme, @source & Design System không Bootstrap', 'https://www.youtube.com/watch?v=mr15Xzb1Ook', 1180, 'Định nghĩa bảng màu, font tự lưu trữ và biên dịch ra file CSS tĩnh siêu nhẹ cho Tomcat.', 1, 1),
(26, 15, 7, 'Tương tác UI tinh gọn với Alpine.js 3 trong JSP/JSTL', 'https://www.youtube.com/watch?v=r5iFrxi9-hY', 1260, 'Dựng Binder Tabs, Preview Modal, Accordion và Toast stack không xung đột cú pháp ${...}.', 0, 2),

-- Course 8 (PRO-04)
(27, 16, 8, 'React 19 + TypeScript: Component Pattern & Strict Typing', 'https://www.youtube.com/watch?v=SqcY0GlETPk', 1340, 'Tổ chức cây component, phân tách state hợp lý và khai báo kiểu dữ liệu an toàn.', 1, 1),
(28, 17, 8, 'TanStack Query: Caching, Optimistic UI & Phân trang mượt', 'https://www.youtube.com/watch?v=r8Dg0KVnfMA', 1410, 'Đồng bộ trạng thái server và xử lý skeleton/retry chuẩn sản phẩm.', 0, 2),

-- Course 9 (PRO-05)
(29, 18, 9, 'Gọi Google Gemini REST API từ Java Backend với x-goog-api-key', 'https://www.youtube.com/watch?v=Z4YFHQ9p8zI', 1220, 'Bảo mật tuyệt đối API key phía server và cấu hình system_instruction, generationConfig.', 1, 1),
(30, 19, 9, 'Mini-RAG từ MySQL & Giao diện Chat Widget hai ngữ cảnh', 'https://www.youtube.com/watch?v=T-D1OfcDW1M', 1480, 'Nhúng danh sách khóa học thực tế và bài học đang xem để Chatbot tư vấn chính xác không bịa đặt.', 0, 2),

-- Course 10 (PRO-06)
(31, 20, 10, 'Đọc EXPLAIN & Thiết kế Composite Index cho truy vấn lọc', 'https://www.youtube.com/watch?v=Hubezeee_Mg', 1380, 'Hiểu nguyên tắc Leftmost Prefix và tránh full table scan khi lọc khóa học.', 1, 1),

-- Course 11 (PRO-07)
(32, 21, 11, 'Dockerize Tomcat 10.1 + MySQL với Docker Compose & Nginx', 'https://www.youtube.com/watch?v=pg19Z8LL06w', 1440, 'Đóng gói file WAR và thiết lập reverse proxy HTTPS sẵn sàng chạy trên VPS.', 1, 1),

-- Course 12 (PRO-08)
(33, 22, 12, 'Idempotency Key & Outbox Pattern trong hệ thống thanh toán', 'https://www.youtube.com/watch?v=rv4LlmLmVWk', 1520, 'Đảm bảo người dùng bấm thanh toán 2 lần hoặc mạng lag không bao giờ bị trừ tiền trùng.', 1, 1);

-- COUPONS
INSERT INTO `coupons` (`id`, `code`, `discount_percent`, `max_discount`, `usage_limit`, `used_count`, `expired_at`, `status`, `stripe_coupon_id`) VALUES
(1, 'WELCOME15', 15, 250000, 500, 12, '2027-12-31 23:59:59', 1, 'WELCOME15'),
(2, 'SINHVIEN20', 20, 350000, 300, 8, '2027-12-31 23:59:59', 1, 'SINHVIEN20'),
(3, 'PRO500K', 25, 500000, 100, 3, '2027-06-30 23:59:59', 1, 'PRO500K');

-- HISTORICAL ORDERS
INSERT INTO `orders` (`id`, `order_code`, `user_id`, `coupon_id`, `subtotal`, `discount_amount`, `total_amount`, `payment_method`, `stripe_session_id`, `status`, `created_at`, `paid_at`) VALUES
(1, 'CS2611160912', 2, 1, 1290000, 193500, 1096500, 'STRIPE', 'cs_test_2611160912', 'PAID', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
(2, 'CS2611181420', 3, 2, 1490000, 298000, 1192000, 'STRIPE', 'cs_test_2611181420', 'PAID', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
(3, 'CS2611201605', 3, NULL, 990000, 0, 990000, 'STRIPE', 'cs_test_2611201605', 'PAID', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(4, 'CS2611211930', 2, NULL, 1090000, 0, 1090000, 'BANK_TRANSFER', NULL, 'PENDING', DATE_SUB(NOW(), INTERVAL 1 DAY), NULL);

INSERT INTO `order_items` (`order_id`, `course_id`, `unit_price`) VALUES
(1, 5, 1290000),
(2, 6, 1490000),
(3, 7, 990000),
(4, 9, 1090000);

-- SAMPLE ENROLLMENTS (Student 2 owns Free LAB-01 + Paid PRO-01; Student 3 owns Free LAB-01, LAB-02 + Paid PRO-02, PRO-03)
INSERT INTO `enrollments` (`user_id`, `course_id`, `order_id`, `enrolled_at`) VALUES
(2, 1, NULL, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(2, 5, 1, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(3, 1, NULL, DATE_SUB(NOW(), INTERVAL 6 DAY)),
(3, 2, NULL, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(3, 6, 2, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(3, 7, 3, DATE_SUB(NOW(), INTERVAL 2 DAY));

-- SAMPLE LESSON PROGRESS
INSERT INTO `lesson_progress` (`user_id`, `lesson_id`, `course_id`, `is_completed`) VALUES
(2, 1, 1, 1),
(2, 2, 1, 1),
(2, 16, 5, 1),
(2, 17, 5, 1),
(2, 18, 5, 1);

-- SAMPLE TIMESTAMP NOTES
INSERT INTO `lesson_notes` (`user_id`, `lesson_id`, `course_id`, `timestamp_seconds`, `note_text`) VALUES
(2, 16, 5, 145, 'Tomcat 10.1 bắt buộc dùng jakarta.servlet.* thay vì javax.servlet.*'),
(2, 16, 5, 420, 'Nhớ cấu hình Context path trong META-INF/context.xml và đóng kết nối JDBC bằng try-with-resources'),
(2, 17, 5, 290, 'Dùng PreparedStatement động để tránh SQL Injection khi lọc khóa học theo từ khóa');

-- SAMPLE REVIEWS
INSERT INTO `reviews` (`user_id`, `course_id`, `rating`, `comment`, `created_at`) VALUES
(2, 1, 5, 'Bài giảng giải thích Flexbox và CSS Grid rất dễ hiểu, cắt lại được giao diện Responsive ngay buổi đầu.', DATE_SUB(NOW(), INTERVAL 4 DAY)),
(3, 1, 5, 'Khóa miễn phí nhưng chất lượng cực kỳ chỉn chu, rất phù hợp cho sinh viên năm 1-2.', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(2, 5, 5, 'Phần tích hợp Stripe Checkout và phân quyền Filter giải thích cặn kẽ, áp dụng thẳng vào đồ án tốt nghiệp được luôn!', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(3, 6, 5, 'Lộ trình đi từ Jakarta EE lên Spring Boot 3 rất mạch lạc, phần JWT dễ nắm bắt.', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(3, 7, 4, 'Tailwind v4 kết hợp Alpine.js giúp bỏ hoàn toàn Bootstrap, giao diện trông chuyên nghiệp hẳn.', DATE_SUB(NOW(), INTERVAL 1 DAY));

-- DEFAULT APP SETTINGS (100% stored in MySQL & editable in /admin/settings)
INSERT INTO `app_settings` (`setting_key`, `setting_value`) VALUES
('site.name', 'CourseShop'),
('site.short_name', 'CourseShop'),
('site.tagline', 'Nền tảng học lập trình thực chiến theo lộ trình dành cho sinh viên CNTT và người mới chuyển ngành. Bắt đầu từ giáo trình miễn phí 0đ, tiến tới xây dựng dự án hoàn chỉnh.'),
('site.hero_title', 'Học lập trình theo lộ trình bài bản, làm ra sản phẩm thật'),
('site.hero_subtitle', 'Lộ trình lập trình dành cho sinh viên CNTT và người mới chuyển ngành: bắt đầu với các khóa nền tảng miễn phí 0đ, sau đó thực hành dự án thực tế cùng Trợ giảng AI.'),
('site.support_email', 'support@courseshop.vn'),
('site.hotline', '1900 6868'),
('site.address', 'Tầng 6, Khu Công nghệ phần mềm, Hà Nội'),
('bank.name', 'Vietcombank — Chi nhánh Hà Nội'),
('bank.account_number', '0123 4567 8999'),
('bank.account_holder', 'COURSESHOP EDUCATION LAB'),
('stripe.secret_key', ''),
('stripe.publishable_key', ''),
('stripe.webhook_secret', ''),
('gemini.api_key', ''),
('gemini.model', 'gemini-3.8-flash');

-- FEATURED DISPLAY ORDER IN MYSQL (Free + Pro progression)
UPDATE `courses` SET `featured_order` = 1 WHERE `code` = 'LAB-01';
UPDATE `courses` SET `featured_order` = 2 WHERE `code` = 'LAB-02';
UPDATE `courses` SET `featured_order` = 3 WHERE `code` = 'PRO-01';
UPDATE `courses` SET `featured_order` = 4 WHERE `code` = 'PRO-02';
UPDATE `courses` SET `featured_order` = 5 WHERE `code` = 'LAB-03';
UPDATE `courses` SET `featured_order` = 6 WHERE `code` = 'PRO-03';
UPDATE `courses` SET `featured_order` = 7 WHERE `code` = 'LAB-04';
UPDATE `courses` SET `featured_order` = 8 WHERE `code` = 'PRO-04';
UPDATE `courses` SET `featured_order` = 9 WHERE `code` = 'PRO-05';
UPDATE `courses` SET `featured_order` = 10 WHERE `code` = 'PRO-06';
UPDATE `courses` SET `featured_order` = 11 WHERE `code` = 'PRO-07';
UPDATE `courses` SET `featured_order` = 12 WHERE `code` = 'PRO-08';

-- STRIPE PRODUCT IDS FOR PRO COURSES (PRO-01 -> PRO-08)
UPDATE `courses` SET `stripe_product_id` = 'prod_Vg8M87HqPoL7yK' WHERE `code` = 'PRO-01';
UPDATE `courses` SET `stripe_product_id` = 'prod_Vg8MOnWDl3Gr0U' WHERE `code` = 'PRO-02';
UPDATE `courses` SET `stripe_product_id` = 'prod_Vg8NOktDF5yWZu' WHERE `code` = 'PRO-03';
UPDATE `courses` SET `stripe_product_id` = 'prod_Vg8NUdNgtqXKZv' WHERE `code` = 'PRO-04';
UPDATE `courses` SET `stripe_product_id` = 'prod_Vg8NE7JBcNe6tK' WHERE `code` = 'PRO-05';
UPDATE `courses` SET `stripe_product_id` = 'prod_Vg8OGI9zCzxK1H' WHERE `code` = 'PRO-06';
UPDATE `courses` SET `stripe_product_id` = 'prod_Vg8OZ9FBeqdq6a' WHERE `code` = 'PRO-07';
UPDATE `courses` SET `stripe_product_id` = 'prod_Vg8Pu7FQGK7Ml4' WHERE `code` = 'PRO-08';

-- AI CHAT QUICK PROMPTS IN MYSQL
INSERT INTO `chat_quick_prompts` (`context_type`, `prompt_text`, `sort_order`, `is_active`) VALUES
('STOREFRONT', 'Tôi mới bắt đầu nên học khóa miễn phí nào?', 1, 1),
('STOREFRONT', 'Lộ trình Java Backend gồm những khóa nào?', 2, 1),
('STOREFRONT', 'Có mã giảm giá nào đang áp dụng không?', 3, 1),
('LEARN', 'Tóm tắt ý chính của bài học này', 1, 1),
('LEARN', 'Cho ví dụ code minh họa dễ hiểu', 2, 1),
('LEARN', 'Những lỗi hay gặp ở phần này?', 3, 1);

-- HISTORICAL PAYMENT TRANSACTIONS LEDGER
INSERT INTO `payment_transactions` (`order_id`, `gateway`, `transaction_ref`, `amount`, `status`, `message`, `created_at`) VALUES
(1, 'STRIPE', 'cs_test_2611160912', 1096500, 'SUCCEEDED', 'Thanh toán thành công qua Stripe và đã kích hoạt khóa học.', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(2, 'STRIPE', 'cs_test_2611181420', 1192000, 'SUCCEEDED', 'Thanh toán thành công qua Stripe và đã kích hoạt khóa học.', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(3, 'STRIPE', 'cs_test_2611201605', 990000, 'SUCCEEDED', 'Thanh toán thành công qua Stripe và đã kích hoạt khóa học.', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(4, 'BANK_TRANSFER', 'CS2611211930', 1090000, 'INITIATED', 'Đơn chuyển khoản ngân hàng đang chờ xác nhận.', DATE_SUB(NOW(), INTERVAL 1 DAY));


-- ============================================================================
-- V2 EXTENSION TABLES (P0 + P1 + P2)
-- ============================================================================
ALTER TABLE `enrollments` ADD COLUMN IF NOT EXISTS `last_lesson_id` INT DEFAULT NULL;

CREATE TABLE IF NOT EXISTS `password_reset_tokens` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `token_hash` VARCHAR(128) NOT NULL UNIQUE,
  `expires_at` DATETIME NOT NULL,
  `used_at` DATETIME DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_prt_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_prt_user` (`user_id`),
  INDEX `idx_prt_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `certificates` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `certificate_code` VARCHAR(32) NOT NULL UNIQUE,
  `user_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `issued_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_cert_user_course` (`user_id`, `course_id`),
  CONSTRAINT `fk_cert_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cert_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `quizzes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `course_id` INT NOT NULL,
  `section_id` INT DEFAULT NULL,
  `lesson_id` INT DEFAULT NULL,
  `title` VARCHAR(220) NOT NULL,
  `description` VARCHAR(500) DEFAULT '',
  `pass_score` INT NOT NULL DEFAULT 70,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_quiz_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_quiz_section` FOREIGN KEY (`section_id`) REFERENCES `sections`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_quiz_lesson` FOREIGN KEY (`lesson_id`) REFERENCES `lessons`(`id`) ON DELETE SET NULL,
  INDEX `idx_quiz_course` (`course_id`),
  INDEX `idx_quiz_section` (`section_id`),
  INDEX `idx_quiz_lesson` (`lesson_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `quiz_questions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `quiz_id` INT NOT NULL,
  `question_text` TEXT NOT NULL,
  `option_a` VARCHAR(500) NOT NULL,
  `option_b` VARCHAR(500) NOT NULL,
  `option_c` VARCHAR(500) NOT NULL,
  `option_d` VARCHAR(500) NOT NULL,
  `correct_option` CHAR(1) NOT NULL DEFAULT 'A',
  `explanation` TEXT,
  `sort_order` INT NOT NULL DEFAULT 1,
  CONSTRAINT `fk_qq_quiz` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes`(`id`) ON DELETE CASCADE,
  INDEX `idx_qq_quiz` (`quiz_id`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `quiz_attempts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `quiz_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `score_percent` INT NOT NULL DEFAULT 0,
  `correct_count` INT NOT NULL DEFAULT 0,
  `total_questions` INT NOT NULL DEFAULT 0,
  `passed` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_qa_quiz` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_qa_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_qa_user_quiz` (`user_id`, `quiz_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `lesson_exercises` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `lesson_id` INT NOT NULL UNIQUE,
  `course_id` INT NOT NULL,
  `title` VARCHAR(220) NOT NULL,
  `prompt_text` TEXT NOT NULL,
  `language` VARCHAR(32) NOT NULL DEFAULT 'html',
  `starter_code` TEXT,
  `expected_tokens` TEXT,
  `hint_text` TEXT,
  `solution_code` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_lex_lesson` FOREIGN KEY (`lesson_id`) REFERENCES `lessons`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_lex_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `lesson_exercise_submissions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `exercise_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `submitted_code` TEXT NOT NULL,
  `passed` TINYINT(1) NOT NULL DEFAULT 0,
  `feedback` VARCHAR(500) DEFAULT '',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_les_user_ex` (`user_id`, `exercise_id`),
  CONSTRAINT `fk_les_ex` FOREIGN KEY (`exercise_id`) REFERENCES `lesson_exercises`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_les_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `lesson_discussions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `lesson_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `parent_id` INT DEFAULT NULL,
  `content` TEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_ld_lesson` FOREIGN KEY (`lesson_id`) REFERENCES `lessons`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ld_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ld_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ld_parent` FOREIGN KEY (`parent_id`) REFERENCES `lesson_discussions`(`id`) ON DELETE CASCADE,
  INDEX `idx_ld_lesson` (`lesson_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `wishlists` (
  `user_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`, `course_id`),
  CONSTRAINT `fk_wl_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_wl_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `app_settings` (`setting_key`, `setting_value`) VALUES
('bank.bin', '970415'),
('mail.resend_api_key', ''),
('mail.from', 'CourseShop <onboarding@resend.dev>');

INSERT IGNORE INTO `lesson_exercises` (`id`, `lesson_id`, `course_id`, `title`, `prompt_text`, `language`, `starter_code`, `expected_tokens`, `hint_text`, `solution_code`) VALUES
(1, 1, 1, 'Dựng khung tài liệu HTML5 ngữ nghĩa', 'Viết cấu trúc HTML5 gồm thẻ <header> chứa tiêu đề <h1>, thẻ <main> chứa một đoạn <p>, và thẻ <footer> ở cuối trang.', 'html', '<header>\n  <!-- Thêm tiêu đề h1 tại đây -->\n</header>\n<main>\n  \n</main>\n<footer>Bản quyền 2026</footer>', '<header>\n<h1>\n<main>\n<p>\n<footer>', 'Đảm bảo đủ 5 thẻ ngữ nghĩa: <header>, <h1>, <main>, <p> và <footer>.', '<header>\n  <h1>Chào mừng tới CourseShop</h1>\n</header>\n<main>\n  <p>Đây là nội dung chính của bài học HTML5.</p>\n</main>\n<footer>Bản quyền 2026</footer>'),
(2, 2, 1, 'Cấu hình Box Model chuẩn với box-sizing', 'Viết đoạn CSS đặt box-sizing: border-box cho lớp .card với padding: 20px và border: 1px solid #16181D.', 'css', '.card {\n  width: 320px;\n  /* Bổ sung box-sizing, padding và border */\n}', 'box-sizing\nborder-box\npadding\nborder', 'Sử dụng thuộc tính box-sizing: border-box; để padding và border không làm phình rộng tổng kích thước 320px.', '.card {\n  width: 320px;\n  box-sizing: border-box;\n  padding: 20px;\n  border: 1px solid #16181D;\n}'),
(3, 5, 2, 'Viết Arrow Function tính giá sau giảm', 'Hoàn thành hàm mũi tên calcDiscount(price, percent) trả về số tiền sau khi giảm giá.', 'javascript', 'const calcDiscount = (price, percent) => {\n  // Trả về giá sau giảm\n};\n\nconsole.log(calcDiscount(1000000, 20));', 'const\n=>\nreturn\n100', 'Công thức: return price - (price * percent) / 100; hoặc price * (1 - percent / 100).', 'const calcDiscount = (price, percent) => {\n  return price - (price * percent) / 100;\n};\n\nconsole.log(calcDiscount(1000000, 20));'),
(4, 6, 2, 'Tính tổng tiền giỏ hàng bằng Array.reduce', 'Dùng phương thức .reduce() để tính tổng thuộc tính price của mảng cart.', 'javascript', 'const cart = [\n  { title: "Java Web", price: 1290000 },\n  { title: "Tailwind UI", price: 990000 }\n];\n\nconst total = cart.reduce((sum, item) => /* viết tiếp */, 0);\nconsole.log(total);', '.reduce(\nsum\nitem.price', 'Trong callback của reduce, cộng dồn sum + item.price với giá trị khởi tạo là 0.', 'const cart = [\n  { title: "Java Web", price: 1290000 },\n  { title: "Tailwind UI", price: 990000 }\n];\n\nconst total = cart.reduce((sum, item) => sum + item.price, 0);\nconsole.log(total);'),
(5, 11, 3, 'Truy vấn doanh thu các đơn đã thanh toán', 'Viết câu lệnh SQL dùng SUM(total_amount) để tính tổng doanh thu các đơn có trạng thái PAID từ bảng orders.', 'sql', 'SELECT /* điền hàm tổng */ AS total_revenue\nFROM orders\nWHERE /* điều kiện trạng thái */;', 'SELECT\nSUM(\nFROM orders\nWHERE\nPAID', 'Sử dụng COALESCE(SUM(total_amount), 0) kết hợp WHERE status = ''PAID''.', 'SELECT COALESCE(SUM(total_amount), 0) AS total_revenue\nFROM orders\nWHERE status = ''PAID'';'),
(6, 16, 5, 'Khai báo Servlet với @WebServlet chuẩn Jakarta EE 10', 'Viết lớp HelloServlet kế thừa HttpServlet dùng namespace jakarta.servlet và ánh xạ đường dẫn /hello.', 'java', 'import jakarta.servlet.annotation.WebServlet;\nimport jakarta.servlet.http.HttpServlet;\n\n// Thêm annotation @WebServlet và khai báo lớp kế thừa HttpServlet\n', 'jakarta.servlet\n@WebServlet\nextends HttpServlet\n/hello', 'Sử dụng @WebServlet("/hello") phía trên public class HelloServlet extends HttpServlet.', 'import jakarta.servlet.annotation.WebServlet;\nimport jakarta.servlet.http.HttpServlet;\n\n@WebServlet("/hello")\npublic class HelloServlet extends HttpServlet {\n}');

INSERT IGNORE INTO `quizzes` (`id`, `course_id`, `section_id`, `lesson_id`, `title`, `description`, `pass_score`) VALUES
(1, 1, 1, NULL, 'Kiểm tra Chương 1: HTML5 Ngữ nghĩa & Box Model', 'Đánh giá nắm vững thẻ ngữ nghĩa HTML5 và cách tính kích thước Box Model.', 70),
(2, 1, 2, NULL, 'Kiểm tra Chương 2: Flexbox, Grid & Responsive', 'Kiểm tra tư duy bố cục đa màn hình từ di động đến máy tính.', 70),
(3, 2, 3, NULL, 'Kiểm tra Chương 1: JavaScript ES6+ & Mảng', 'Củng cố scope let/const, arrow function và map/filter/reduce.', 70),
(4, 3, 5, NULL, 'Kiểm tra Chương 1: Thiết kế Cơ sở dữ liệu & Khóa ngoại', 'Kiểm tra kiến thức chuẩn hóa ERD, khóa ngoại và ràng buộc UNIQUE.', 70),
(5, 5, 9, NULL, 'Kiểm tra Chương 1: Jakarta EE 10, Servlet & JDBC', 'Đánh giá kiến thức Tomcat 10.1, vòng đời Servlet và PreparedStatement.', 70),
(6, 5, 11, NULL, 'Kiểm tra Chương 3: Giao dịch & Thanh toán trực tuyến', 'Kiểm tra xử lý Transaction, xác minh giao dịch phía máy chủ và mở khóa học.', 70);

INSERT IGNORE INTO `quiz_questions` (`id`, `quiz_id`, `question_text`, `option_a`, `option_b`, `option_c`, `option_d`, `correct_option`, `explanation`, `sort_order`) VALUES
(1, 1, 'Thuộc tính CSS nào giúp padding và border được tính gộp bên trong width đã khai báo?', 'box-sizing: content-box', 'box-sizing: border-box', 'display: inline-block', 'overflow: hidden', 'B', 'box-sizing: border-box giữ tổng độ rộng phần tử đúng bằng giá trị width khai báo, tránh vỡ khung ngang.', 1),
(2, 1, 'Thẻ HTML5 nào phù hợp nhất để bao bọc phần nội dung chính duy nhất của trang web?', '<div id="body">', '<section>', '<main>', '<article>', 'C', 'Thẻ <main> biểu thị vùng nội dung trọng tâm duy nhất của tài liệu, hỗ trợ tốt cho SEO và trình đọc màn hình.', 2),
(3, 1, 'Khoảng cách nằm BÊN NGOÀI đường viền (border) của phần tử là thuộc tính nào?', 'padding', 'margin', 'gap', 'outline-offset', 'B', 'Margin tạo khoảng trống bên ngoài border để tách biệt các phần tử lân cận.', 3),
(4, 2, 'Trong Flexbox, thuộc tính nào căn giữa các phần tử con theo trục dọc khi flex-direction là row?', 'justify-content: center', 'align-items: center', 'place-content: start', 'flex-wrap: wrap', 'B', 'Khi trục chính nằm ngang (row), align-items điều khiển căn chỉnh theo trục phụ (dọc).', 1),
(5, 2, 'Lớp Tailwind CSS nào chia lưới 1 cột trên điện thoại và 4 cột từ màn hình lớn (lg)?', 'grid-cols-4 sm:grid-cols-1', 'grid-cols-1 lg:grid-cols-4', 'flex-col lg:flex-row', 'cols-1 md:cols-4', 'B', 'Tailwind thiết kế theo hướng mobile-first: grid-cols-1 mặc định và nâng lên lg:grid-cols-4 từ 1024px.', 2),
(6, 3, 'Phương thức mảng nào tạo ra mảng mới chỉ giữ lại các phần tử thỏa mãn điều kiện?', 'map()', 'forEach()', 'filter()', 'find()', 'C', 'filter() trả về một mảng mới chứa tất cả phần tử mà hàm kiểm tra trả về true.', 1),
(7, 3, 'Từ khóa khai báo biến nào có phạm vi khối (block scope) và không thể gán lại tham chiếu?', 'var', 'let', 'const', 'static', 'C', 'const có block scope và ngăn việc gán lại giá trị tham chiếu mới cho biến.', 2),
(8, 4, 'Ràng buộc nào ngăn một học viên ghi danh trùng hai lần vào cùng một khóa học trong bảng enrollments?', 'PRIMARY KEY(user_id)', 'UNIQUE KEY(user_id, course_id)', 'INDEX(course_id)', 'NOT NULL(course_id)', 'B', 'Khóa duy nhất kết hợp (user_id, course_id) bảo vệ tính toàn vẹn ngay ở tầng cơ sở dữ liệu.', 1),
(9, 4, 'Khi xóa một khóa học, tùy chọn khóa ngoại nào tự động xóa các bài học liên quan?', 'ON DELETE RESTRICT', 'ON DELETE SET NULL', 'ON DELETE CASCADE', 'ON UPDATE CASCADE', 'C', 'ON DELETE CASCADE tự động dọn sạch các bản ghi con phụ thuộc khi bản ghi cha bị xóa.', 2),
(10, 5, 'Tomcat 10.1 sử dụng gói thư viện Servlet nào sau đây?', 'javax.servlet.*', 'jakarta.servlet.*', 'org.tomcat.servlet.*', 'java.servlet.*', 'B', 'Từ Jakarta EE 9/10 trở đi (Tomcat 10+), toàn bộ namespace chuyển từ javax.servlet sang jakarta.servlet.', 1),
(11, 5, 'Tại sao bắt buộc dùng PreparedStatement thay vì nối chuỗi SQL trực tiếp?', 'Chạy chậm hơn nhưng dễ đọc hơn', 'Ngăn chặn lỗ hổng SQL Injection và tái sử dụng kế hoạch thực thi', 'Chỉ dùng được cho câu lệnh SELECT', 'Không cần đóng kết nối sau khi chạy', 'B', 'PreparedStatement tách biệt cấu trúc lệnh SQL và tham số người dùng, chặn triệt để SQL Injection.', 2),
(12, 6, 'Trạng thái thanh toán thành công của đơn hàng phải được xác nhận ở đâu để đảm bảo an toàn?', 'Từ tham số query URL trên trình duyệt', 'Từ nút bấm xác nhận ở giao diện người dùng', 'Xác minh phía máy chủ qua API cổng thanh toán hoặc Webhook có chữ ký', 'Lưu trực tiếp vào localStorage', 'C', 'Mọi xác nhận thanh toán phải được kiểm chứng phía máy chủ để tránh giả mạo yêu cầu từ trình duyệt.', 1),
(13, 6, 'Mục đích của JDBC Transaction khi duyệt đơn hàng và mở khóa học là gì?', 'Giúp giao diện load nhanh hơn', 'Đảm bảo cập nhật đơn PAID và tạo quyền học cùng thành công hoặc cùng hoàn tác', 'Tự động gửi email marketing', 'Nén kích thước cơ sở dữ liệu', 'B', 'Transaction bảo toàn tính nguyên tử (ACID), tránh tình trạng đã trừ tiền nhưng học viên chưa nhận được khóa học.', 2);

INSERT IGNORE INTO `lesson_discussions` (`id`, `lesson_id`, `course_id`, `user_id`, `parent_id`, `content`) VALUES
(1, 1, 1, 2, NULL, 'Cho em hỏi khi nào nên dùng thẻ <article> thay cho thẻ <section> trong HTML5 ạ?'),
(2, 1, 1, 1, 1, 'Chào bạn! Bạn dùng <article> cho khối nội dung độc lập có thể tách riêng đem chia sẻ (như bài viết blog, thẻ tin tức), còn <section> dùng để gom nhóm các phần theo chủ đề bên trong một trang nhé.'),
(3, 16, 5, 2, NULL, 'Em chạy trên Tomcat 10.1 mà import javax.servlet bị báo lỗi 404, có phải do sai phiên bản không ạ?'),
(4, 16, 5, 1, 3, 'Đúng rồi bạn! Tomcat 10.1 chạy chuẩn Jakarta EE 10 nên toàn bộ Servlet và Filter cần dùng gói jakarta.servlet.* thay cho javax.servlet.* nhé.');
