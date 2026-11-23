package com.mycompany.courseshop.service;

import com.google.gson.JsonObject;
import com.mycompany.courseshop.dao.SettingsDAO;
import com.mycompany.courseshop.model.Order;
import com.mycompany.courseshop.model.OrderItem;
import com.stripe.StripeClient;
import com.stripe.exception.AuthenticationException;
import com.stripe.exception.CardException;
import com.stripe.exception.InvalidRequestException;
import com.stripe.exception.RateLimitException;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.exception.StripeException;
import com.stripe.model.Balance;
import com.stripe.model.Coupon;
import com.stripe.model.Event;
import com.stripe.model.PromotionCode;
import com.stripe.model.StripeCollection;
import com.stripe.model.checkout.Session;
import com.stripe.net.RequestOptions;
import com.stripe.net.Webhook;
import com.stripe.param.CouponCreateParams;
import com.stripe.param.PromotionCodeListParams;
import com.stripe.param.checkout.SessionCreateParams;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Production Stripe SDK service (Test Sandbox & Live Mode only — zero mock payment logic).
 * API keys and webhook secrets resolve from Environment Variables first (STRIPE_SECRET_KEY,
 * STRIPE_WEBHOOK_SECRET), falling back to Admin DB settings only when ENV is unset.
 */
public class StripeService {

    private final SettingsDAO settingsDAO = new SettingsDAO();

    public boolean isConfigured() {
        String key = settingsDAO.getStripeSecretKey();
        return key != null && (key.startsWith("sk_test_") || key.startsWith("sk_live_"));
    }

    public boolean isWebhookConfigured() {
        String whsec = settingsDAO.getStripeWebhookSecret();
        return whsec != null && whsec.startsWith("whsec_");
    }

    public record CheckoutSessionResult(boolean ok, String sessionId, String checkoutUrl, String errorMessage) {}

    public record SessionVerifyResult(
            boolean ok,
            boolean paid,
            String status,
            String paymentStatus,
            long amountSubtotal,
            long amountDiscount,
            long amountTotal,
            String paymentIntentId,
            String errorMessage) {}

    public record TestResult(boolean ok, String message) {}

    private StripeClient buildClient(String secretKey) {
        return StripeClient.builder()
                .setApiKey(secretKey.trim())
                .setConnectTimeout(15_000)
                .setReadTimeout(20_000)
                .build();
    }

