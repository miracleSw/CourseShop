// Floating AI Tutor & Course Advisor Widget (Backend API driven — zero mock responses)
document.addEventListener('alpine:init', () => {
  Alpine.data('aiChatWidget', (config) => ({
    open: false,
    loaded: false,
    loadingHistory: false,
    loading: false,
    available: null,
    statusText: 'Đang kiểm tra...',
    input: '',
    lastFailedText: '',
    courseId: config.courseId || null,
    lessonId: config.lessonId || null,
    contextPath: config.contextPath || '',
    greeting: {
      role: 'model',
      isError: false,
      html: config.courseId
        ? 'Xin chào! Bạn cần giải thích kiến thức, ví dụ minh họa hay hỗ trợ về bài học đang xem?'
        : 'Xin chào! Bạn đang tìm lộ trình học phù hợp hay cần tư vấn chọn khóa học?'
    },
    messages: [],
    quickPrompts: [],

    init() {
      this.messages = [this.greeting];
    },

    async loadFromBackend() {
      if (this.loaded) return;
      this.loaded = true;
      this.loadingHistory = true;
      try {
        const qs = this.courseId ? ('?courseId=' + encodeURIComponent(this.courseId)) : '';
        const res = await fetch(this.contextPath + '/api/chat' + qs);
        if (!res.ok) {
          this.available = false;
          this.statusText = 'Hiện tạm ngưng';
          return;
        }
        const data = await res.json();
        this.available = !!data.available;
        this.statusText = data.statusText || (this.available ? 'Sẵn sàng hỗ trợ' : 'Hiện tạm ngưng');
        if (Array.isArray(data.quickPrompts)) {
          this.quickPrompts = data.quickPrompts;
        }
        if (Array.isArray(data.messages) && data.messages.length > 0) {
          this.messages = [
            this.greeting,
            ...data.messages.map((m) => ({
              role: m.role,
              isError: false,
              html: m.role === 'user' ? this.escapeHtml(m.text) : this.formatMarkdown(m.text)
            }))
          ];
          this.$nextTick(() => this.scrollToBottom());
        }
      } catch (e) {
        this.available = false;
        this.statusText = 'Không thể kết nối';
      } finally {
        this.loadingHistory = false;
        this.$nextTick(() => {
          if (window.lucide) window.lucide.createIcons({ attrs: { 'stroke-width': 1.75 } });
        });
      }
    },

    toggle() {
      this.open = !this.open;
      if (this.open) {
        this.loadFromBackend();
        this.$nextTick(() => {
          this.scrollToBottom();
          if (window.lucide) window.lucide.createIcons({ attrs: { 'stroke-width': 1.75 } });
        });
      }
    },

    retryLast() {
      if (!this.lastFailedText || this.loading) return;
      const text = this.lastFailedText;
      this.lastFailedText = '';
      this.send(text, true);
    },

    async send(preset, isRetry = false) {
      const text = (preset !== undefined ? preset : this.input).trim();
      if (!text || this.loading || this.available === false) return;
      this.input = '';
      this.lastFailedText = '';
      if (!isRetry) {
        this.messages.push({ role: 'user', isError: false, html: this.escapeHtml(text) });
      }
      this.loading = true;
      this.$nextTick(() => this.scrollToBottom());

      try {
        const res = await fetch(this.contextPath + '/api/chat', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json;charset=UTF-8',
            'X-CSRF-Token': window.getCsrfToken ? window.getCsrfToken() : ''
          },
          body: JSON.stringify({
            message: text,
            courseId: this.courseId,
            lessonId: this.lessonId
          })
        });
        let data = null;
        try {
          data = await res.json();
        } catch (parseErr) {
          data = null;
        }
        if (!res.ok || !data || !data.ok) {
          if (data && data.code === 'SERVICE_UNAVAILABLE') {
            this.available = false;
            this.statusText = 'Hiện tạm ngưng';
          } else {
            this.lastFailedText = text;
          }
          const errMsg = (data && data.error) ? data.error : 'Không thể nhận phản hồi lúc này. Vui lòng thử lại.';
          this.messages.push({
            role: 'model',
            isError: true,
            html: this.escapeHtml(errMsg)
          });
        } else {
          this.available = true;
          this.statusText = data.statusText || 'Sẵn sàng hỗ trợ';
          this.messages.push({ role: 'model', isError: false, html: this.formatMarkdown(data.reply || '') });
        }
      } catch (err) {
        this.lastFailedText = text;
        this.messages.push({
          role: 'model',
          isError: true,
          html: 'Không thể kết nối tới máy chủ. Vui lòng kiểm tra mạng và thử lại.'
        });
      } finally {
        this.loading = false;
        this.$nextTick(() => {
          this.scrollToBottom();
          if (window.lucide) window.lucide.createIcons({ attrs: { 'stroke-width': 1.75 } });
        });
      }
    },

    async resetChat() {
      if (this.loading) return;
      try {
        const qs = this.courseId ? ('?courseId=' + encodeURIComponent(this.courseId)) : '';
        await fetch(this.contextPath + '/api/chat' + qs, {
          method: 'DELETE',
          headers: { 'X-CSRF-Token': window.getCsrfToken ? window.getCsrfToken() : '' }
        });
      } catch (e) {}
      this.lastFailedText = '';
      this.messages = [this.greeting];
    },

    scrollToBottom() {
      const el = this.$refs.chatBody;
      if (el) el.scrollTop = el.scrollHeight;
    },

    escapeHtml(str) {
      return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
    },

    formatMarkdown(raw) {
      let s = this.escapeHtml(raw);
      s = s.replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, (_, label, url) => {
        const safeUrl = url.startsWith('/') || url.startsWith('http://') || url.startsWith('https://') ? url : '#';
        return '<a href="' + safeUrl + '" class="underline font-semibold text-blueprint hover:text-blueprint-hover">' + label + '</a>';
      });
      s = s.replace(/`([^`]+)`/g, '<code class="font-mono text-xs bg-paper px-1.5 py-0.5 rounded border border-rule">$1</code>');
      s = s.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
      s = s.replace(/\n/g, '<br>');
      return s;
    }
  }));
});
