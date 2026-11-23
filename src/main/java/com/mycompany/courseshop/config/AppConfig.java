package com.mycompany.courseshop.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class AppConfig {

    private static final Properties PROPS = new Properties();

    static {
        try (InputStream in = AppConfig.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (in != null) {
                PROPS.load(in);
            }
        } catch (IOException ignored) {
        }
    }

    public static boolean isEnvSet(String envKey) {
        String env = System.getenv(envKey);
        return env != null && !env.isBlank();
    }

    private static String resolve(String envKey, String propKey, String defaultVal) {
        String env = System.getenv(envKey);
        if (env != null && !env.isBlank()) {
            return env.trim();
        }
        String prop = PROPS.getProperty(propKey);
        if (prop != null && !prop.isBlank()) {
            return prop.trim();
        }
        return defaultVal;
    }

    public static String getDbUrl() {
        return resolve("COURSESHOP_DB_URL", "db.url",
                "jdbc:mysql://localhost:3306/course_shop?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh&allowPublicKeyRetrieval=true&useSSL=false");
    }

    public static String getDbUser() {
        return resolve("COURSESHOP_DB_USER", "db.user", "root");
    }

    public static String getDbPassword() {
        return resolve("COURSESHOP_DB_PASSWORD", "db.password", "");
    }

    public static String getStripeSecretKey() {
        return resolve("STRIPE_SECRET_KEY", "stripe.secretKey", "");
    }

    public static String getStripePublishableKey() {
        return resolve("STRIPE_PUBLISHABLE_KEY", "stripe.publishableKey", "");
    }

    public static String getStripeWebhookSecret() {
        return resolve("STRIPE_WEBHOOK_SECRET", "stripe.webhookSecret", "");
    }

    public static String getGeminiApiKey() {
        return resolve("GEMINI_API_KEY", "gemini.apiKey", "");
    }

    public static String getGeminiModel() {
        return resolve("GEMINI_MODEL", "gemini.model", "gemini-3.8-flash");
    }

    public static String getAppBaseUrl() {
        return resolve("APP_BASE_URL", "app.baseUrl", "");
    }

    public static String getSupabaseUrl() {
        return resolve("SUPABASE_URL", "supabase.url", "");
    }

    public static String getSupabaseKey() {
        return resolve("SUPABASE_KEY", "supabase.key", "");
    }

    public static String getSupabaseBucket() {
        return resolve("SUPABASE_BUCKET", "supabase.bucket", "courseshop");
    }

    public static String getResendApiKey() {
        return resolve("RESEND_API_KEY", "mail.resendApiKey", "");
    }

    public static String getMailFrom() {
        return resolve("MAIL_FROM", "mail.from", "");
    }
}