    public CheckoutSessionResult createCheckoutSession(Order order, String baseUrl) {
        String secretKey = settingsDAO.getStripeSecretKey();
        if (secretKey == null || (!secretKey.startsWith("sk_test_") && !secretKey.startsWith("sk_live_"))) {
            return new CheckoutSessionResult(false, null, null,
                    "Cổng thanh toán thẻ quốc tế hiện chưa sẵn sàng. Vui lòng chọn chuyển khoản ngân hàng hoặc thử lại sau.");
        }

        // Stripe minimum charge for zero-decimal VND is ~15,000 VND
        long totalVnd = order.getTotalAmount().longValue();
        if (totalVnd < 15_000L) {
            return new CheckoutSessionResult(false, null, null,
                    "Giá trị thanh toán qua thẻ tối thiểu là 15.000đ.");
        }

        try {
            StripeClient client = buildClient(secretKey);

            SessionCreateParams.Builder builder = SessionCreateParams.builder()
                    .setMode(SessionCreateParams.Mode.PAYMENT)
                    .setClientReferenceId(order.getOrderCode())
                    .setSuccessUrl(baseUrl + "/payment/stripe/success?session_id={CHECKOUT_SESSION_ID}&orderCode=" + enc(order.getOrderCode()))
                    .setCancelUrl(baseUrl + "/payment/stripe/cancel?orderCode=" + enc(order.getOrderCode()))
                    .putMetadata("order_id", String.valueOf(order.getId()))
                    .putMetadata("order_code", order.getOrderCode())
                    .setPaymentIntentData(
                            SessionCreateParams.PaymentIntentData.builder()
                                    .putMetadata("order_id", String.valueOf(order.getId()))
                                    .putMetadata("order_code", order.getOrderCode())
                                    .build()
                    );

            if (order.getUserEmail() != null && !order.getUserEmail().isBlank()) {
                builder.setCustomerEmail(order.getUserEmail());
            }

            long subtotalVnd = order.getSubtotal() != null ? order.getSubtotal().longValue() : totalVnd;
            long discountVnd = order.getDiscountAmount() != null ? order.getDiscountAmount().longValue() : 0L;
            boolean hasDiscount = discountVnd > 0L;

            if (order.getItems() != null && !order.getItems().isEmpty()) {
                if (hasDiscount) {
                    SessionCreateParams.Discount stripeDiscount = resolveOrCreateDiscount(client, order, subtotalVnd, discountVnd);
                    if (stripeDiscount != null) {
                        for (OrderItem item : order.getItems()) {
                            builder.addLineItem(buildLineItem(item.getCourseTitle(), item.getStripeProductId(), item.getUnitPrice().longValue()));
                        }
                        builder.addDiscount(stripeDiscount);
                    } else {
                        String label = "Đơn hàng khóa học #" + order.getOrderCode()
                                + (order.getCouponCode() != null ? " (Mã " + order.getCouponCode() + ")" : "");
                        builder.addLineItem(buildLineItem(label, null, totalVnd));
                    }
                } else {
                    for (OrderItem item : order.getItems()) {
                        builder.addLineItem(buildLineItem(item.getCourseTitle(), item.getStripeProductId(), item.getUnitPrice().longValue()));
                    }
                    // Allow entering Stripe Promotion Codes directly on Stripe Checkout when no cart coupon was applied
                    builder.setAllowPromotionCodes(true);
                }
            } else {
                String label = "Đơn hàng khóa học #" + order.getOrderCode();
                builder.addLineItem(buildLineItem(label, null, totalVnd));
            }

            RequestOptions options = RequestOptions.builder()
                    .setIdempotencyKey("checkout-" + order.getOrderCode())
                    .build();

            Session session = client.checkout().sessions().create(builder.build(), options);
            if (session == null || session.getUrl() == null || session.getUrl().isBlank()) {
                return new CheckoutSessionResult(false, null, null,
                        "Không nhận được liên kết thanh toán hợp lệ. Vui lòng thử lại.");
            }
            return new CheckoutSessionResult(true, session.getId(), session.getUrl(), null);
        } catch (AuthenticationException e) {
            return new CheckoutSessionResult(false, null, null,
                    "Cổng thanh toán thẻ tạm thời gián đoạn do lỗi xác thực. Vui lòng thử lại sau.");
        } catch (RateLimitException e) {
            return new CheckoutSessionResult(false, null, null,
                    "Cổng thanh toán đang bận. Vui lòng chờ vài giây rồi thử lại.");
        } catch (CardException | InvalidRequestException e) {
            System.err.println("[StripeService] Checkout session rejected: " + e.getMessage());
            String msg = e.getMessage() != null && e.getMessage().contains("No such product")
                    ? "Không tìm thấy mã sản phẩm Stripe (prod_...) trên tài khoản Stripe hiện tại. Vui lòng kiểm tra chế độ Test/Live và cấu hình khóa học."
                    : "Không thể khởi tạo phiên thanh toán. Vui lòng kiểm tra lại đơn hàng và thử lại.";
            return new CheckoutSessionResult(false, null, null, msg);
        } catch (StripeException e) {
            return new CheckoutSessionResult(false, null, null,
                    "Không thể kết nối cổng thanh toán thẻ. Vui lòng thử lại sau ít phút.");
        }
    }

    /**
     * Resolves an existing Stripe Coupon or Promotion Code matching the order's coupon and exact discount.
     * Falls back to a single-use exact amount_off Stripe Coupon when max_discount caps apply or no matching ID exists,
     * preserving individual Stripe Product line items on the Checkout page.
     */
    private SessionCreateParams.Discount resolveOrCreateDiscount(
            StripeClient client, Order order, long subtotalVnd, long discountVnd) {
        // 1) Explicit stripe_coupon_id configured on the coupon row (supports promo_... or Stripe coupon ID)
        String configuredId = order.getStripeCouponId();
        if (configuredId != null && !configuredId.isBlank()) {
            SessionCreateParams.Discount matched = tryMatchStripeDiscount(client, configuredId.trim(), subtotalVnd, discountVnd);
            if (matched != null) return matched;
        }

        // 2) Auto-match by CourseShop coupon code against Stripe Coupon ID or active Stripe Promotion Code
        String code = order.getCouponCode();
        if (code != null && !code.isBlank()) {
            String trimmed = code.trim();
            if (configuredId == null || !trimmed.equalsIgnoreCase(configuredId.trim())) {
                SessionCreateParams.Discount matched = tryMatchStripeDiscount(client, trimmed, subtotalVnd, discountVnd);
                if (matched != null) return matched;
            }
            try {
                StripeCollection<PromotionCode> promos = client.promotionCodes().list(
                        PromotionCodeListParams.builder()
                                .setCode(trimmed)
                                .setActive(true)
                                .setLimit(1L)
                                .build()
                );
                if (promos != null && promos.getData() != null && !promos.getData().isEmpty()) {
                    PromotionCode pc = promos.getData().get(0);
                    if (matchesExactDiscount(pc.getCoupon(), subtotalVnd, discountVnd)) {
                        return SessionCreateParams.Discount.builder().setPromotionCode(pc.getId()).build();
                    }
                }
            } catch (StripeException ignored) {
            }
        }

        // 3) Fallback: create a single-use exact amount_off coupon (handles max_discount caps cleanly)
        try {
            String rawName = (code != null && !code.isBlank()) ? ("Mã ưu đãi " + code.trim()) : ("Ưu đãi #" + order.getOrderCode());
            String safeName = rawName.length() > 40 ? rawName.substring(0, 40) : rawName;
            Coupon oneTime = client.coupons().create(
                    CouponCreateParams.builder()
                            .setAmountOff(discountVnd)
                            .setCurrency("vnd")
                            .setDuration(CouponCreateParams.Duration.ONCE)
                            .setMaxRedemptions(1L)
                            .setName(safeName)
                            .build()
            );
            return SessionCreateParams.Discount.builder().setCoupon(oneTime.getId()).build();
        } catch (StripeException e) {
            System.err.println("[StripeService] Could not create one-time discount coupon: " + e.getMessage());
            return null;
        }
    }

