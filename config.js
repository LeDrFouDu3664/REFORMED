import 'dotenv/config';

export default {
    token: process.env.DISCORD_TOKEN,
    guildId: process.env.GUILD_ID,

    // Role IDs
    roles: {
        staff: process.env.STAFF_ROLE_ID,
        admin: process.env.ADMIN_ROLE_ID,
        recruitmentStaff: process.env.RECRUITMENT_ROLE_ID,
        recruit: process.env.RECRUIT_ROLE_ID // Role given on acceptance
    },

    // Channel & Category IDs
    channels: {
        logs: process.env.LOG_CHANNEL_ID,
        ticketCategory: process.env.TICKET_CATEGORY_ID,
        archiveCategory: process.env.ARCHIVE_CATEGORY_ID,
        recruitChannelsCategory: process.env.RECRUIT_CHANNELS_CATEGORY_ID
    },

    // Ticket Categories Configuration
    ticketCategories: {
        commande: {
            name: "commande",
            label: "Commande",
            emoji: "🛒",
            welcomeMessage: "Bienvenue dans votre ticket de commande. Un membre du staff va vous prendre en charge.",
            color: "#3498db"
        },
        direction: {
            name: "direction",
            label: "Direction",
            emoji: "👑",
            welcomeMessage: "Bienvenue dans votre ticket Direction. Ce ticket est réservé aux demandes importantes.",
            color: "#f1c40f"
        },
        partenariat: {
            name: "partenariat",
            label: "Partenariat",
            emoji: "🤝",
            welcomeMessage: "Bienvenue dans votre ticket Partenariat. Veuillez présenter votre projet.",
            color: "#9b59b6"
        },
        recrutement: {
            name: "recrutement",
            label: "Recrutement",
            emoji: "📝",
            welcomeMessage: "Bienvenue dans votre ticket Recrutement. Veuillez poster votre candidature ici.",
            color: "#2ecc71",
            isRecruitment: true
        },
        moderation: {
            name: "moderation",
            label: "Modération / Signalement",
            emoji: "🛡️",
            welcomeMessage: "Bienvenue dans votre ticket Modération. Expliquez-nous le problème avec des preuves si possible.",
            color: "#e74c3c"
        }
    },

    // General Settings
    ticketLimitPerUser: 1,
    cooldownSeconds: 60
};
