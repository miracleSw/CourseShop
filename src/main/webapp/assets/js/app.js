// CourseShop global interactive helpers (Lucide init, AJAX cart, toast bus)
(function () {
  window.CourseShopToast = {
    push(type, message) {
      window.dispatchEvent(new CustomEvent('cs-toast', { detail: { type, message } }));
    }
  };

  window.addToCartAsync = async function (courseId, btnEl) {
    const ctx = document.body.dataset.contextPath || '';
    if (btnEl) {
      btnEl.disabled = true;
    }
    try {
      const form = new URLSearchParams();
      form.append('action', 'add');
      form.append('courseId', String(courseId));

      const res = await fetch(ctx + '/cart', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: form.toString()
      });
      const data = await res.json();
      if (typeof data.cartCount === 'number') {
        document.querySelectorAll('[data-cart-count]').forEach(el => {
          el.textContent = data.cartCount;
          el.classList.toggle('hidden', data.cartCount === 0);
        });
      }
      window.CourseShopToast.push(data.ok ? 'success' : 'error', data.message || 'Đã cập nhật giỏ hàng.');
      if (btnEl && data.ok) {
        btnEl.innerHTML = '<i data-lucide="check" class="w-4 h-4"></i><span>Trong giỏ</span>';
        if (window.lucide) window.lucide.createIcons();
      }
    } catch (e) {
      window.CourseShopToast.push('error', 'Không thể kết nối máy chủ. Vui lòng thử lại.');
    } finally {
      if (btnEl) btnEl.disabled = false;
    }
  };

  document.addEventListener('DOMContentLoaded', () => {
    if (window.lucide) {
      window.lucide.createIcons({ attrs: { 'stroke-width': 1.75 } });
    }
  });
})();
