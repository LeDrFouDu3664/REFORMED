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

        // MàJ Textes & Header Info
        document.getElementById('hud-id').innerText = event.data.id;
        document.getElementById('hud-players').innerText = event.data.playerCount;
        document.getElementById('hud-time').innerText = event.data.time;
        document.getElementById('hud-date').innerText = event.data.date.replace(/\//g, '.'); // Format 11.09.2022

        document.getElementById('hud-money').innerText = event.data.money.toLocaleString();
        document.getElementById('hud-bank').innerText = event.data.bank.toLocaleString();
        if(event.data.black > 0) {
            document.querySelector('.black-text').style.display = 'block';
            document.getElementById('hud-black').innerText = event.data.black.toLocaleString();
        } else {
            document.querySelector('.black-text').style.display = 'none';
        }

        // MàJ Cercles Vitaux (Calcul du stroke-dashoffset, dasharray = 100)
        // Les cercles sont dessinés pour faire 100 de circonférence.
        // Mais ils ne font pas un tour complet (style image), on va masquer un quart environ en tournant l'offset,
        // En fait laissons le calcul standard, le SVG les remplit bien.
        document.getElementById('circle-health').style.strokeDashoffset = 100 - event.data.health;
        document.getElementById('circle-armor').style.strokeDashoffset = 100 - event.data.armor;
        document.getElementById('circle-hunger').style.strokeDashoffset = 100 - event.data.hunger;
        document.getElementById('circle-thirst').style.strokeDashoffset = 100 - event.data.thirst;

        // MàJ Micro
        const micIcon = document.getElementById('mic-icon');
        if (event.data.isTalking) {
            micIcon.className = 'fas fa-microphone icon-active-green';
        } else {
            micIcon.className = 'fas fa-microphone-slash';
        }

        // HUD Véhicule
        if (event.data.inVehicle) {
            document.getElementById('hud-vehicle').style.display = 'flex';
            document.getElementById('hud-speed').innerText = event.data.speed;

            // Vitesse (Inner Arc, Dasharray = 290)
            const speedoMax = 250;
            let speedPercent = (event.data.speed / speedoMax) * 100;
            if (speedPercent > 100) speedPercent = 100;
            const speedOffset = 290 - (290 * (speedPercent / 100));
            document.getElementById('speed-path').style.strokeDashoffset = speedOffset;

            // Changer la couleur en fonction de la vitesse (Jaune -> Vert selon l'image)
            if (speedPercent > 80) document.getElementById('speed-path').style.stroke = 'var(--health-color)';
            else document.getElementById('speed-path').style.stroke = 'var(--hunger-color)';

            // RPM (Outer Arc, Dasharray = 350)
            // L'image utilise l'arc extérieur pour un effet de jauge blanche (ou RPM)
            // On va le mapper sur l'RPM du véhicule
            let rpmPercent = event.data.rpm * 100; // RPM est entre 0.0 et 1.0 (ou 0.2 au ralenti)
            if (rpmPercent < 20) rpmPercent = 20; // base idle
            if (rpmPercent > 100) rpmPercent = 100;
            const rpmOffset = 350 - (350 * (rpmPercent / 100));
            document.getElementById('rpm-path').style.strokeDashoffset = rpmOffset;

            // Clignotants (Left Indicator = Headlights in new design)
            document.getElementById('indicator-left').className = event.data.indicatorL ? 'fas fa-lightbulb icon-active-blue' : 'fas fa-lightbulb';

            // Moteur (Moteur de couleur blanche si OK, sinon rouge)
            const engineEl = document.getElementById('hud-engine-bottom');
            if (event.data.engineHealth < 400) engineEl.className = 'fas fa-car-battery icon-active';
            else if (event.data.engineHealth < 800) engineEl.className = 'fas fa-car-battery icon-active';
            else engineEl.className = 'fas fa-car-battery';

            // Essence Icon
            const fuelIcon = document.getElementById('hud-fuel');
            if (event.data.fuel < 20) {
                fuelIcon.className = 'fas fa-gas-pump icon-active';
            } else {
                fuelIcon.className = 'fas fa-gas-pump icon-active-green';
            }

            // Engine Health side icon (Petit voyant gauche du compteur)
            const engineSideEl = document.getElementById('hud-engine');
            if (event.data.engineHealth < 900) engineSideEl.className = 'fas fa-engine-warning icon-active';
            else engineSideEl.className = 'fas fa-engine-warning';

        } else {
            document.getElementById('hud-vehicle').style.display = 'none';
        }

    } else if (event.data.action === 'hideHUD') {
        const widgets = document.querySelectorAll('.hud-widget');
        widgets.forEach(w => w.style.display = 'none');
    } else if (event.data.action === 'toggleDragMode') {
        const widgets = document.querySelectorAll('.hud-widget');
        widgets.forEach(widget => {
            if (event.data.state) {
                widget.classList.add('edit-mode');
            } else {
                widget.classList.remove('edit-mode');
            }
        });

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
    colorShadow.value = 'rgba(0, 0, 0, 0.7)';
    colorBg.value = 'rgba(10, 20, 45, 0.75)';
    applyColors('#ffffff', 'rgba(0, 0, 0, 0.7)', 'rgba(10, 20, 45, 0.75)');
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
    if (handle) {
        handle.addEventListener('mousedown', function(e) {
            isDragging = true;
            currentWidget = widget;
            offsetX = e.clientX - widget.getBoundingClientRect().left;
            offsetY = e.clientY - widget.getBoundingClientRect().top;
        });
    }
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