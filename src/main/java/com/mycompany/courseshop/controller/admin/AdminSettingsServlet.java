package com.mycompany.courseshop.controller.admin;

import com.mycompany.courseshop.config.AppConfig;
import com.mycompany.courseshop.dao.SettingsDAO;
import com.mycompany.courseshop.service.GeminiChatService;
import com.mycompany.courseshop.service.StripeService;
import com.mycompany.courseshop.utils.FormatUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "AdminSettingsServlet", urlPatterns = {"/admin/settings"})
public class AdminSettingsServlet extends HttpServlet {

    private final SettingsDAO settingsDAO = new SettingsDAO();
    private final StripeService stripeService = new StripeService();
    private final GeminiChatService geminiService = new GeminiChatService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String stripeSk = settingsDAO.getStripeSecretKey();
        String stripePk = settingsDAO.getStripePublishableKey();
        String stripeWh = settingsDAO.getStripeWebhookSecret();
        String geminiKey = settingsDAO.getGeminiApiKey();

        req.setAttribute("stripeSkMasked", FormatUtil.maskSecret(stripeSk));
        req.setAttribute("stripePkMasked", FormatUtil.maskSecret(stripePk));
        req.setAttribute("stripeWhMasked", FormatUtil.maskSecret(stripeWh));
        req.setAttribute("hasStripeSk", stripeService.isConfigured());
        req.setAttribute("hasStripeWh", stripeService.isWebhookConfigured());
        req.setAttribute("stripeFromEnv", AppConfig.isEnvSet("STRIPE_SECRET_KEY"));
        req.setAttribute("webhookFromEnv", AppConfig.isEnvSet("STRIPE_WEBHOOK_SECRET"));

        req.setAttribute("geminiKeyMasked", FormatUtil.maskSecret(geminiKey));
        req.setAttribute("hasGeminiKey", geminiService.isConfigured());
        req.setAttribute("geminiFromEnv", AppConfig.isEnvSet("GEMINI_API_KEY"));
        req.setAttribute("geminiModel", settingsDAO.getGeminiModel());

        req.setAttribute("adminNav", "settings");
        req.setAttribute("pageTitle", "Cài đặt hệ thống — Quản trị CourseShop");
        req.getRequestDispatcher("/views/admin/settings.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            if ("testStripe".equalsIgnoreCase(action)) {
                String keyInput = req.getParameter("stripeSecretKey");
                String keyToTest = (keyInput != null && !keyInput.isBlank()) ? keyInput.trim() : settingsDAO.getStripeSecretKey();
                StripeService.TestResult res = stripeService.testConnection(keyToTest);
                req.getSession().setAttribute(res.ok() ? "flashSuccess" : "flashError", res.message());
            } else if ("testGemini".equalsIgnoreCase(action)) {
                String keyInput = req.getParameter("geminiApiKey");
                String modelInput = req.getParameter("geminiModel");
                String keyToTest = (keyInput != null && !keyInput.isBlank()) ? keyInput.trim() : settingsDAO.getGeminiApiKey();
                String modelToTest = (modelInput != null && !modelInput.isBlank()) ? modelInput.trim() : settingsDAO.getGeminiModel();
                GeminiChatService.TestResult res = geminiService.testConnection(keyToTest, modelToTest);
                req.getSession().setAttribute(res.ok() ? "flashSuccess" : "flashError", res.message());
            } else if ("saveStripe".equalsIgnoreCase(action)) {
                String sk = req.getParameter("stripeSecretKey");
                if (sk != null && !sk.isBlank()) settingsDAO.upsert("stripe.secret_key", sk);
                String pk = req.getParameter("stripePublishableKey");
                if (pk != null && !pk.isBlank()) settingsDAO.upsert("stripe.publishable_key", pk);
                String wh = req.getParameter("stripeWebhookSecret");
                if (wh != null && !wh.isBlank()) settingsDAO.upsert("stripe.webhook_secret", wh);
                if ("1".equals(req.getParameter("clearStripeKey"))) {
                    settingsDAO.upsert("stripe.secret_key", "");
                    settingsDAO.upsert("stripe.publishable_key", "");
                    settingsDAO.upsert("stripe.webhook_secret", "");
                }
                req.getSession().setAttribute("flashSuccess", "Đã lưu cấu hình cổng thanh toán Stripe.");
            } else if ("saveGemini".equalsIgnoreCase(action)) {
                String model = req.getParameter("geminiModel");
                settingsDAO.upsert("gemini.model", (model == null || model.isBlank()) ? "gemini-3.8-flash" : model);
                String key = req.getParameter("geminiApiKey");
                if (key != null && !key.isBlank()) settingsDAO.upsert("gemini.api_key", key);
                if ("1".equals(req.getParameter("clearGeminiKey"))) {
                    settingsDAO.upsert("gemini.api_key", "");
                }
                req.getSession().setAttribute("flashSuccess", "Đã lưu cấu hình Trợ lý AI.");
            } else if ("saveSite".equalsIgnoreCase(action)) {
                upsertNonNull("site.name", req.getParameter("siteName"));
                upsertNonNull("site.tagline", req.getParameter("siteTagline"));
                upsertNonNull("site.hero_title", req.getParameter("heroTitle"));
                upsertNonNull("site.hero_subtitle", req.getParameter("heroSubtitle"));
                upsertNonNull("site.support_email", req.getParameter("supportEmail"));
                upsertNonNull("site.hotline", req.getParameter("hotline"));
                upsertNonNull("site.address", req.getParameter("address"));
                upsertNonNull("bank.name", req.getParameter("bankName"));
                upsertNonNull("bank.account_number", req.getParameter("bankAccountNumber"));
                upsertNonNull("bank.account_holder", req.getParameter("bankAccountHolder"));
                req.getSession().setAttribute("flashSuccess", "Đã lưu thông tin website và tài khoản ngân hàng.");
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("flashError", "Không thể lưu cấu hình lúc này. Vui lòng thử lại.");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/settings");
    }

    private void upsertNonNull(String key, String value) throws SQLException {
        if (value != null) {
            settingsDAO.upsert(key, value.trim());
        }
    }
}
