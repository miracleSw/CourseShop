package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.CertificateDAO;
import com.mycompany.courseshop.model.Certificate;
import com.mycompany.courseshop.utils.CsrfUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Public certificate showcase & verification page:
 * Supports both /certificate?code=CS-2026-XXXXXXXX and /certificate/CS-2026-XXXXXXXX.
 */
@WebServlet(name = "CertificateServlet", urlPatterns = {"/certificate", "/certificate/*"})
public class CertificateServlet extends HttpServlet {

    private final CertificateDAO certificateDAO = new CertificateDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String code = req.getParameter("code");
        if ((code == null || code.isBlank()) && req.getPathInfo() != null && req.getPathInfo().length() > 1) {
            code = req.getPathInfo().substring(1).trim();
        }

        if (code != null && !code.isBlank()) {
            Certificate cert = certificateDAO.findByCode(code);
            req.setAttribute("certificate", cert);
            req.setAttribute("lookupCode", code.trim().toUpperCase());
            if (cert != null) {
                String publicUrl = CsrfUtil.resolvePublicBaseUrl(req) + "/certificate/" + cert.getCertificateCode();
                req.setAttribute("verifyUrl", publicUrl);
                req.setAttribute("pageTitle", "Chứng chỉ " + cert.getCertificateCode() + " — CourseShop");
            } else {
                req.setAttribute("pageTitle", "Tra cứu chứng chỉ — CourseShop");
            }
        } else {
            req.setAttribute("pageTitle", "Tra cứu chứng chỉ — CourseShop");
        }
        req.getRequestDispatcher("/views/certificate.jsp").forward(req, resp);
    }
}
