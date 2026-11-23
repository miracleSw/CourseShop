// Learning Workspace controller (/learn):
// Progress toggle + Auto Certificate, Coding Practice + Live Sandbox Preview,
// Multiple-Choice Quizzes, Timestamp Notes, Lesson Q&A Discussions, Sidebar
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
    certificateCode: cfg.certificateCode || '',
    sidebarOpen: window.innerWidth >= 1024,
    activeTab: 'overview',

    // Timestamp Notes
    noteMin: 0,
    noteSec: 0,
    noteText: '',
    savingNote: false,
    savingProgress: false,
    notes: cfg.initialNotes || [],

    // Coding Exercise
    exercise: cfg.exercise || null,
    exerciseCode: (cfg.exercise && (cfg.exercise.lastSubmittedCode || cfg.exercise.starterCode)) || '',
    exercisePassed: !!(cfg.exercise && cfg.exercise.passed),
    exerciseFeedback: (cfg.exercise && cfg.exercise.lastFeedback) || '',
    showHint: false,
    showSolution: false,
    submittingCode: false,
    previewSrcdoc: '',
    jsLogs: [],

    // Chapter / Lesson Quizzes
    quizzes: cfg.quizzes || [],
    selectedQuizId: null,
    quizAnswers: {},
    submittingQuiz: false,
    quizResults: {},

    // Lesson Q&A Discussions
    discussions: cfg.discussions || [],
    newQuestion: '',
    replyingToId: null,
    replyText: '',
    postingDiscussion: false,

    init() {
      if (this.quizzes.length > 0) {
        const current = this.quizzes.find(q => q.isCurrentSection) || this.quizzes[0];
        this.selectedQuizId = current.id;
      }
      if (this.exercise && (this.exercise.language === 'html' || this.exercise.language === 'css')) {
        this.runPreview();
      }
    },

    get activeQuiz() {
      return this.quizzes.find(q => q.id === this.selectedQuizId) || null;
    },

    get embedUrl() {
      if (!this.youtubeId) return '';
      return 'https://www.youtube.com/embed/' + this.youtubeId + '?enablejsapi=1&rel=0';
    },

    csrfHeaders() {
      return {
        'Content-Type': 'application/json;charset=UTF-8',
        'X-CSRF-Token': window.getCsrfToken ? window.getCsrfToken() : ''
      };
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
          headers: this.csrfHeaders(),
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
          if (data.certificateCode) {
            this.certificateCode = data.certificateCode;
          }
          const badge = document.querySelector('[data-lesson-check="' + this.lessonId + '"]');
          if (badge) {
            badge.classList.toggle('bg-emerald-ok', this.completed);
            badge.classList.toggle('text-white', this.completed);
            badge.classList.toggle('border-emerald-ok', this.completed);
          }
          if (data.certificateCode && this.percent === 100) {
            window.CourseShopToast.push('success', 'Chúc mừng bạn đã hoàn thành 100% khóa học và nhận chứng chỉ!');
          } else {
            window.CourseShopToast.push(
              'success',
              this.completed ? 'Đã đánh dấu hoàn thành bài học!' : 'Đã bỏ dấu hoàn thành bài học.'
            );
          }
        }
      } catch (e) {
        window.CourseShopToast.push('error', 'Không thể cập nhật tiến độ.');
      } finally {
        this.savingProgress = false;
      }
    },

    // --- Coding Exercise ---
    resetStarterCode() {
      if (!this.exercise) return;
      this.exerciseCode = this.exercise.starterCode || '';
      this.runPreview();
    },

    runPreview() {
      if (!this.exercise) return;
      const lang = (this.exercise.language || '').toLowerCase();
      if (lang === 'html') {
        this.previewSrcdoc = '<!doctype html><html><head><meta charset="utf-8"><style>body{font-family:system-ui,sans-serif;padding:14px;color:#16181D;background:#fff;margin:0;}</style></head><body>' + this.exerciseCode + '</body></html>';
      } else if (lang === 'css') {
        this.previewSrcdoc = '<!doctype html><html><head><meta charset="utf-8"><style>body{font-family:system-ui,sans-serif;padding:14px;background:#FAF8F3;margin:0;}' + this.exerciseCode + '</style></head><body><div class="card">Khối xem trước (.card) — CourseShop</div></body></html>';
      } else if (lang === 'javascript') {
        const logs = [];
        try {
          const fakeConsole = {
            log: (...args) => logs.push(args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a)).join(' '))
          };
          const fn = new Function('console', this.exerciseCode);
          fn(fakeConsole);
          this.jsLogs = logs.length ? logs : ['(Chạy xong — không có dữ liệu in ra console.log)'];
        } catch (err) {
          this.jsLogs = ['Lỗi cú pháp / thực thi: ' + err.message];
        }
      }
    },

    async submitExercise() {
      if (!this.exercise || this.submittingCode) return;
      this.submittingCode = true;
      this.runPreview();
      try {
        const res = await fetch(this.contextPath + '/api/practice', {
          method: 'POST',
          headers: this.csrfHeaders(),
          body: JSON.stringify({
            exerciseId: this.exercise.id,
            code: this.exerciseCode
          })
        });
        const data = await res.json();
        if (res.ok && data.ok) {
          this.exercisePassed = !!data.passed;
          this.exerciseFeedback = data.feedback || '';
          window.CourseShopToast.push(data.passed ? 'success' : 'error', data.feedback);
        } else {
          window.CourseShopToast.push('error', (data && data.error) || 'Không thể chấm bài thực hành.');
        }
      } catch (e) {
        window.CourseShopToast.push('error', 'Lỗi kết nối khi nộp bài thực hành.');
      } finally {
        this.submittingCode = false;
      }
    },

    // --- Multiple-Choice Quizzes ---
    selectAnswer(questionId, opt) {
      this.quizAnswers[String(questionId)] = opt;
    },

    getQuestionFeedback(quizId, questionId) {
      const r = this.quizResults[quizId];
      if (!r || !Array.isArray(r.details)) return null;
      return r.details.find(d => d.questionId === questionId) || null;
    },

    retakeQuiz(quizId) {
      delete this.quizResults[quizId];
      const q = this.quizzes.find(item => item.id === quizId);
      if (q) {
        q.questions.forEach(qq => delete this.quizAnswers[String(qq.id)]);
      }
    },

    async submitQuiz(quizId) {
      if (this.submittingQuiz) return;
      this.submittingQuiz = true;
      try {
        const res = await fetch(this.contextPath + '/api/quiz', {
          method: 'POST',
          headers: this.csrfHeaders(),
          body: JSON.stringify({
            quizId,
            answers: this.quizAnswers
          })
        });
        const data = await res.json();
        if (res.ok && data.ok) {
          this.quizResults[quizId] = data;
          const q = this.quizzes.find(item => item.id === quizId);
          if (q) {
            if (q.bestScore === null || q.bestScore === undefined || data.scorePercent > q.bestScore) {
              q.bestScore = data.scorePercent;
            }
            if (data.passed) q.passed = true;
          }
          window.CourseShopToast.push(
            data.passed ? 'success' : 'error',
            data.passed
              ? 'Đạt yêu cầu! Bạn trả lời đúng ' + data.correctCount + '/' + data.totalQuestions + ' câu (' + data.scorePercent + '%).'
              : 'Bạn đạt ' + data.scorePercent + '% (' + data.correctCount + '/' + data.totalQuestions + ' câu). Xem giải thích bên dưới và thử lại!'
          );
        } else {
          window.CourseShopToast.push('error', (data && data.error) || 'Không thể nộp bài kiểm tra.');
        }
      } catch (e) {
        window.CourseShopToast.push('error', 'Lỗi kết nối khi nộp bài kiểm tra.');
      } finally {
        this.submittingQuiz = false;
      }
    },

    // --- Timestamp Notes ---
    async addNote() {
      const text = this.noteText.trim();
      if (!text || this.savingNote) return;
      const ts = Math.max(0, (parseInt(this.noteMin || 0, 10) * 60) + parseInt(this.noteSec || 0, 10));
      this.savingNote = true;
      try {
        const res = await fetch(this.contextPath + '/api/notes', {
          method: 'POST',
          headers: this.csrfHeaders(),
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
          window.CourseShopToast.push('error', (data && data.error) || 'Không thể lưu ghi chú.');
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
          headers: this.csrfHeaders(),
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
    },

    // --- Lesson Q&A Discussions ---
    async postQuestion() {
      const text = this.newQuestion.trim();
      if (text.length < 3 || this.postingDiscussion) return;
      this.postingDiscussion = true;
      try {
        const res = await fetch(this.contextPath + '/api/discussions', {
          method: 'POST',
          headers: this.csrfHeaders(),
          body: JSON.stringify({
            action: 'add',
            courseId: this.courseId,
            lessonId: this.lessonId,
            content: text
          })
        });
        const data = await res.json();
        if (res.ok && data.ok && data.item) {
          this.discussions.unshift(data.item);
          this.newQuestion = '';
          window.CourseShopToast.push('success', 'Đã đăng câu hỏi thảo luận.');
        } else {
          window.CourseShopToast.push('error', (data && data.error) || 'Không thể gửi câu hỏi.');
        }
      } catch (e) {
        window.CourseShopToast.push('error', 'Lỗi kết nối khi gửi câu hỏi.');
      } finally {
        this.postingDiscussion = false;
      }
    },

    async postReply(parentId) {
      const text = this.replyText.trim();
      if (text.length < 3 || this.postingDiscussion) return;
      this.postingDiscussion = true;
      try {
        const res = await fetch(this.contextPath + '/api/discussions', {
          method: 'POST',
          headers: this.csrfHeaders(),
          body: JSON.stringify({
            action: 'add',
            courseId: this.courseId,
            lessonId: this.lessonId,
            parentId,
            content: text
          })
        });
        const data = await res.json();
        if (res.ok && data.ok && data.item) {
          const parent = this.discussions.find(d => d.id === parentId);
          if (parent) parent.replies.push(data.item);
          this.replyText = '';
          this.replyingToId = null;
          window.CourseShopToast.push('success', 'Đã gửi phản hồi.');
        } else {
          window.CourseShopToast.push('error', (data && data.error) || 'Không thể gửi phản hồi.');
        }
      } catch (e) {
        window.CourseShopToast.push('error', 'Lỗi kết nối khi gửi phản hồi.');
      } finally {
        this.postingDiscussion = false;
      }
    },

    async deleteDiscussion(id, parentId) {
      try {
        const res = await fetch(this.contextPath + '/api/discussions', {
          method: 'POST',
          headers: this.csrfHeaders(),
          body: JSON.stringify({ action: 'delete', discussionId: id })
        });
        const data = await res.json();
        if (res.ok && data.ok) {
          if (parentId) {
            const p = this.discussions.find(d => d.id === parentId);
            if (p) p.replies = p.replies.filter(r => r.id !== id);
          } else {
            this.discussions = this.discussions.filter(d => d.id !== id);
          }
          window.CourseShopToast.push('success', 'Đã xóa bình luận.');
        }
      } catch (e) {
        window.CourseShopToast.push('error', 'Không thể xóa bình luận.');
      }
    }
  }));
});
