import os
from dotenv import load_dotenv

load_dotenv()

# Bot Configuration
TOKEN = os.getenv("DISCORD_TOKEN")
GUILD_ID = int(os.getenv("GUILD_ID", 0))

# Role IDs
STAFF_ROLE_ID = int(os.getenv("STAFF_ROLE_ID", 0))
ADMIN_ROLE_ID = int(os.getenv("ADMIN_ROLE_ID", 0))
RECRUITMENT_ROLE_ID = int(os.getenv("RECRUITMENT_ROLE_ID", 0))

# Channel IDs
LOG_CHANNEL_ID = int(os.getenv("LOG_CHANNEL_ID", 0))
TICKET_CATEGORY_ID = int(os.getenv("TICKET_CATEGORY_ID", 0))
ARCHIVE_CATEGORY_ID = int(os.getenv("ARCHIVE_CATEGORY_ID", 0))

# Recruitment specific
RECRUIT_ROLE_ID = int(os.getenv("RECRUIT_ROLE_ID", 0)) # Role given on acceptance
RECRUIT_CHANNELS_CATEGORY_ID = int(os.getenv("RECRUIT_CHANNELS_CATEGORY_ID", 0))

# Ticket Categories Configuration
TICKET_CATEGORIES = {
    "commande": {
        "name": "commande",
        "label": "Commande",
        "emoji": "🛒",
        "description": "Pour toute demande de commande.",
        "welcome_message": "Bienvenue dans votre ticket de commande. Un membre du staff va vous prendre en charge.",
        "color": 0x3498db, # Blue
        "category_id": int(os.getenv("TICKET_CATEGORY_ID", 0))
    },
    "direction": {
        "name": "direction",
        "label": "Direction",
        "emoji": "👑",
        "description": "Pour contacter la direction.",
        "welcome_message": "Bienvenue dans votre ticket Direction. Ce ticket est réservé aux demandes importantes.",
        "color": 0xf1c40f, # Gold
        "category_id": int(os.getenv("TICKET_CATEGORY_ID", 0))
    },
    "partenariat": {
        "name": "partenariat",
        "label": "Partenariat",
        "emoji": "🤝",
        "description": "Pour toute proposition de partenariat.",
        "welcome_message": "Bienvenue dans votre ticket Partenariat. Veuillez présenter votre projet.",
        "color": 0x9b59b6, # Purple
        "category_id": int(os.getenv("TICKET_CATEGORY_ID", 0))
    },
    "recrutement": {
        "name": "recrutement",
        "label": "Recrutement",
        "emoji": "📝",
        "description": "Pour déposer votre candidature.",
        "welcome_message": "Bienvenue dans votre ticket Recrutement. Veuillez poster votre candidature ici.",
        "color": 0x2ecc71, # Green
        "is_recruitment": True,
        "category_id": int(os.getenv("TICKET_CATEGORY_ID", 0))
    },
    "moderation": {
        "name": "moderation",
        "label": "Modération / Signalement",
        "emoji": "🛡️",
        "description": "Pour signaler un joueur ou un problème.",
        "welcome_message": "Bienvenue dans votre ticket Modération. Expliquez-nous le problème avec des preuves si possible.",
        "color": 0xe74c3c, # Red
        "category_id": int(os.getenv("TICKET_CATEGORY_ID", 0))
    }
}

# General Settings
TICKET_LIMIT_PER_USER = 1
COOLDOWN_SECONDS = 60
