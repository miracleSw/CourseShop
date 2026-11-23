// CourseShop global interactive helpers (Lucide init, CSRF protection, AJAX cart/wishlist, copy, toast bus)
(function () {
  window.getCsrfToken = function () {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? (meta.getAttribute('content') || '') : '';
  };

  window.CourseShopToast = {
    push(type, message) {
      window.dispatchEvent(new CustomEvent('cs-toast', { detail: { type, message } }));
    }
  };

  window.copyText = async function (text, label) {
    try {
      await navigator.clipboard.writeText(text);
      window.CourseShopToast.push('success', 'Đã sao chép ' + (label || 'nội dung') + '.');
    } catch (e) {
      const ta = document.createElement('textarea');
      ta.value = text;
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      ta.remove();
      window.CourseShopToast.push('success', 'Đã sao chép ' + (label || 'nội dung') + '.');
    }
  };

  window.addToCartAsync = async function (courseId, btnEl) {
    const ctx = document.body.dataset.contextPath || '';
    if (btnEl) btnEl.disabled = true;
    try {
      const form = new URLSearchParams();
      form.append('action', 'add');
      form.append('courseId', String(courseId));

      const res = await fetch(ctx + '/cart', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': window.getCsrfToken()
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

  window.toggleWishlistAsync = async function (courseId, btnEl) {
    const ctx = document.body.dataset.contextPath || '';
    if (btnEl) btnEl.disabled = true;
    try {
      const res = await fetch(ctx + '/api/wishlist', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': window.getCsrfToken()
        },
        body: JSON.stringify({ courseId })
      });
      if (res.status === 401) {
        window.CourseShopToast.push('error', 'Vui lòng đăng nhập để lưu khóa học yêu thích.');
        setTimeout(() => { window.location.href = ctx + '/login'; }, 800);
        return;
      }
      const data = await res.json();
      if (res.ok && data.ok) {
        if (btnEl) {
          btnEl.dataset.saved = data.saved ? 'true' : 'false';
          const icon = btnEl.querySelector('svg, i');
          if (icon) {
            icon.classList.toggle('fill-danger', data.saved);
            icon.classList.toggle('text-danger', data.saved);
          }
          const label = btnEl.querySelector('[data-wishlist-label]');
          if (label) {
            label.textContent = data.saved ? 'Đã lưu yêu thích' : 'Lưu vào yêu thích';
          }
        }
        window.CourseShopToast.push('success', data.message);
      } else {
        window.CourseShopToast.push('error', (data && data.error) || 'Không thể cập nhật yêu thích.');
      }
    } catch (e) {
      window.CourseShopToast.push('error', 'Không thể kết nối máy chủ. Vui lòng thử lại.');
    } finally {
      if (btnEl) btnEl.disabled = false;
    }
  };

  function injectCsrfIntoForms() {
    const token = window.getCsrfToken();
    if (!token) return;
    document.querySelectorAll('form').forEach(form => {
      const method = (form.getAttribute('method') || 'get').toLowerCase();
      if (method !== 'post') return;
      if (!form.querySelector('input[name="_csrf"]')) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = '_csrf';
        input.value = token;
        form.appendChild(input);
      }
      // For multipart forms, also ensure _csrf query param so CsrfFilter verifies before multipart parsing
      const enc = (form.getAttribute('enctype') || '').toLowerCase();
      if (enc.includes('multipart/form-data')) {
        const action = form.getAttribute('action') || '';
        if (!action.includes('_csrf=')) {
          const sep = action.includes('?') ? '&' : '?';
          form.setAttribute('action', action + sep + '_csrf=' + encodeURIComponent(token));
        }
      }
    });
  }

  document.addEventListener('DOMContentLoaded', () => {
    injectCsrfIntoForms();
    if (window.lucide) {
      window.lucide.createIcons({ attrs: { 'stroke-width': 1.75 } });
    }
  });
})();
