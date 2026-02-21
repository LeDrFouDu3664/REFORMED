import aiosqlite
import datetime

DB_PATH = "tickets.db"

async def init_db():
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("""
            CREATE TABLE IF NOT EXISTS tickets (
                channel_id INTEGER PRIMARY KEY,
                user_id INTEGER,
                category TEXT,
                status TEXT,
                staff_id INTEGER,
                created_at TIMESTAMP
            )
        """)
        await db.execute("""
            CREATE TABLE IF NOT EXISTS cooldowns (
                user_id INTEGER PRIMARY KEY,
                last_ticket_at TIMESTAMP
            )
        """)
        await db.commit()

async def create_ticket(channel_id, user_id, category):
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute(
            "INSERT INTO tickets (channel_id, user_id, category, status, created_at) VALUES (?, ?, ?, ?, ?)",
            (channel_id, user_id, category, 'open', datetime.datetime.now())
        )
        await db.commit()

async def get_active_ticket_count(user_id):
    async with aiosqlite.connect(DB_PATH) as db:
        async with db.execute("SELECT COUNT(*) FROM tickets WHERE user_id = ? AND status = 'open'", (user_id,)) as cursor:
            row = await cursor.fetchone()
            return row[0] if row else 0

async def update_ticket_status(channel_id, status):
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("UPDATE tickets SET status = ? WHERE channel_id = ?", (status, channel_id))
        await db.commit()

async def claim_ticket(channel_id, staff_id):
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("UPDATE tickets SET staff_id = ? WHERE channel_id = ?", (staff_id, channel_id))
        await db.commit()

async def get_ticket(channel_id):
    async with aiosqlite.connect(DB_PATH) as db:
        async with db.execute("SELECT * FROM tickets WHERE channel_id = ?", (channel_id,)) as cursor:
            return await cursor.fetchone()

async def set_cooldown(user_id):
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute(
            "INSERT OR REPLACE INTO cooldowns (user_id, last_ticket_at) VALUES (?, ?)",
            (user_id, datetime.datetime.now())
        )
        await db.commit()

async def get_last_ticket_time(user_id):
    async with aiosqlite.connect(DB_PATH) as db:
        async with db.execute("SELECT last_ticket_at FROM cooldowns WHERE user_id = ?", (user_id,)) as cursor:
            row = await cursor.fetchone()
            if row:
                return datetime.datetime.fromisoformat(row[0]) if isinstance(row[0], str) else row[0]
            return None
