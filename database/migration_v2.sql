-- ============================================================================
-- CourseShop v2 Migration (P0 + P1 + P2)
-- Compatible with MariaDB 10.4+ (XAMPP) and MySQL 8 / TiDB Cloud Serverless
-- Safe & idempotent: can be executed on an existing `course_shop` database.
-- ============================================================================

USE `course_shop`;
SET NAMES utf8mb4;

-- 1. Resume playback: track last opened lesson per enrollment
ALTER TABLE `enrollments`
  ADD COLUMN IF NOT EXISTS `last_lesson_id` INT DEFAULT NULL;

-- 2. Password reset tokens (stores SHA-256 hash of single-use token)
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

-- 3. Course completion certificates (auto-issued at 100% progress)
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

-- 4. Quizzes (per-lesson or end-of-chapter multiple-choice assessments)
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

-- 5. Per-lesson coding exercises & submissions
CREATE TABLE IF NOT EXISTS `lesson_exercises` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `lesson_id` INT NOT NULL UNIQUE,
  `course_id` INT NOT NULL,
  `title` VARCHAR(220) NOT NULL,
  `prompt_text` TEXT NOT NULL,
  `language` VARCHAR(32) NOT NULL DEFAULT 'html',
  `starter_code` TEXT,
  `expected_tokens` TEXT COMMENT 'Newline-separated required code fragments checked case-insensitively',
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

-- 6. Lesson Q&A Discussions (supports 1-level replies + Instructor badge for ADMIN)
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

