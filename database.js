import Database from 'better-sqlite3';

const db = new Database('tickets.db');

// Initialize database
db.exec(`
    CREATE TABLE IF NOT EXISTS tickets (
        channelId TEXT PRIMARY KEY,
        userId TEXT,
        category TEXT,
        status TEXT,
        staffId TEXT,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        lastActivityAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    CREATE TABLE IF NOT EXISTS cooldowns (
        userId TEXT PRIMARY KEY,
        lastTicketAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    CREATE TABLE IF NOT EXISTS blacklist (
        userId TEXT PRIMARY KEY,
        reason TEXT,
        staffId TEXT,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
`);

// Migration for existing databases (adding lastActivityAt if it doesn't exist)
try {
    db.prepare("ALTER TABLE tickets ADD COLUMN lastActivityAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP").run();
} catch (e) {
    // Column likely already exists
}

export const createTicket = (channelId, userId, category) => {
    const stmt = db.prepare("INSERT INTO tickets (channelId, userId, category, status) VALUES (?, ?, ?, ?)");
    return stmt.run(channelId, userId, category, 'open');
};

export const getActiveTicketCount = (userId) => {
    const row = db.prepare("SELECT COUNT(*) as count FROM tickets WHERE userId = ? AND status = 'open'").get(userId);
    return row ? row.count : 0;
};

export const updateTicketStatus = (channelId, status) => {
    return db.prepare("UPDATE tickets SET status = ? WHERE channelId = ?").run(status, channelId);
};

export const updateActivity = (channelId) => {
    return db.prepare("UPDATE tickets SET lastActivityAt = CURRENT_TIMESTAMP WHERE channelId = ?").run(channelId);
};

export const claimTicket = (channelId, staffId) => {
    return db.prepare("UPDATE tickets SET staffId = ? WHERE channelId = ?").run(staffId, channelId);
};

export const getTicket = (channelId) => {
    return db.prepare("SELECT * FROM tickets WHERE channelId = ?").get(channelId);
};

export const setCooldown = (userId) => {
    return db.prepare("INSERT OR REPLACE INTO cooldowns (userId, lastTicketAt) VALUES (?, CURRENT_TIMESTAMP)").run(userId);
};

export const getLastTicketTime = (userId) => {
    const row = db.prepare("SELECT lastTicketAt FROM cooldowns WHERE userId = ?").get(userId);
    return row ? new Date(row.lastTicketAt + 'Z') : null;
};

// Blacklist functions
export const addToBlacklist = (userId, reason, staffId) => {
    return db.prepare("INSERT OR REPLACE INTO blacklist (userId, reason, staffId) VALUES (?, ?, ?)").run(userId, reason, staffId);
};

export const removeFromBlacklist = (userId) => {
    return db.prepare("DELETE FROM blacklist WHERE userId = ?").run(userId);
};

export const isBlacklisted = (userId) => {
    const row = db.prepare("SELECT * FROM blacklist WHERE userId = ?").get(userId);
    return !!row;
};

export const getBlacklistInfo = (userId) => {
    return db.prepare("SELECT * FROM blacklist WHERE userId = ?").get(userId);
};

// Stats functions
export const getStats = () => {
    const total = db.prepare("SELECT COUNT(*) as count FROM tickets").get().count;
    const open = db.prepare("SELECT COUNT(*) as count FROM tickets WHERE status = 'open'").get().count;
    const closed = db.prepare("SELECT COUNT(*) as count FROM tickets WHERE status = 'closed'").get().count;
    return { total, open, closed };
};

export const getInactiveTickets = (hours) => {
    return db.prepare("SELECT * FROM tickets WHERE status = 'open' AND lastActivityAt < datetime('now', '-' || ? || ' hours')").all(hours);
};
