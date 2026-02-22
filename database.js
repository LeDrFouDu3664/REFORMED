const Database = require('better-sqlite3');
const db = new Database('tickets.db');

// Initialize database
db.exec(`
    CREATE TABLE IF NOT EXISTS tickets (
        channelId TEXT PRIMARY KEY,
        userId TEXT,
        category TEXT,
        status TEXT,
        staffId TEXT,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    CREATE TABLE IF NOT EXISTS cooldowns (
        userId TEXT PRIMARY KEY,
        lastTicketAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
`);

module.exports = {
    createTicket: (channelId, userId, category) => {
        const stmt = db.prepare("INSERT INTO tickets (channelId, userId, category, status) VALUES (?, ?, ?, ?)");
        return stmt.run(channelId, userId, category, 'open');
    },

    getActiveTicketCount: (userId) => {
        const row = db.prepare("SELECT COUNT(*) as count FROM tickets WHERE userId = ? AND status = 'open'").get(userId);
        return row ? row.count : 0;
    },

    updateTicketStatus: (channelId, status) => {
        return db.prepare("UPDATE tickets SET status = ? WHERE channelId = ?").run(status, channelId);
    },

    claimTicket: (channelId, staffId) => {
        return db.prepare("UPDATE tickets SET staffId = ? WHERE channelId = ?").run(staffId, channelId);
    },

    getTicket: (channelId) => {
        return db.prepare("SELECT * FROM tickets WHERE channelId = ?").get(channelId);
    },

    setCooldown: (userId) => {
        return db.prepare("INSERT OR REPLACE INTO cooldowns (userId, lastTicketAt) VALUES (?, CURRENT_TIMESTAMP)").run(userId);
    },

    getLastTicketTime: (userId) => {
        const row = db.prepare("SELECT lastTicketAt FROM cooldowns WHERE userId = ?").get(userId);
        return row ? new Date(row.lastTicketAt + 'Z') : null;
    }
};
