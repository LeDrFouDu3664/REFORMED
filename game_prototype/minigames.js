// Minigame Engine & Definitions
const Minigames = {
    list: [
        {
            id: 'reflex_clicker',
            name: 'Réflexe Rapide',
            desc: 'Le premier à cliquer sur la cible rouge gagne !',
            init: function(players, onComplete) {
                const area = document.createElement('div');
                area.className = 'minigame-area';

                const target = document.createElement('div');
                target.id = 'reflex-target';

                const instruction = document.createElement('h2');
                instruction.innerText = 'Préparez-vous...';
                instruction.style.position = 'absolute';
                instruction.style.top = '50%';
                instruction.style.left = '50%';
                instruction.style.transform = 'translate(-50%, -50%)';

                area.appendChild(instruction);
                area.appendChild(target);

                document.getElementById('minigame-screen').innerHTML = '';
                document.getElementById('minigame-screen').appendChild(area);

                let scores = {};
                players.forEach(p => scores[p.id] = 0);

                let timeout;
                let active = false;

                const startRound = () => {
                    instruction.innerText = '';
                    target.style.display = 'block';
                    target.style.left = Math.random() * 80 + 10 + '%';
                    target.style.top = Math.random() * 80 + 10 + '%';
                    active = true;

                    // Trigger AI reactions
                    players.forEach(p => {
                        if(p.isAI) {
                            // AI reaction time between 0.5s and 1.5s
                            setTimeout(() => {
                                if(active) registerClick(p.id);
                            }, 500 + Math.random() * 1000);
                        }
                    });
                };

                const registerClick = (playerId) => {
                    if(!active) return;
                    active = false;
                    target.style.display = 'none';
                    scores[playerId] = 10; // Winner gets 10 points
                    instruction.innerText = players.find(p=>p.id===playerId).name + ' gagne !';

                    setTimeout(() => {
                        // End game after someone wins
                        onComplete(scores);
                    }, 2000);
                };

                // Allow human click
                target.addEventListener('click', () => {
                    // Only allow P1 or P2 human clicks for simplicity in prototype
                    // Ideally you'd map keyboard keys to different human players
                    const human = players.find(p => !p.isAI);
                    if(human) registerClick(human.id);
                });

                // Start after random delay
                setTimeout(startRound, 1000 + Math.random() * 2000);
            }
        }
    ]
};
