document.addEventListener('DOMContentLoaded', () => {
    // Make sure Config is loaded
    if (typeof Config === 'undefined') {
        console.error('Config object not found! Make sure config.js is loaded before script.js');
        return;
    }

    initDashboard();
});

function initDashboard() {
    loadHeader();
    loadPlayerInfo();
    loadQuickActions();
    loadModules();
}

// 1. EN-TÊTE ET STATUTS
function loadHeader() {
    const { header } = Config;

    // Titles
    const mainTitle = document.getElementById('main-title');
    mainTitle.textContent = header.title;
    mainTitle.style.fontSize = header.titleSize;

    document.getElementById('sub-title').textContent = header.subtitle;

    // Online Players
    document.getElementById('online-text').textContent = header.playersOnline.text;
    document.getElementById('online-current').textContent = header.playersOnline.current;
    document.getElementById('online-max').textContent = header.playersOnline.max;
    document.getElementById('online-icon').className = header.playersOnline.icon;

    // Last Connection
    document.getElementById('connection-text').textContent = header.lastConnection.text;
    document.getElementById('connection-date').textContent = header.lastConnection.date;
    const connectionIcon = document.getElementById('connection-icon');
    connectionIcon.className = header.lastConnection.icon;
    connectionIcon.style.color = header.lastConnection.iconColor;
}

// 2. INFOS DU JOUEUR
function loadPlayerInfo() {
    const container = document.getElementById('player-info-container');
    container.innerHTML = '';

    Config.playerInfo.forEach(info => {
        const card = document.createElement('div');
        card.className = 'info-card';

        card.innerHTML = `
            <div class="info-icon" style="color: ${info.color}">
                <i class="${info.icon}"></i>
            </div>
            <div class="info-text">
                <span class="info-title">${info.title}</span>
                <span class="info-value" style="color: ${info.color}">${info.value}</span>
            </div>
        `;

        container.appendChild(card);
    });
}

// 3. ACTIONS RAPIDES & RACCOURCIS
function loadQuickActions() {
    document.getElementById('quick-actions-subtitle').textContent = Config.quickActionsSubtitle;

    const container = document.getElementById('quick-actions-container');
    container.innerHTML = '';

    Config.quickActions.forEach((action, index) => {
        const btn = document.createElement('a');
        btn.href = '#';
        btn.className = `action-btn ${action.isFreeSlot ? 'free-slot' : ''}`;

        // Custom id for specific styling/events if needed
        btn.id = `action-btn-${index}`;

        if (action.isFreeSlot) {
            btn.innerHTML = `<span>${action.text}</span>`;
        } else {
            // Apply specific styles for the first button (red/déconnexion usually)
            if (action.color === '#e74c3c' || action.text.toLowerCase().includes('déconnexion')) {
                btn.classList.add('btn-red');
                btn.innerHTML = `
                    <i class="${action.icon}"></i>
                    <span>${action.text}</span>
                `;
            } else {
                // For other buttons, set icon color dynamically
                btn.innerHTML = `
                    <i class="${action.icon}" style="color: ${action.color}"></i>
                    <span>${action.text}</span>
                `;
            }
        }

        // Add click listener (mock action)
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            console.log(`Clicked action: ${action.text}`);
            if(window.invokeNative) {
                // FiveM NUI callback example
                // fetch('https://your_resource_name/actionClicked', { method: 'POST', body: JSON.stringify({ action: action.text }) });
            }
        });

        container.appendChild(btn);
    });
}

// 4. BLOCS ET GRANDS MODULES
function loadModules() {
    const { modules } = Config;

    // Left Column (Image Cards)
    const leftContainer = document.getElementById('module-left-container');
    leftContainer.innerHTML = '';

    modules.left.forEach(module => {
        const card = document.createElement('a');
        card.href = '#';
        card.className = 'image-card';
        card.innerHTML = `
            <div class="card-bg" style="background-image: url('${module.bgImage}')"></div>
            <div class="card-overlay"></div>
            <div class="card-icon">
                <i class="${module.icon}"></i>
            </div>
            <div class="card-content">
                <h3>${module.title}</h3>
                <p>${module.description}</p>
            </div>
        `;

        card.addEventListener('click', (e) => {
            e.preventDefault();
            console.log(`Action triggered: ${module.action}`);
        });

        leftContainer.appendChild(card);
    });

    // Middle Column (Discord)
    document.getElementById('discord-title').textContent = modules.middle.title;
    document.getElementById('discord-desc').textContent = modules.middle.description;
    document.getElementById('discord-badge').textContent = modules.middle.badgeText;

    const discordBtn = document.getElementById('discord-btn');
    document.getElementById('discord-btn-text').textContent = modules.middle.buttonText;
    document.getElementById('discord-btn-icon').className = modules.middle.buttonIcon;
    discordBtn.href = modules.middle.buttonLink;

    // Right Column (Announcements)
    document.getElementById('announcements-title-text').textContent = modules.right.title;
    document.getElementById('announcements-icon').className = modules.right.titleIcon;
    document.getElementById('announcements-ticker').textContent = modules.right.tickerText;

    const announcementsList = document.getElementById('announcements-list');
    announcementsList.innerHTML = '';

    modules.right.announcements.forEach(ann => {
        // Convert hex color to rgba for the background tint (assuming simple hex like #e74c3c)
        // A simple way is to use CSS custom properties or inline rgba if we had a converter.
        // For simplicity, we just apply the hex to text and a transparent version if possible,
        // or just rely on CSS opacity.

        const item = document.createElement('div');
        item.className = 'announcement-item';
        item.innerHTML = `
            <div class="announcement-meta">
                <span class="announcement-date" style="background-color: ${hexToRgba(ann.dateColor, 0.2)}; color: ${ann.dateColor}">${ann.date}</span>
                <span class="announcement-type">${ann.type}</span>
            </div>
            <h4>${ann.title}</h4>
            <p>${ann.text}</p>
        `;

        announcementsList.appendChild(item);
    });
}

// Utility function to add background tint based on hex color
function hexToRgba(hex, alpha) {
    let r = 0, g = 0, b = 0;
    // 3 digits
    if (hex.length == 4) {
      r = "0x" + hex[1] + hex[1];
      g = "0x" + hex[2] + hex[2];
      b = "0x" + hex[3] + hex[3];
    // 6 digits
    } else if (hex.length == 7) {
      r = "0x" + hex[1] + hex[2];
      g = "0x" + hex[3] + hex[4];
      b = "0x" + hex[5] + hex[6];
    }
    return "rgba("+ +r + "," + +g + "," + +b + "," + alpha + ")";
}

// Optional: FiveM Escape key event listener to close NUI
document.addEventListener('keyup', (e) => {
    if (e.key === 'Escape') {
        console.log('Close UI triggered');
        // Fetch to your Lua client callback
        // fetch('https://your_resource_name/closeUI', { method: 'POST', body: JSON.stringify({}) });
    }
});