-- 7. Course Wishlists
CREATE TABLE IF NOT EXISTS `wishlists` (
  `user_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`, `course_id`),
  CONSTRAINT `fk_wl_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_wl_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Default new app_settings (VietQR Bank BIN + Transactional Email)
INSERT IGNORE INTO `app_settings` (`setting_key`, `setting_value`) VALUES
('bank.bin', '970415'),
('mail.resend_api_key', ''),
('mail.from', 'CourseShop <onboarding@resend.dev>');

-- 9. Seed interactive Coding Exercises (idempotent)
INSERT IGNORE INTO `lesson_exercises` (`id`, `lesson_id`, `course_id`, `title`, `prompt_text`, `language`, `starter_code`, `expected_tokens`, `hint_text`, `solution_code`) VALUES
(1, 1, 1, 'Dựng khung tài liệu HTML5 ngữ nghĩa',
 'Viết cấu trúc HTML5 gồm thẻ <header> chứa tiêu đề <h1>, thẻ <main> chứa một đoạn <p>, và thẻ <footer> ở cuối trang.',
 'html',
 '<header>\n  <!-- Thêm tiêu đề h1 tại đây -->\n</header>\n<main>\n  \n</main>\n<footer>Bản quyền 2026</footer>',
 '<header>\n<h1>\n<main>\n<p>\n<footer>',
 'Đảm bảo đủ 5 thẻ ngữ nghĩa: <header>, <h1>, <main>, <p> và <footer>.',
 '<header>\n  <h1>Chào mừng tới CourseShop</h1>\n</header>\n<main>\n  <p>Đây là nội dung chính của bài học HTML5.</p>\n</main>\n<footer>Bản quyền 2026</footer>'),

(2, 2, 1, 'Cấu hình Box Model chuẩn với box-sizing',
 'Viết đoạn CSS đặt box-sizing: border-box cho lớp .card với padding: 20px và border: 1px solid #16181D.',
 'css',
 '.card {\n  width: 320px;\n  /* Bổ sung box-sizing, padding và border */\n}',
 'box-sizing\nborder-box\npadding\nborder',
 'Sử dụng thuộc tính box-sizing: border-box; để padding và border không làm phình rộng tổng kích thước 320px.',
 '.card {\n  width: 320px;\n  box-sizing: border-box;\n  padding: 20px;\n  border: 1px solid #16181D;\n}'),

(3, 5, 2, 'Viết Arrow Function tính giá sau giảm',
 'Hoàn thành hàm mũi tên calcDiscount(price, percent) trả về số tiền sau khi giảm giá.',
 'javascript',
 'const calcDiscount = (price, percent) => {\n  // Trả về giá sau giảm\n};\n\nconsole.log(calcDiscount(1000000, 20));',
 'const\n=>\nreturn\n100',
 'Công thức: return price - (price * percent) / 100; hoặc price * (1 - percent / 100).',
 'const calcDiscount = (price, percent) => {\n  return price - (price * percent) / 100;\n};\n\nconsole.log(calcDiscount(1000000, 20));'),

(4, 6, 2, 'Tính tổng tiền giỏ hàng bằng Array.reduce',
 'Dùng phương thức .reduce() để tính tổng thuộc tính price của mảng cart.',
 'javascript',
 'const cart = [\n  { title: "Java Web", price: 1290000 },\n  { title: "Tailwind UI", price: 990000 }\n];\n\nconst total = cart.reduce((sum, item) => /* viết tiếp */, 0);\nconsole.log(total);',
 '.reduce(\nsum\nitem.price',
 'Trong callback của reduce, cộng dồn sum + item.price với giá trị khởi tạo là 0.',
 'const cart = [\n  { title: "Java Web", price: 1290000 },\n  { title: "Tailwind UI", price: 990000 }\n];\n\nconst total = cart.reduce((sum, item) => sum + item.price, 0);\nconsole.log(total);'),

(5, 11, 3, 'Truy vấn doanh thu các đơn đã thanh toán',
 'Viết câu lệnh SQL dùng SUM(total_amount) để tính tổng doanh thu các đơn có trạng thái PAID từ bảng orders.',
 'sql',
 'SELECT /* điền hàm tổng */ AS total_revenue\nFROM orders\nWHERE /* điều kiện trạng thái */;',
 'SELECT\nSUM(\nFROM orders\nWHERE\nPAID',
 'Sử dụng COALESCE(SUM(total_amount), 0) kết hợp WHERE status = ''PAID''.',
 'SELECT COALESCE(SUM(total_amount), 0) AS total_revenue\nFROM orders\nWHERE status = ''PAID'';'),

(6, 16, 5, 'Khai báo Servlet với @WebServlet chuẩn Jakarta EE 10',
 'Viết lớp HelloServlet kế thừa HttpServlet dùng namespace jakarta.servlet và ánh xạ đường dẫn /hello.',
 'java',
 'import jakarta.servlet.annotation.WebServlet;\nimport jakarta.servlet.http.HttpServlet;\n\n// Thêm annotation @WebServlet và khai báo lớp kế thừa HttpServlet\n',
 'jakarta.servlet\n@WebServlet\nextends HttpServlet\n/hello',
 'Sử dụng @WebServlet("/hello") phía trên public class HelloServlet extends HttpServlet.',
 'import jakarta.servlet.annotation.WebServlet;\nimport jakarta.servlet.http.HttpServlet;\n\n@WebServlet("/hello")\npublic class HelloServlet extends HttpServlet {\n}');

-- 10. Seed Chapter & Lesson Quizzes (idempotent)
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

-- 11. Seed initial realistic Q&A discussion on lesson 1 & lesson 16
INSERT IGNORE INTO `lesson_discussions` (`id`, `lesson_id`, `course_id`, `user_id`, `parent_id`, `content`) VALUES
(1, 1, 1, 2, NULL, 'Cho em hỏi khi nào nên dùng thẻ <article> thay cho thẻ <section> trong HTML5 ạ?'),
(2, 1, 1, 1, 1, 'Chào bạn! Bạn dùng <article> cho khối nội dung độc lập có thể tách riêng đem chia sẻ (như bài viết blog, thẻ tin tức), còn <section> dùng để gom nhóm các phần theo chủ đề bên trong một trang nhé.'),
(3, 16, 5, 2, NULL, 'Em chạy trên Tomcat 10.1 mà import javax.servlet bị báo lỗi 404, có phải do sai phiên bản không ạ?'),
(4, 16, 5, 1, 3, 'Đúng rồi bạn! Tomcat 10.1 chạy chuẩn Jakarta EE 10 nên toàn bộ Servlet và Filter cần dùng gói jakarta.servlet.* thay cho javax.servlet.* nhé.');
