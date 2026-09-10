// js/chats.js

let activeSessionId = null;
let refreshInterval = null;

async function loadSessions() {
    try {
        const response = await api.get('/admin/sessions');
        const listEl = document.getElementById('chat-list');
        listEl.innerHTML = '';
        
        const sessions = response.data || [];
        
        if (sessions.length === 0) {
            listEl.innerHTML = '<div style="padding: 20px; text-align: center; color: #666;">Hozircha chatlar yo\'q</div>';
            return;
        }
        
        sessions.forEach(session => {
            const item = document.createElement('div');
            item.className = `chat-item ${activeSessionId === session.id ? 'active' : ''}`;
            item.onclick = () => selectChat(session);
            
            const time = new Date(session.updated_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
            
            let statusHtml = '';
            if (session.is_resolved) {
                statusHtml = '<span class="status-badge resolved">Yopilgan</span>';
            } else {
                statusHtml = '<span class="status-badge active">Ochiq</span>';
            }
            
            item.innerHTML = `
                <div class="chat-item-time">${time}</div>
                <div class="chat-item-name">${session.name} ${statusHtml}</div>
                <div class="chat-item-phone">${session.phone}</div>
            `;
            
            listEl.appendChild(item);
        });
    } catch (error) {
        console.error("Error loading sessions", error);
    }
}

async function selectChat(session) {
    activeSessionId = session.id;
    
    document.getElementById('chat-empty-state').style.display = 'none';
    document.getElementById('chat-active-state').style.display = 'flex';
    
    document.getElementById('active-chat-name').textContent = session.name;
    document.getElementById('active-chat-phone').textContent = session.phone;
    
    const resolveBtn = document.getElementById('resolve-btn');
    if (session.is_resolved) {
        resolveBtn.style.display = 'none';
    } else {
        resolveBtn.style.display = 'block';
    }
    
    // Update active class in list
    document.querySelectorAll('.chat-item').forEach(el => el.classList.remove('active'));
    
    await loadMessages();
    
    // Setup interval for polling messages
    if (refreshInterval) clearInterval(refreshInterval);
    refreshInterval = setInterval(loadMessages, 3000);
}

async function loadMessages() {
    if (!activeSessionId) return;
    
    try {
        const response = await api.get(`/chat/${activeSessionId}/messages`);
        const messages = response.data || [];
        
        const container = document.getElementById('chat-messages');
        const isScrolledToBottom = container.scrollHeight - container.clientHeight <= container.scrollTop + 1;
        
        container.innerHTML = '';
        
        if (messages.length === 0) {
            container.innerHTML = '<div style="text-align:center; color:#999; margin-top: 20px;">Hali xabarlar yo\'q</div>';
        } else {
            messages.forEach(msg => {
                const bubble = document.createElement('div');
                bubble.className = `msg-bubble ${msg.sender}`;
                
                const time = new Date(msg.created_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                
                bubble.innerHTML = `
                    <div>${msg.text}</div>
                    <div class="msg-time">${time}</div>
                `;
                
                container.appendChild(bubble);
            });
        }
        
        // Scroll to bottom if we were already at the bottom or if this is the first load
        if (isScrolledToBottom || container.children.length > 0) {
            container.scrollTop = container.scrollHeight;
        }
        
    } catch (error) {
        console.error("Error loading messages", error);
    }
}

async function sendMessage() {
    if (!activeSessionId) return;
    
    const input = document.getElementById('chat-input');
    const text = input.value.trim();
    
    if (!text) return;
    
    try {
        input.disabled = true;
        await api.post(`/admin/${activeSessionId}/messages`, { text });
        
        input.value = '';
        await loadMessages();
        loadSessions(); // refresh list to update time/status
        
        // Scroll to bottom
        const container = document.getElementById('chat-messages');
        container.scrollTop = container.scrollHeight;
        
    } catch (error) {
        alert("Xabar yuborishda xatolik: " + error.message);
    } finally {
        input.disabled = false;
        input.focus();
    }
}

function handleKeyPress(e) {
    if (e.key === 'Enter') {
        sendMessage();
    }
}

async function resolveChat() {
    if (!activeSessionId) return;
    
    if (confirm("Bu chatni yakunlamoqchimisiz?")) {
        try {
            await api.put(`/admin/${activeSessionId}/resolve`);
            await loadSessions();
            
            document.getElementById('resolve-btn').style.display = 'none';
        } catch (error) {
            alert("Xatolik: " + error.message);
        }
    }
}

// Initial load
document.addEventListener('DOMContentLoaded', () => {
    auth.requireAdmin();
    
    document.getElementById('current-username').textContent = auth.getUser()?.full_name || 'Admin';
    
    loadSessions();
    setInterval(loadSessions, 5000); // refresh list every 5s
});
