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
        document.getElementById('hud-id').innerText = event.data.id;
        document.getElementById('hud-time').innerText = event.data.time;
        document.getElementById('hud-date').innerText = event.data.date;

        document.getElementById('hud-money').innerText = `${event.data.money}$`;
        document.getElementById('hud-bank').innerText = `${event.data.bank}$`;
        document.getElementById('hud-black').innerText = `${event.data.black}$`;

        // MàJ Cercles Vitaux (Calcul du stroke-dashoffset, dasharray = 100)
        document.getElementById('circle-health').style.strokeDashoffset = 100 - event.data.health;
        document.getElementById('circle-armor').style.strokeDashoffset = 100 - event.data.armor;
        document.getElementById('circle-hunger').style.strokeDashoffset = 100 - event.data.hunger;
        document.getElementById('circle-thirst').style.strokeDashoffset = 100 - event.data.thirst;

        // MàJ Micro
        const micCircle = document.getElementById('circle-mic');
        const micIcon = document.getElementById('mic-icon');
        if (event.data.isTalking) {
            micCircle.style.strokeDashoffset = 0; // Plein quand on parle
            micCircle.style.stroke = 'var(--mic-active)';
            micIcon.style.color = 'var(--mic-active)';
        } else {
            micCircle.style.strokeDashoffset = 100; // Vide
            micCircle.style.stroke = 'var(--mic-inactive)';
            micIcon.style.color = 'var(--mic-inactive)';
        }

        // HUD Véhicule
        if (event.data.inVehicle) {
            document.getElementById('hud-vehicle').style.display = 'flex';
            document.getElementById('hud-speed').innerText = event.data.speed;
            document.getElementById('hud-gear').innerText = event.data.gear === 0 ? 'R' : event.data.gear;

            // Compteur Vitesse (Demi-cercle, dasharray = 110 max)
            const speedoMax = 250; // Vitesse max estimée pour remplir la jauge
            let speedPercent = (event.data.speed / speedoMax) * 100;
            if (speedPercent > 100) speedPercent = 100;
            const offset = 110 - (110 * (speedPercent / 100));
            document.getElementById('speedo-path').style.strokeDashoffset = offset;

            // Changer la couleur en fonction de la vitesse
            if (speedPercent > 80) document.getElementById('speedo-path').style.stroke = 'var(--black-color)';
            else if (speedPercent > 50) document.getElementById('speedo-path').style.stroke = 'var(--hunger-color)';
            else document.getElementById('speedo-path').style.stroke = 'var(--primary-color)';

            // Clignotants
            document.getElementById('indicator-left').className = event.data.indicatorL ? 'fas fa-arrow-left icon-active-green' : 'fas fa-arrow-left icon-gray';
            document.getElementById('indicator-right').className = event.data.indicatorR ? 'fas fa-arrow-right icon-active-green' : 'fas fa-arrow-right icon-gray';

            // Moteur
            const engineEl = document.getElementById('hud-engine');
            if (event.data.engineHealth < 400) engineEl.className = 'fas fa-wrench icon-active-red';
            else if (event.data.engineHealth < 800) engineEl.className = 'fas fa-wrench icon-active-yellow';
            else engineEl.className = 'fas fa-wrench icon-gray';

            // Essence Bar & Icon
            const fuelIcon = document.getElementById('hud-fuel');
            const fuelBar = document.getElementById('hud-fuel-bar');
            fuelBar.style.width = `${event.data.fuel}%`;
            if (event.data.fuel < 20) {
                fuelIcon.className = 'fas fa-gas-pump icon-active-red';
                fuelBar.style.backgroundColor = 'var(--black-color)';
            } else {
                fuelIcon.className = 'fas fa-gas-pump icon-gray';
                fuelBar.style.backgroundColor = 'var(--hunger-color)';
            }

            // Ceinture
            const seatbeltEl = document.getElementById('hud-seatbelt');
            seatbeltEl.className = event.data.seatbelt ? 'fas fa-user icon-active-green' : 'fas fa-user-slash icon-active-red';

            // Régulateur
            const cruiseEl = document.getElementById('hud-cruise');
            cruiseEl.className = event.data.cruiseControl ? 'fas fa-tachometer-alt icon-active-blue' : 'fas fa-tachometer-alt icon-gray';

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
    document.documentElement.style.setProperty('--primary-color', primary);
    document.documentElement.style.setProperty('--shadow-color', shadow);
    document.documentElement.style.setProperty('--bg-color', bg);

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