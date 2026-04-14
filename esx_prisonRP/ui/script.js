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
        const widgets = document.querySelectorAll('.hud-widget');
        widgets.forEach(w => w.style.display = 'block'); // Afficher tous sauf véhicule par défaut

        // MàJ Textes
        document.getElementById('hud-id').innerHTML = `<i class="fas fa-id-badge"></i> ID: ${event.data.id}`;
        document.getElementById('hud-time').innerHTML = `<i class="fas fa-clock"></i> ${event.data.time}`;
        document.getElementById('hud-date').innerHTML = `<i class="fas fa-calendar-alt"></i> ${event.data.date}`;

        document.getElementById('hud-money').innerText = `${event.data.money}$`;
        document.getElementById('hud-bank').innerText = `${event.data.bank}$`;
        document.getElementById('hud-black').innerText = `${event.data.black}$`;

        // MàJ Anneaux (Calcul du clip-path basique)
        // Note: L'animation radiale parfaite en CSS nécessite un découpage complexe.
        // Ici, on gère la couleur ou la hauteur visuelle de l'icône comme repère.
        document.getElementById('ring-health').style.clipPath = `inset(${100 - event.data.health}% 0 0 0)`;
        document.getElementById('ring-armor').style.clipPath = `inset(${100 - event.data.armor}% 0 0 0)`;
        document.getElementById('ring-hunger').style.clipPath = `inset(${100 - event.data.hunger}% 0 0 0)`;
        document.getElementById('ring-thirst').style.clipPath = `inset(${100 - event.data.thirst}% 0 0 0)`;

        // HUD Véhicule
        if (event.data.inVehicle) {
            document.getElementById('hud-vehicle').style.display = 'block';
            document.getElementById('hud-speed').innerText = event.data.speed;
            document.getElementById('hud-gear').innerText = event.data.gear === 0 ? 'R' : event.data.gear;
        } else {
            document.getElementById('hud-vehicle').style.display = 'none';
        }

    } else if (event.data.action === 'toggleDragMode') {
        const handles = document.querySelectorAll('.hud-drag-handle');
        handles.forEach(handle => {
            handle.style.display = event.data.state ? 'block' : 'none';
        });
    }
});

// Drag & Drop Multi-Widgets
let isDragging = false;
let currentWidget = null;
let offsetX, offsetY;

const widgets = document.querySelectorAll('.hud-widget');

widgets.forEach(widget => {
    // Restauration
    const savedX = localStorage.getItem(`${widget.id}_x`);
    const savedY = localStorage.getItem(`${widget.id}_y`);
    if (savedX && savedY) {
        widget.style.left = savedX;
        widget.style.top = savedY;
        widget.style.bottom = 'auto';
        widget.style.right = 'auto';
    }

    const handle = widget.querySelector('.hud-drag-handle');
    handle.addEventListener('mousedown', function(e) {
        isDragging = true;
        currentWidget = widget;
        offsetX = e.clientX - widget.getBoundingClientRect().left;
        offsetY = e.clientY - widget.getBoundingClientRect().top;
    });
});

window.addEventListener('mousemove', function(e) {
    if (isDragging && currentWidget) {
        let x = e.clientX - offsetX;
        let y = e.clientY - offsetY;
        currentWidget.style.left = `${x}px`;
        currentWidget.style.top = `${y}px`;
        currentWidget.style.bottom = 'auto';
        currentWidget.style.right = 'auto';
    }
});

window.addEventListener('mouseup', function(e) {
    if (isDragging && currentWidget) {
        isDragging = false;
        localStorage.setItem(`${currentWidget.id}_x`, currentWidget.style.left);
        localStorage.setItem(`${currentWidget.id}_y`, currentWidget.style.top);
        currentWidget = null;
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