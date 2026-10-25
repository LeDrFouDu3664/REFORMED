// Game Logic & State
const Game = {
    players: [],
    currentPlayerIndex: 0,
    boardTiles: [],
    boardSize: 40,
    state: 'MENU', // MENU, BOARD, MINIGAME_INTRO, MINIGAME, MINIGAME_RESULTS, END
    colors: ['#ff4757', '#1e90ff', '#2ed573', '#ffa502'],

    init() {
        this.bindEvents();
    },

    bindEvents() {
        document.getElementById('btn-start-game').addEventListener('click', () => this.startGame());
        document.getElementById('btn-roll-dice').addEventListener('click', () => this.rollDice());
        document.getElementById('btn-start-minigame').addEventListener('click', () => this.startMinigame());
        document.getElementById('btn-return-board').addEventListener('click', () => this.returnToBoard());
        document.getElementById('btn-restart').addEventListener('click', () => this.resetGame());
    },

    showScreen(screenId) {
        document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
        document.getElementById(screenId).classList.add('active');
    },

    startGame() {
        this.players = [];
        for(let i=1; i<=4; i++) {
            const type = document.getElementById('type-p' + i).value;
            if(type !== 'none') {
                this.players.push({
                    id: i,
                    name: 'Joueur ' + i,
                    color: this.colors[i-1],
                    isAI: type === 'ai',
                    score: 0,
                    pos: 0
                });
            }
        }

        if(this.players.length === 0) {
            alert('Il faut au moins 1 joueur !');
            return;
        }

        this.generateBoard();
        this.updateHUD();
        this.currentPlayerIndex = 0;

        this.showScreen('board-screen');
        this.startTurn();
    },

    generateBoard() {
        const board = document.getElementById('board');
        board.innerHTML = '';
        this.boardTiles = [];

        // Simple linear board generation snaking around
        for(let i=0; i<this.boardSize; i++) {
            const tile = document.createElement('div');
            tile.className = 'tile';
            tile.innerText = i;

            if(i === 0) tile.classList.add('start');
            if(i === this.boardSize - 1) tile.classList.add('end');
            if(i > 0 && i < this.boardSize -1 && Math.random() < 0.2) tile.classList.add('bad');

            board.appendChild(tile);
            this.boardTiles.push(tile);
        }
        this.drawTokens();
    },

    drawTokens() {
        const layer = document.getElementById('tokens-layer');
        layer.innerHTML = '';

        this.players.forEach((p, index) => {
            if(p.pos >= this.boardSize) p.pos = this.boardSize - 1;

            const tile = this.boardTiles[p.pos];
            const tileRect = tile.getBoundingClientRect();
            const boardRect = document.getElementById('board-container').getBoundingClientRect();

            const token = document.createElement('div');
            token.className = 'token';
            token.style.backgroundColor = p.color;

            // Calculate center of tile relative to tokens-layer
            const x = tileRect.left - boardRect.left + (tileRect.width / 2) + (index * 5 - 10);
            const y = tileRect.top - boardRect.top + (tileRect.height / 2) + (index * 5 - 10);

            token.style.left = x + 'px';
            token.style.top = y + 'px';

            layer.appendChild(token);
        });
    },

    updateHUD() {
        const scoresDiv = document.getElementById('player-scores');
        scoresDiv.innerHTML = '';
        this.players.forEach(p => {
            scoresDiv.innerHTML += `<div class="score-badge" style="color:${p.color}">${p.name} : ${p.score}pts</div>`;
        });
    },

    startTurn() {
        const p = this.players[this.currentPlayerIndex];
        document.getElementById('current-player-name').innerText = p.name;
        document.getElementById('current-player-name').style.color = p.color;
        document.getElementById('dice-result').innerText = '';

        if(p.isAI) {
            document.getElementById('btn-roll-dice').disabled = true;
            setTimeout(() => this.rollDice(), 1000); // AI rolls after 1s
        } else {
            document.getElementById('btn-roll-dice').disabled = false;
        }
    },

    rollDice() {
        document.getElementById('btn-roll-dice').disabled = true;
        const p = this.players[this.currentPlayerIndex];
        const roll = Math.floor(Math.random() * 6) + 1;
        document.getElementById('dice-result').innerText = roll;

        p.pos += roll;

        // Ensure tokens update visually
        setTimeout(() => {
            this.drawTokens();
            setTimeout(() => this.endTurn(), 1000);
        }, 500);
    },

    endTurn() {
        // Check win condition
        const p = this.players[this.currentPlayerIndex];
        if(p.pos >= this.boardSize - 1) {
            this.endGame(p);
            return;
        }

        this.currentPlayerIndex++;
        if(this.currentPlayerIndex >= this.players.length) {
            // End of Round -> Play Minigame
            this.prepareMinigame();
        } else {
            this.startTurn();
        }
    },

    prepareMinigame() {
        const mg = Minigames.list[Math.floor(Math.random() * Minigames.list.length)];
        this.currentMinigame = mg;

        document.getElementById('minigame-title').innerText = mg.name;
        document.getElementById('minigame-desc').innerText = mg.desc;

        this.showScreen('minigame-intro-screen');

        // If all players are AI, auto start
        if(this.players.every(p => p.isAI)) {
            setTimeout(() => this.startMinigame(), 2000);
        }
    },

    startMinigame() {
        this.showScreen('minigame-screen');
        this.currentMinigame.init(this.players, (scores) => this.endMinigame(scores));
    },

    endMinigame(scores) {
        let standingsHTML = '';

        this.players.forEach(p => {
            const pts = scores[p.id] || 0;
            p.score += pts;
            standingsHTML += `<p style="color:${p.color}">${p.name} : +${pts} points</p>`;
        });

        document.getElementById('minigame-standings').innerHTML = standingsHTML;
        this.showScreen('minigame-results-screen');

        if(this.players.every(p => p.isAI)) {
            setTimeout(() => this.returnToBoard(), 3000);
        }
    },

    returnToBoard() {
        this.updateHUD();
        this.currentPlayerIndex = 0;
        this.showScreen('board-screen');
        this.startTurn();
    },

    endGame(winner) {
        document.getElementById('winner-name').innerText = winner.name;
        document.getElementById('winner-name').style.color = winner.color;

        const sorted = [...this.players].sort((a,b) => b.score - a.score);
        let finalHTML = '';
        sorted.forEach((p, i) => {
            finalHTML += `<p style="color:${p.color}">${i+1}. ${p.name} - ${p.score}pts</p>`;
        });
        document.getElementById('final-standings').innerHTML = finalHTML;

        this.showScreen('game-over-screen');
    },

    resetGame() {
        this.showScreen('main-menu');
    }
};

window.onload = () => {
    Game.init();
};