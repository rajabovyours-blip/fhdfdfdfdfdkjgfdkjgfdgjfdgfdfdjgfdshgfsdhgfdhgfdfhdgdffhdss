/**
 * Admin chat — mijozlar bilan yozishmalar.
 *
 * Backend endpointlari:
 *   GET  /chat/admin/sessions?is_resolved=      — suhbatlar ro'yxati
 *   POST /chat/admin/{id}/messages              — admin javobi
 *   PUT  /chat/admin/{id}/resolve               — suhbatni yopish
 *   GET  /chat/{id}/messages                    — xabarlar
 */

let sessions = [];
let activeSessionId = null;
let pollTimer = null;

document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();

  loadSessions();

  document.getElementById('btn-refresh').addEventListener('click', loadSessions);
  document.getElementById('filter-resolved').addEventListener('change', () => {
    activeSessionId = null;
    loadSessions();
  });

  // Ochiq suhbatni har 10 soniyada yangilab turamiz — mijoz yozsa darhol ko'rinadi
  pollTimer = setInterval(() => {
    if (activeSessionId) loadMessages(activeSessionId, true);
  }, 10000);
});

window.addEventListener('beforeunload', () => {
  if (pollTimer) clearInterval(pollTimer);
});

function fmtTime(iso) {
  if (!iso) return '';
  const locale = i18n.lang === 'ru' ? 'ru-RU' : 'uz-UZ';
  return new Date(iso).toLocaleString(locale, {
    day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit',
  });
}

function escapeHtml(s) {
  return String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

async function loadSessions() {
  const host = document.getElementById('session-list');
  host.innerHTML = `<div style="padding:16px; color:var(--text-medium); font-size:13px;">${i18n.t('loading')}</div>`;

  const filter = document.getElementById('filter-resolved').value;
  const qs = filter === '' ? '' : `?is_resolved=${filter}`;

  try {
    const res = await api.get(`/chat/admin/sessions${qs}`);
    sessions = res.data || [];
    renderSessions();
  } catch (err) {
    host.innerHTML = `<div style="padding:16px; color:var(--color-danger); font-size:13px;">${escapeHtml(err.message)}</div>`;
  }
}

function renderSessions() {
  const host = document.getElementById('session-list');

  if (sessions.length === 0) {
    host.innerHTML = `<div style="padding:16px; color:var(--text-medium); font-size:13px;">${i18n.t('noData')}</div>`;
    return;
  }

  host.innerHTML = sessions.map(s => {
    const msgs = s.messages || [];
    const last = msgs.length ? msgs[msgs.length - 1] : null;
    const preview = last ? escapeHtml(last.text) : '—';
    const resolvedBadge = s.is_resolved
      ? `<span class="badge badge-success" style="font-size:10px;">${i18n.t('chatResolved')}</span>`
      : `<span class="badge badge-warning" style="font-size:10px;">${i18n.t('chatOpen')}</span>`;

    return `
      <div class="session-item ${s.id === activeSessionId ? 'active' : ''}" onclick="openSession('${s.id}')">
        <div class="d-flex justify-content-between align-items-center" style="gap:8px;">
          <span class="session-name">${escapeHtml(s.name)}</span>
          ${resolvedBadge}
        </div>
        <div class="session-phone">${escapeHtml(s.phone)}</div>
        <div class="session-preview">${preview}</div>
        <div style="font-size:10px; color:var(--text-medium); margin-top:4px;">${fmtTime(s.updated_at)}</div>
      </div>
    `;
  }).join('');
}

async function openSession(id) {
  activeSessionId = id;
  renderSessions();

  const session = sessions.find(s => s.id === id);
  if (!session) return;

  const thread = document.getElementById('chat-thread');
  thread.innerHTML = `
    <div class="chat-header">
      <div>
        <div style="font-weight:600;">${escapeHtml(session.name)}</div>
        <div style="font-size:12px; color:var(--text-medium);">${escapeHtml(session.phone)}</div>
      </div>
      <button class="btn btn-sm btn-outline" id="btn-resolve">
        <span class="material-symbols-rounded" style="font-size:18px;">check_circle</span>
        <span>${i18n.t('chatResolve')}</span>
      </button>
    </div>
    <div class="chat-messages" id="chat-messages">
      <div style="color:var(--text-medium); font-size:13px;">${i18n.t('loading')}</div>
    </div>
    <div class="chat-input">
      <input type="text" class="form-control" id="msg-input" placeholder="${i18n.t('chatWriteMessage')}">
      <button class="btn btn-primary" id="btn-send">
        <span class="material-symbols-rounded" style="font-size:18px;">send</span>
      </button>
    </div>
  `;

  document.getElementById('btn-send').addEventListener('click', sendMessage);
  document.getElementById('msg-input').addEventListener('keydown', (e) => {
    if (e.key === 'Enter') sendMessage();
  });
  document.getElementById('btn-resolve').addEventListener('click', resolveSession);

  loadMessages(id);
}

async function loadMessages(sessionId, silent = false) {
  const host = document.getElementById('chat-messages');
  if (!host) return;

  try {
    const res = await api.get(`/chat/${sessionId}/messages`);
    const msgs = res.data || [];

    if (msgs.length === 0) {
      host.innerHTML = `<div style="color:var(--text-medium); font-size:13px;">${i18n.t('noData')}</div>`;
      return;
    }

    host.innerHTML = msgs.map(m => `
      <div class="msg ${m.sender === 'admin' ? 'msg-admin' : 'msg-user'}">
        <div>${escapeHtml(m.text)}</div>
        <div class="msg-time">${fmtTime(m.created_at)}</div>
      </div>
    `).join('');

    host.scrollTop = host.scrollHeight;
  } catch (err) {
    if (!silent) {
      host.innerHTML = `<div style="color:var(--color-danger); font-size:13px;">${escapeHtml(err.message)}</div>`;
    }
  }
}

async function sendMessage() {
  const input = document.getElementById('msg-input');
  const text = input.value.trim();
  if (!text || !activeSessionId) return;

  const btn = document.getElementById('btn-send');
  btn.disabled = true;
  input.value = '';

  try {
    await api.post(`/chat/admin/${activeSessionId}/messages`, { text: text });
    await loadMessages(activeSessionId);
    loadSessions();
  } catch (err) {
    layout.showToast(err.message, 'error');
    input.value = text; // xato bo'lsa matnni qaytaramiz
  } finally {
    btn.disabled = false;
    input.focus();
  }
}

async function resolveSession() {
  if (!activeSessionId) return;
  if (!confirm(i18n.t('chatResolveConfirm'))) return;

  try {
    await api.put(`/chat/admin/${activeSessionId}/resolve`);
    layout.showToast(i18n.t('success'));
    loadSessions();
  } catch (err) {
    layout.showToast(err.message, 'error');
  }
}
