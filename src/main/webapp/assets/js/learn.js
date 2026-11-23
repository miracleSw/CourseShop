// Learning Workspace controller (/learn): Progress toggle, Timestamp Notes, Video seek, Sidebar
document.addEventListener('alpine:init', () => {
  Alpine.data('learnWorkspace', (cfg) => ({
    courseId: cfg.courseId,
    lessonId: cfg.lessonId,
    youtubeId: cfg.youtubeId || '',
    contextPath: cfg.contextPath || '',
    completed: !!cfg.completed,
    doneCount: cfg.doneCount || 0,
    totalCount: cfg.totalCount || 0,
    percent: cfg.percent || 0,
    sidebarOpen: window.innerWidth >= 1024,
    activeTab: 'overview',
    noteMin: 0,
    noteSec: 0,
    noteText: '',
    savingNote: false,
    savingProgress: false,
    notes: cfg.initialNotes || [],

    get embedUrl() {
      if (!this.youtubeId) return '';
      return 'https://www.youtube.com/embed/' + this.youtubeId + '?enablejsapi=1&rel=0';
    },

    seekTo(seconds) {
      const iframe = this.$refs.ytPlayer;
      if (!iframe || !this.youtubeId) return;
      iframe.src = 'https://www.youtube.com/embed/' + this.youtubeId + '?start=' + Math.max(0, seconds) + '&autoplay=1&rel=0';
      window.CourseShopToast.push('success', 'Đã chuyển video tới mốc ' + this.formatTs(seconds));
    },

    formatTs(seconds) {
      const s = Math.max(0, parseInt(seconds || 0, 10));
      const m = Math.floor(s / 60);
      const sec = s % 60;
      return String(m).padStart(2, '0') + ':' + String(sec).padStart(2, '0');
    },

    async toggleComplete() {
      if (this.savingProgress) return;
      this.savingProgress = true;
      const next = !this.completed;
      try {
        const res = await fetch(this.contextPath + '/api/progress', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json;charset=UTF-8' },
          body: JSON.stringify({
            courseId: this.courseId,
            lessonId: this.lessonId,
            completed: next
          })
        });
        const data = await res.json();
        if (res.ok && data.ok) {
          this.completed = data.completed;
          this.doneCount = data.done;
          this.totalCount = data.total;
          this.percent = data.percent;
          const badge = document.querySelector('[data-lesson-check="' + this.lessonId + '"]');
          if (badge) {
            badge.classList.toggle('bg-emerald-ok', this.completed);
            badge.classList.toggle('text-white', this.completed);
            badge.classList.toggle('border-emerald-ok', this.completed);
          }
          window.CourseShopToast.push(
            'success',
            this.completed ? 'Đã đánh dấu hoàn thành bài học!' : 'Đã bỏ dấu hoàn thành bài học.'
          );
        }
      } catch (e) {
        window.CourseShopToast.push('error', 'Không thể cập nhật tiến độ.');
      } finally {
        this.savingProgress = false;
      }
    },

    async addNote() {
      const text = this.noteText.trim();
      if (!text || this.savingNote) return;
      const ts = Math.max(0, (parseInt(this.noteMin || 0, 10) * 60) + parseInt(this.noteSec || 0, 10));
      this.savingNote = true;
      try {
        const res = await fetch(this.contextPath + '/api/notes', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json;charset=UTF-8' },
          body: JSON.stringify({
            action: 'add',
            courseId: this.courseId,
            lessonId: this.lessonId,
            timestampSeconds: ts,
            noteText: text
          })
        });
        const data = await res.json();
        if (res.ok && data.ok && data.note) {
          this.notes.push(data.note);
          this.notes.sort((a, b) => a.timestampSeconds - b.timestampSeconds);
          this.noteText = '';
          window.CourseShopToast.push('success', 'Đã lưu ghi chú tại mốc ' + data.note.formattedTimestamp);
          this.$nextTick(() => {
            if (window.lucide) window.lucide.createIcons({ attrs: { 'stroke-width': 1.75 } });
          });
        } else {
          window.CourseShopToast.push('error', data.error || 'Không thể lưu ghi chú.');
        }
      } catch (e) {
        window.CourseShopToast.push('error', 'Lỗi kết nối khi lưu ghi chú.');
      } finally {
        this.savingNote = false;
      }
    },

    async deleteNote(noteId) {
      try {
        const res = await fetch(this.contextPath + '/api/notes', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json;charset=UTF-8' },
          body: JSON.stringify({ action: 'delete', noteId })
        });
        const data = await res.json();
        if (res.ok && data.ok) {
          this.notes = this.notes.filter(n => n.id !== noteId);
          window.CourseShopToast.push('success', 'Đã xóa ghi chú.');
        }
      } catch (e) {
        window.CourseShopToast.push('error', 'Không thể xóa ghi chú.');
      }
    }
  }));
});
