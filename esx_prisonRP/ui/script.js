window.addEventListener('message', function(event) {
    if (event.data.action === 'showCustomChat') {
        const container = document.getElementById('notification-container');

        const notification = document.createElement('div');
        notification.classList.add('notification', `notification-${event.data.type}`);

        let icon = '';
        if (event.data.type === 'system') icon = '<i class="fas fa-volume-up"></i> ';
        else if (event.data.type === 'radio') icon = '<i class="fas fa-broadcast-tower"></i> ';
        else if (event.data.type === 'guide') icon = '<i class="fas fa-user-circle"></i> ';
        else icon = '<i class="fas fa-mask"></i> ';

        notification.innerHTML = `
            <div class="header">${icon}${event.data.author}</div>
            <div class="message">${event.data.text}</div>
        `;

        container.prepend(notification);

        // Nettoyer le DOM après l'animation (8.5s)
        setTimeout(() => {
            notification.remove();
        }, 8500);
    }
});