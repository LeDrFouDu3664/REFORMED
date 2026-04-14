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
    } else if (event.data.action === 'updateHUD') {
        document.getElementById('hud-container').style.display = 'block';

        // MàJ Textes
        document.getElementById('hud-id').innerHTML = `<i class="fas fa-id-badge"></i> ID: ${event.data.id}`;
        document.getElementById('hud-time').innerHTML = `<i class="fas fa-clock"></i> ${event.data.time}`;
        document.getElementById('hud-date').innerHTML = `<i class="fas fa-calendar-alt"></i> ${event.data.date}`;

        document.getElementById('hud-money').innerText = `${event.data.money}$`;
        document.getElementById('hud-bank').innerText = `${event.data.bank}$`;
        document.getElementById('hud-black').innerText = `${event.data.black}$`;

        // MàJ Barres (en %)
        document.getElementById('bar-health').style.width = `${event.data.health}%`;
        document.getElementById('bar-armor').style.width = `${event.data.armor}%`;
        document.getElementById('bar-hunger').style.width = `${event.data.hunger}%`;
        document.getElementById('bar-thirst').style.width = `${event.data.thirst}%`;

    } else if (event.data.action === 'toggleDragMode') {
        const handle = document.getElementById('hud-drag-handle');
        if (event.data.state) {
            handle.style.display = 'block';
        } else {
            handle.style.display = 'none';
        }
    }
});

// Script de Drag & Drop (Déplacer le HUD)
const hudContainer = document.getElementById('hud-container');
const dragHandle = document.getElementById('hud-drag-handle');
let isDragging = false;
let offsetX, offsetY;

// Restauration de la position sauvegardée
const savedX = localStorage.getItem('prisonHUD_x');
const savedY = localStorage.getItem('prisonHUD_y');

if (savedX && savedY) {
    hudContainer.style.left = savedX;
    hudContainer.style.top = savedY;
    hudContainer.style.bottom = 'auto'; // Disable default bottom/right if saved
    hudContainer.style.right = 'auto';
}

dragHandle.addEventListener('mousedown', function(e) {
    isDragging = true;
    offsetX = e.clientX - hudContainer.getBoundingClientRect().left;
    offsetY = e.clientY - hudContainer.getBoundingClientRect().top;
});

window.addEventListener('mousemove', function(e) {
    if (isDragging) {
        let x = e.clientX - offsetX;
        let y = e.clientY - offsetY;
        hudContainer.style.left = `${x}px`;
        hudContainer.style.top = `${y}px`;
        hudContainer.style.bottom = 'auto';
        hudContainer.style.right = 'auto';
    }
});

window.addEventListener('mouseup', function(e) {
    if (isDragging) {
        isDragging = false;
        // Sauvegarder la position en local
        localStorage.setItem('prisonHUD_x', hudContainer.style.left);
        localStorage.setItem('prisonHUD_y', hudContainer.style.top);
    }
});

// Écouteur pour la touche Échap (pour fermer le HUD interactif)
document.addEventListener('keyup', function(e) {
    if (e.key === "Escape") {
        fetch(`https://${GetParentResourceName()}/closeEdit`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});