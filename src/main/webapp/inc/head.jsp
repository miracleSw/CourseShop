<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${not empty pageTitle ? pageTitle : 'CourseShop — Giáo trình Lập trình Thực chiến'}"/></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=4">
    <script src="${pageContext.request.contextPath}/assets/js/vendor/lucide.min.js" defer></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js?v=3" defer></script>
    <script src="${pageContext.request.contextPath}/assets/js/chat-widget.js?v=3" defer></script>
    <c:if test="${includeLearnJs}">
        <script src="${pageContext.request.contextPath}/assets/js/learn.js?v=1" defer></script>
    </c:if>
    <c:if test="${includeChartJs}">
        <script src="${pageContext.request.contextPath}/assets/js/vendor/chart.umd.min.js" defer></script>
    </c:if>
    <script src="${pageContext.request.contextPath}/assets/js/vendor/alpine.min.js" defer></script>
</head>
<body class="${not empty bodyClass ? bodyClass : 'bg-paper text-ink antialiased flex flex-col min-h-screen'}"
      data-context-path="${pageContext.request.contextPath}">
