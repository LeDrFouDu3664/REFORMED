window.addEventListener('DOMContentLoaded', () => {
    const app = document.getElementById('app');
    const closeBtn = document.getElementById('close-btn');
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');

    const editModal = document.getElementById('edit-modal');
    const btnSaveZone = document.getElementById('btn-save-zone');
    const btnCancelEdit = document.getElementById('btn-cancel-edit');

    const infectionHud = document.getElementById('infection-hud');
    const hudPercent = document.getElementById('hud-percent');
    const hudBar = document.getElementById('hud-bar');
    const hudStage = document.getElementById('hud-stage');

    let currentZones = [];
    let currentVehicles = [];
    let currentProps = [];
    let isHalloweenActive = false;

    // NUI Message Listener from Client Lua
    window.addEventListener('message', (event) => {
        const data = event.data;

        if (data.type === 'openAdmin') {
            currentZones = data.zones || [];
            currentVehicles = data.vehicles || [];
            currentProps = data.props || [];
            isHalloweenActive = data.globalHalloween || false;

            renderZones();
            renderVehicles();
            renderProps();
            updateHalloweenUI();

            app.classList.remove('hidden');
        } else if (data.type === 'updateInfection') {
            const level = data.level || 0;
            const stage = data.stage || 0;

            if (level > 0) {
                infectionHud.classList.remove('hidden');
                hudPercent.textContent = `${level}%`;
                hudBar.style.width = `${level}%`;

                if (stage === 1) {
                    hudStage.textContent = 'Stade 1 : Contamination débutante';
                    hudStage.style.color = '#ffcc00';
                } else if (stage === 2) {
                    hudStage.textContent = 'Stade 2 : Symptômes sévères';
                    hudStage.style.color = '#ff6600';
                } else if (stage === 3) {
                    hudStage.textContent = 'Stade 3 CRITIQUE';
                    hudStage.style.color = '#ff0000';
                } else {
                    hudStage.textContent = 'Sain';
                    hudStage.style.color = '#28a745';
                }
            } else {
                infectionHud.classList.add('hidden');
            }
        } else if (data.type === 'playSound') {
            playAudio(data.sound, data.volume || 0.4);
        }
    });

    // Close UI Function
    function closeUI() {
        app.classList.add('hidden');
        editModal.classList.add('hidden');
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }

    closeBtn.addEventListener('click', closeUI);

    document.addEventListener('keyup', (e) => {
        if (e.key === 'Escape') {
            if (!editModal.classList.contains('hidden')) {
                editModal.classList.add('hidden');
            } else if (!app.classList.contains('hidden')) {
                closeUI();
            }
        }
    });

    // Tab Navigation
    tabBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const tabId = btn.getAttribute('data-tab');

            tabBtns.forEach(b => b.classList.remove('active'));
            tabContents.forEach(c => c.classList.remove('active'));

            btn.classList.add('active');
            document.getElementById(tabId).classList.add('active');
        });
    });

    // Render Zones List
    function renderZones() {
        const container = document.getElementById('zones-list');
        container.innerHTML = '';

        if (currentZones.length === 0) {
            container.innerHTML = '<p class="text-muted">Aucune zone d\'infection active.</p>';
            return;
        }

        currentZones.forEach(zone => {
            const card = document.createElement('div');
            card.className = 'card';
            card.innerHTML = `
                <div class="card-header">
                    <span>${zone.name || zone.id}</span>
                    <span class="${zone.active ? 'text-success' : 'text-danger'}">${zone.active ? 'ACTIF' : 'INACTIF'}</span>
                </div>
                <div class="card-body">
                    <div>Rayon : <strong>${zone.radius}m</strong></div>
                    <div>Max Zombies : <strong>${zone.zombieMax || 20}</strong></div>
                    <div>Santé : <strong>${zone.zombieHealth || 150} HP</strong></div>
                </div>
                <div class="card-actions">
                    <button class="btn btn-primary" onclick="openEditZone('${zone.id}')"><i class="fa-solid fa-pen"></i> Éditer</button>
                    <button class="btn ${zone.active ? 'btn-warning' : 'btn-success'}" onclick="toggleZone('${zone.id}', ${!zone.active})">
                        ${zone.active ? 'Désactiver' : 'Activer'}
                    </button>
                    <button class="btn btn-danger" onclick="deleteZone('${zone.id}')">Supprimer</button>
                </div>
            `;
            container.appendChild(card);
        });
    }

    // Render Vehicles List
    function renderVehicles() {
        const container = document.getElementById('vehicles-list');
        container.innerHTML = '';

        if (currentVehicles.length === 0) {
            container.innerHTML = '<p class="text-muted">Aucun véhicule abandonné placé.</p>';
            return;
        }

        currentVehicles.forEach(veh => {
            const card = document.createElement('div');
            card.className = 'card';
            card.innerHTML = `
                <div class="card-header">
                    <span>${veh.model.toUpperCase()}</span>
                </div>
                <div class="card-body">
                    <div>ID : <strong>${veh.id}</strong></div>
                </div>
                <div class="card-actions">
                    <button class="btn btn-danger" onclick="deleteVehicle('${veh.id}')">Supprimer</button>
                </div>
            `;
            container.appendChild(card);
        });
    }

    // Render Props List
    function renderProps() {
        const container = document.getElementById('props-list');
        container.innerHTML = '';

        if (currentProps.length === 0) {
            container.innerHTML = '<p class="text-muted">Aucune barricade / prop placé(e).</p>';
            return;
        }

        currentProps.forEach(prop => {
            const card = document.createElement('div');
            card.className = 'card';
            card.innerHTML = `
                <div class="card-header">
                    <span>${prop.model.toUpperCase()}</span>
                </div>
                <div class="card-body">
                    <div>ID : <strong>${prop.id}</strong></div>
                </div>
                <div class="card-actions">
                    <button class="btn btn-danger" onclick="deleteProp('${prop.id}')">Supprimer</button>
                </div>
            `;
            container.appendChild(card);
        });
    }

    // Update Halloween UI Status
    function updateHalloweenUI() {
        const statusLbl = document.getElementById('halloween-status');
        const btnToggle = document.getElementById('btn-toggle-halloween');

        if (isHalloweenActive) {
            statusLbl.textContent = 'ACTIVÉ';
            statusLbl.className = 'text-success';
            btnToggle.textContent = 'Désactiver la Nuit d\'Halloween';
            btnToggle.className = 'btn btn-danger';
        } else {
            statusLbl.textContent = 'DÉSACTIVÉ';
            statusLbl.className = 'text-danger';
            btnToggle.textContent = 'Activer la Nuit d\'Halloween';
            btnToggle.className = 'btn btn-warning';
        }
    }

    // Modal Edit Zone Handlers
    window.openEditZone = function(id) {
        const zone = currentZones.find(z => z.id === id);
        if (!zone) return;

        document.getElementById('edit-zone-id').value = zone.id;
        document.getElementById('edit-zone-name').value = zone.name || zone.id;

        document.getElementById('edit-zone-radius').value = zone.radius || 150;
        document.getElementById('lbl-edit-radius').textContent = zone.radius || 150;

        document.getElementById('edit-zone-max').value = zone.zombieMax || 20;
        document.getElementById('lbl-edit-max').textContent = zone.zombieMax || 20;

        document.getElementById('edit-zone-health').value = zone.zombieHealth || 150;
        document.getElementById('lbl-edit-health').textContent = zone.zombieHealth || 150;

        editModal.classList.remove('hidden');
    };

    btnCancelEdit.addEventListener('click', () => {
        editModal.classList.add('hidden');
    });

    btnSaveZone.addEventListener('click', () => {
        const id = document.getElementById('edit-zone-id').value;
        const zone = currentZones.find(z => z.id === id);
        if (!zone) return;

        const updated = {
            ...zone,
            name: document.getElementById('edit-zone-name').value,
            radius: parseFloat(document.getElementById('edit-zone-radius').value) || 150.0,
            zombieMax: parseInt(document.getElementById('edit-zone-max').value) || 20,
            zombieHealth: parseInt(document.getElementById('edit-zone-health').value) || 150
        };

        fetch(`https://${GetParentResourceName()}/updateZone`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(updated)
        });

        editModal.classList.add('hidden');
    });

    // Zone, Vehicle & Prop Actions
    window.toggleZone = function(id, state) {
        fetch(`https://${GetParentResourceName()}/toggleZone`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id, state })
        });
    };

    window.deleteZone = function(id) {
        fetch(`https://${GetParentResourceName()}/deleteZone`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id })
        });
    };

    window.deleteVehicle = function(id) {
        fetch(`https://${GetParentResourceName()}/deleteVehicle`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id })
        });
    };

    window.deleteProp = function(id) {
        fetch(`https://${GetParentResourceName()}/deleteProp`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id })
        });
    };

    document.getElementById('btn-create-zone-here').addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/createZoneHere`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                radius: 150.0,
                zombieMax: parseInt(document.getElementById('input-zombie-max').value) || 20,
                zombieHealth: parseInt(document.getElementById('input-zombie-health').value) || 150,
                zombieSpeed: parseFloat(document.getElementById('input-zombie-speed').value) || 1.2,
                zombieDamage: parseInt(document.getElementById('input-zombie-damage').value) || 15
            })
        });
    });

    document.getElementById('btn-place-veh-here').addEventListener('click', () => {
        const model = document.getElementById('select-veh-model').value;
        fetch(`https://${GetParentResourceName()}/placeVehicleHere`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ model })
        });
    });

    document.getElementById('btn-place-prop-here').addEventListener('click', () => {
        const model = document.getElementById('select-prop-model').value;
        fetch(`https://${GetParentResourceName()}/placePropHere`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ model })
        });
    });

    document.getElementById('btn-toggle-halloween').addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/toggleHalloween`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ state: !isHalloweenActive })
        });
    });

    // Dynamic Sliders Feedback
    document.getElementById('input-zombie-max').addEventListener('input', (e) => {
        document.getElementById('lbl-max').textContent = e.target.value;
    });
    document.getElementById('input-zombie-health').addEventListener('input', (e) => {
        document.getElementById('lbl-health').textContent = e.target.value;
    });
    document.getElementById('input-zombie-speed').addEventListener('input', (e) => {
        document.getElementById('lbl-speed').textContent = e.target.value;
    });
    document.getElementById('input-zombie-damage').addEventListener('input', (e) => {
        document.getElementById('lbl-damage').textContent = e.target.value;
    });

    document.getElementById('edit-zone-radius').addEventListener('input', (e) => {
        document.getElementById('lbl-edit-radius').textContent = e.target.value;
    });
    document.getElementById('edit-zone-max').addEventListener('input', (e) => {
        document.getElementById('lbl-edit-max').textContent = e.target.value;
    });
    document.getElementById('edit-zone-health').addEventListener('input', (e) => {
        document.getElementById('lbl-edit-health').textContent = e.target.value;
    });

    // Web Audio API Sound Generator Fallback for Ambiance Sounds
    function playAudio(type, volume) {
        try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();

            osc.connect(gain);
            gain.connect(ctx.destination);

            gain.gain.setValueAtTime(volume || 0.3, ctx.currentTime);

            if (type === 'scream') {
                osc.type = 'sawtooth';
                osc.frequency.setValueAtTime(600, ctx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(150, ctx.currentTime + 1.2);
                osc.start();
                osc.stop(ctx.currentTime + 1.2);
            } else if (type === 'groan') {
                osc.type = 'sine';
                osc.frequency.setValueAtTime(120, ctx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(70, ctx.currentTime + 2.0);
                osc.start();
                osc.stop(ctx.currentTime + 2.0);
            } else if (type === 'cough') {
                osc.type = 'square';
                osc.frequency.setValueAtTime(220, ctx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(80, ctx.currentTime + 0.4);
                osc.start();
                osc.stop(ctx.currentTime + 0.4);
            } else if (type === 'explosion') {
                osc.type = 'square';
                osc.frequency.setValueAtTime(100, ctx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(30, ctx.currentTime + 0.8);
                osc.start();
                osc.stop(ctx.currentTime + 0.8);
            } else { // wind / default
                osc.type = 'triangle';
                osc.frequency.setValueAtTime(180, ctx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(110, ctx.currentTime + 2.5);
                osc.start();
                osc.stop(ctx.currentTime + 2.5);
            }
        } catch (e) {
            // Audio context fallback
        }
    }
});
