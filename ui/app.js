(() => {
    const root = document.getElementById('notifications');
    const maxQueue = 6;

    function normalizeType(type) {
        const value = String(type || 'info').toLowerCase();
        return ['info', 'success', 'error', 'warning'].includes(value) ? value : 'info';
    }

    function notify(data) {
        if (!data || !data.message) return;

        while (root.children.length >= maxQueue) {
            root.removeChild(root.firstElementChild);
        }

        const toast = document.createElement('div');
        const type = normalizeType(data.type);
        toast.className = `toast ${type}`;

        const title = document.createElement('div');
        title.className = 'toast-title';
        title.textContent = data.title || (type === 'error' ? 'Error' : 'Nyx');

        const message = document.createElement('div');
        message.className = 'toast-message';
        message.textContent = String(data.message);

        toast.appendChild(title);
        toast.appendChild(message);
        root.appendChild(toast);

        const duration = Math.max(1200, Number(data.duration || 4500));
        window.setTimeout(() => {
            toast.classList.add('hide');
            window.setTimeout(() => toast.remove(), 220);
        }, duration);
    }

    window.addEventListener('message', (event) => {
        const payload = event.data || {};
        if (payload.action === 'notify') notify(payload.data);
    });
})();