    private SessionCreateParams.Discount tryMatchStripeDiscount(
            StripeClient client, String stripeId, long subtotalVnd, long discountVnd) {
        try {
            if (stripeId.startsWith("promo_")) {
                PromotionCode pc = client.promotionCodes().retrieve(stripeId);
                if (Boolean.TRUE.equals(pc.getActive()) && matchesExactDiscount(pc.getCoupon(), subtotalVnd, discountVnd)) {
                    return SessionCreateParams.Discount.builder().setPromotionCode(pc.getId()).build();
                }
            } else {
                Coupon sc = client.coupons().retrieve(stripeId);
                if (matchesExactDiscount(sc, subtotalVnd, discountVnd)) {
                    return SessionCreateParams.Discount.builder().setCoupon(sc.getId()).build();
                }
            }
        } catch (StripeException ignored) {
        }
        return null;
    }

    private boolean matchesExactDiscount(Coupon sc, long subtotalVnd, long expectedDiscountVnd) {
        if (sc == null || !Boolean.TRUE.equals(sc.getValid())) return false;
        if (sc.getAmountOff() != null) {
            if (sc.getCurrency() == null || !"vnd".equalsIgnoreCase(sc.getCurrency())) return false;
            return Math.min(subtotalVnd, sc.getAmountOff()) == expectedDiscountVnd;
        }
        if (sc.getPercentOff() != null) {
            long stripeDisc = BigDecimal.valueOf(subtotalVnd)
                    .multiply(sc.getPercentOff())
                    .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP)
                    .longValue();
            return stripeDisc == expectedDiscountVnd;
        }
        // Support Stripe Custom Coupons (e.g., percentage_discount + maximum_discount cap in VND)
        JsonObject raw = sc.getRawJsonObject();
        if (raw != null && raw.has("custom") && raw.get("custom").isJsonObject()) {
            JsonObject custom = raw.getAsJsonObject("custom");
            if (custom.has("configuration") && custom.get("configuration").isJsonObject()) {
                JsonObject cfg = custom.getAsJsonObject("configuration");
                if (cfg.has("percentage_discount") && !cfg.get("percentage_discount").isJsonNull()) {
                    try {
                        BigDecimal pctRatio = cfg.get("percentage_discount").getAsBigDecimal();
                        long computed = BigDecimal.valueOf(subtotalVnd)
                                .multiply(pctRatio)
                                .setScale(0, RoundingMode.HALF_UP)
                                .longValue();
                        if (cfg.has("maximum_discount") && cfg.get("maximum_discount").isJsonObject()) {
                            JsonObject maxObj = cfg.getAsJsonObject("maximum_discount");
                            String cur = maxObj.has("currency") && !maxObj.get("currency").isJsonNull()
                                    ? maxObj.get("currency").getAsString() : "";
                            if (!"vnd".equalsIgnoreCase(cur)) return false;
                            if (maxObj.has("amount") && !maxObj.get("amount").isJsonNull()) {
                                long maxAmt = Long.parseLong(maxObj.get("amount").getAsString());
                                computed = Math.min(computed, maxAmt);
                            }
                        }
                        computed = Math.min(computed, subtotalVnd);
                        return computed == expectedDiscountVnd;
                    } catch (NumberFormatException ignored) {
                    }
                }
            }
        }
        return false;
    }

    public SessionVerifyResult retrieveCheckoutSession(String sessionId) {
        String secretKey = settingsDAO.getStripeSecretKey();
        if (secretKey == null || secretKey.isBlank() || sessionId == null || sessionId.isBlank()) {
            return new SessionVerifyResult(false, false, "invalid", "unpaid", 0L, 0L, 0L, null,
                    "Không thể xác minh thông tin giao dịch.");
        }
        try {
            StripeClient client = buildClient(secretKey);
            Session session = client.checkout().sessions().retrieve(sessionId.trim());
            String status = session.getStatus() != null ? session.getStatus() : "";
            String paymentStatus = session.getPaymentStatus() != null ? session.getPaymentStatus() : "";
            long amountSubtotal = session.getAmountSubtotal() != null ? session.getAmountSubtotal() : 0L;
            long amountTotal = session.getAmountTotal() != null ? session.getAmountTotal() : 0L;
            long amountDiscount = (session.getTotalDetails() != null && session.getTotalDetails().getAmountDiscount() != null)
                    ? session.getTotalDetails().getAmountDiscount() : 0L;
            String paymentIntentId = session.getPaymentIntent();
            boolean paid = "complete".equalsIgnoreCase(status)
                    && ("paid".equalsIgnoreCase(paymentStatus) || "no_payment_required".equalsIgnoreCase(paymentStatus));
            return new SessionVerifyResult(true, paid, status, paymentStatus,
                    amountSubtotal, amountDiscount, amountTotal, paymentIntentId, null);
        } catch (StripeException e) {
            return new SessionVerifyResult(false, false, "error", "unpaid", 0L, 0L, 0L, null,
                    "Không thể xác minh trạng thái thanh toán lúc này. Vui lòng thử lại sau ít giây.");
        }
    }

    /**
     * Validates that the Stripe-reported amounts match either the pre-calculated order total,
     * or the exact server-controlled order subtotal minus a verified Stripe Promotion Code discount.
     */
    public boolean isAmountValidForOrder(Order order, long amountSubtotal, long amountDiscount, long amountTotal) {
        if (order == null) return false;
        long expectedTotal = order.getTotalAmount() != null ? order.getTotalAmount().longValue() : -1L;
        if (amountTotal == expectedTotal) {
            return true;
        }
        long expectedSubtotal = order.getSubtotal() != null ? order.getSubtotal().longValue() : -1L;
        long orderDiscount = order.getDiscountAmount() != null ? order.getDiscountAmount().longValue() : 0L;
        return order.getCouponId() == null
                && orderDiscount == 0L
                && amountSubtotal == expectedSubtotal
                && amountDiscount > 0L
                && amountTotal >= 0L
                && amountTotal == (amountSubtotal - amountDiscount);
    }

    public Event verifyWebhookEvent(String payload, String sigHeader) throws SignatureVerificationException {
        String webhookSecret = settingsDAO.getStripeWebhookSecret();
        if (webhookSecret == null || webhookSecret.isBlank()) {
            throw new SignatureVerificationException("Webhook secret is not configured.", sigHeader);
        }
        return Webhook.constructEvent(payload, sigHeader, webhookSecret.trim());
    }

    public TestResult testConnection(String secretKey) {
        if (secretKey == null || secretKey.isBlank()) {
            return new TestResult(false, "Chưa có khóa bí mật Stripe để kiểm tra kết nối.");
        }
        try {
            StripeClient client = buildClient(secretKey);
            Balance balance = client.balance().retrieve();
            boolean live = Boolean.TRUE.equals(balance.getLivemode());
            return new TestResult(true, "Kết nối Stripe thành công (" + (live ? "Môi trường Live" : "Môi trường Test") + ").");
        } catch (AuthenticationException e) {
            return new TestResult(false, "Khóa bí mật Stripe không hợp lệ hoặc đã bị thu hồi.");
        } catch (StripeException e) {
            return new TestResult(false, "Không thể kết nối tới Stripe: " + e.getUserMessage());
        }
    }

    private SessionCreateParams.LineItem buildLineItem(String productName, String stripeProductId, long unitAmountVnd) {
        SessionCreateParams.LineItem.PriceData.Builder priceData =
                SessionCreateParams.LineItem.PriceData.builder()
                        .setCurrency("vnd")
                        .setUnitAmount(unitAmountVnd);

        if (stripeProductId != null && !stripeProductId.isBlank()) {
            priceData.setProduct(stripeProductId.trim());
        } else {
            priceData.setProductData(
                    SessionCreateParams.LineItem.PriceData.ProductData.builder()
                            .setName(productName)
                            .build()
            );
        }

        return SessionCreateParams.LineItem.builder()
                .setQuantity(1L)
                .setPriceData(priceData.build())
                .build();
    }

    private String enc(String val) {
        return URLEncoder.encode(val == null ? "" : val, StandardCharsets.UTF_8);
    }
}
