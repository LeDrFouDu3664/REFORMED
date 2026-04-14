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
        document.getElementById('hud-id').innerHTML = `<i class="fas fa-id-badge"></i> ${event.data.id}`;
        document.getElementById('hud-time').innerHTML = `<i class="fas fa-clock"></i> ${event.data.time}`;
        document.getElementById('hud-date').innerHTML = `<i class="fas fa-calendar-alt"></i> ${event.data.date}`;

        document.getElementById('hud-money').innerText = `${event.data.money}$`;
        document.getElementById('hud-bank').innerText = `${event.data.bank}$`;
        document.getElementById('hud-black').innerText = `${event.data.black}$`;

        // MàJ Barres (Flat Design)
        document.getElementById('bar-health').style.width = `${event.data.health}%`;
        document.getElementById('bar-armor').style.width = `${event.data.armor}%`;
        document.getElementById('bar-hunger').style.width = `${event.data.hunger}%`;
        document.getElementById('bar-thirst').style.width = `${event.data.thirst}%`;

        // HUD Véhicule
        if (event.data.inVehicle) {
            document.getElementById('hud-vehicle').style.display = 'block';
            document.getElementById('hud-speed').innerText = event.data.speed;
            document.getElementById('hud-gear').innerText = event.data.gear === 0 ? 'R' : event.data.gear;

            // Clignotants
            document.getElementById('indicator-left').className = event.data.indicatorL ? 'fas fa-arrow-left active' : 'fas fa-arrow-left';
            document.getElementById('indicator-right').className = event.data.indicatorR ? 'fas fa-arrow-right active' : 'fas fa-arrow-right';

            // Essence (Rouge si < 15%)
            const fuelEl = document.getElementById('hud-fuel');
            if (event.data.fuel < 15) { fuelEl.style.color = '#e74c3c'; fuelEl.style.textShadow = '0 0 5px #e74c3c'; }
            else { fuelEl.style.color = '#f1c40f'; fuelEl.style.textShadow = 'none'; }

            // Ceinture
            const seatbeltEl = document.getElementById('hud-seatbelt');
            if (event.data.seatbelt) { seatbeltEl.style.color = '#2ecc71'; seatbeltEl.style.textShadow = '0 0 5px #2ecc71'; }
            else { seatbeltEl.style.color = '#e74c3c'; seatbeltEl.style.textShadow = 'none'; }

            // Régulateur
            const cruiseEl = document.getElementById('hud-cruise');
            if (event.data.cruiseControl) { cruiseEl.style.color = '#3498db'; cruiseEl.style.textShadow = '0 0 5px #3498db'; }
            else { cruiseEl.style.color = '#95a5a6'; cruiseEl.style.textShadow = 'none'; }

        } else {
            document.getElementById('hud-vehicle').style.display = 'none';
        }

    } else if (event.data.action === 'hideHUD') {
        const widgets = document.querySelectorAll('.hud-widget');
        widgets.forEach(w => w.style.display = 'none');
    } else if (event.data.action === 'toggleDragMode') {
        const handles = document.querySelectorAll('.hud-drag-handle');
        handles.forEach(handle => {
            handle.style.display = event.data.state ? 'block' : 'none';
        });
        document.getElementById('hud-color-picker').style.display = event.data.state ? 'block' : 'none';
    }
});

// Color Picker Logic
const colorPrimary = document.getElementById('color-primary');
const colorShadow = document.getElementById('color-shadow');
const colorBg = document.getElementById('color-bg');
const btnResetColors = document.getElementById('btn-reset-colors');

function applyColors(primary, shadow, bg) {
    document.documentElement.style.setProperty('--hud-text-color', primary);
    document.documentElement.style.setProperty('--hud-shadow-color', shadow);
    document.documentElement.style.setProperty('--hud-bg-color', bg);

    localStorage.setItem('prisonHUD_colorPrimary', primary);
    localStorage.setItem('prisonHUD_colorShadow', shadow);
    localStorage.setItem('prisonHUD_colorBg', bg);
}

// Charger couleurs
const savedColorPrimary = localStorage.getItem('prisonHUD_colorPrimary');
const savedColorShadow = localStorage.getItem('prisonHUD_colorShadow');
const savedColorBg = localStorage.getItem('prisonHUD_colorBg');

if (savedColorPrimary && savedColorShadow && savedColorBg) {
    colorPrimary.value = savedColorPrimary;
    colorShadow.value = savedColorShadow;
    colorBg.value = savedColorBg;
    applyColors(savedColorPrimary, savedColorShadow, savedColorBg);
}

colorPrimary.addEventListener('input', (e) => applyColors(e.target.value, colorShadow.value, colorBg.value));
colorShadow.addEventListener('input', (e) => applyColors(colorPrimary.value, e.target.value, colorBg.value));
colorBg.addEventListener('input', (e) => applyColors(colorPrimary.value, colorShadow.value, e.target.value));

btnResetColors.addEventListener('click', () => {
    colorPrimary.value = '#ffffff';
    colorShadow.value = '#000000';
    colorBg.value = '#000000';
    applyColors('#ffffff', '#000000', '#000000');
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