const Config = {
    // 1. EN-TÊTE ET STATUTS (Haut)
    header: {
        title: "MIKE WAZOVSKI",
        titleSize: "28px",
        subtitle: "PAUSE MENU • ROLEPLAY SERVER",
        playersOnline: {
            text: "JOUEURS EN LIGNE:",
            current: 516,
            max: 1024,
            icon: "fa-solid fa-users"
        },
        lastConnection: {
            text: "DERNIÈRE CONNEXION:",
            date: "12.10.2026, 08:21",
            icon: "fa-solid fa-wifi",
            iconColor: "#2ecc71" // Green
        }
    },

    // 2. INFOS DU JOUEUR (Ligne de badges du haut)
    playerInfo: [
        { title: "ACCOUNT ID", value: "318548999", icon: "fa-solid fa-id-card", color: "#ffffff" },
        { title: "MONEY", value: "$ 52 658 666", icon: "fa-solid fa-money-bill", color: "#2ecc71" },
        { title: "BANK", value: "$ 2 875 612", icon: "fa-solid fa-building-columns", color: "#f1c40f" },
        { title: "JOB", value: "LSPD OFFICER", icon: "fa-solid fa-user-shield", color: "#3498db" },
        { title: "PHONE", value: "659 936 955", icon: "fa-solid fa-mobile-screen", color: "#2ecc71" },
        { title: "GANG", value: "THE BALLAS", icon: "fa-solid fa-skull", color: "#e74c3c" },
        { title: "DISCORD", value: "AdeztR", icon: "fa-brands fa-discord", color: "#9b59b6" },
        { title: "TIME", value: "12.10, 10:13", icon: "fa-regular fa-clock", color: "#3498db" },
        { title: "WEATHER", value: "CLOUDS", icon: "fa-solid fa-cloud-sun", color: "#f1c40f" }
    ],

    // 3. ACTIONS RAPIDES & RACCOURCIS (Bande de boutons)
    quickActionsSubtitle: "Boutons configurables pour les futures fonctionnalités",
    quickActions: [
        { text: "DÉCONNEXION", icon: "fa-solid fa-power-off", color: "#e74c3c", isFreeSlot: false }, // Red
        { text: "Règlement", icon: "fa-solid fa-book", color: "#f39c12", isFreeSlot: false }, // Orange
        { text: "Assistance", icon: "fa-solid fa-headset", color: "#9b59b6", isFreeSlot: false }, // Purple
        { text: "Boutique", icon: "fa-solid fa-cart-shopping", color: "#2ecc71", isFreeSlot: false }, // Green
        { text: "Succès / XP", icon: "fa-solid fa-trophy", color: "#f1c40f", isFreeSlot: false }, // Yellow
        { text: "Garage", icon: "fa-solid fa-car", color: "#3498db", isFreeSlot: false }, // Blue
        { text: "Clés / Props", icon: "fa-solid fa-key", color: "#8e44ad", isFreeSlot: false }, // Purple
        { text: "+ Slot Libre", icon: "", color: "transparent", isFreeSlot: true } // Empty slot
    ],

    // 4. BLOCS ET GRANDS MODULES (Bas)
    modules: {
        // Colonne Gauche
        left: [
            {
                title: "WORLD MAP",
                description: "Consulter la carte satellite et les points d'intérêts",
                icon: "fa-solid fa-map-location-dot",
                bgImage: "https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=2074&auto=format&fit=crop", // Placeholder map
                action: "openMap"
            },
            {
                title: "PARAMÈTRES",
                description: "Ajuster l'affichage et vos préférences sonores",
                icon: "fa-solid fa-gear",
                bgImage: "https://images.unsplash.com/photo-1506318137071-a8e063b4bec0?q=80&w=2093&auto=format&fit=crop", // Placeholder space/night
                action: "openSettings"
            }
        ],

        // Colonne Milieu
        middle: {
            title: "COMMUNAUTÉ DISCORD",
            description: "Rejoignez plus de 1 000 joueurs actifs, découvrez les patch notes et échangez avec le staff.",
            badgeText: "+1000 MEMBRES EN LIGNE",
            buttonText: "REJOINDRE LE DISCORD",
            buttonIcon: "fa-solid fa-arrow-up-right-from-square",
            buttonLink: "https://discord.gg/yourlink"
        },

        // Colonne Droite
        right: {
            title: "ANNONCES DU PROJET",
            titleIcon: "fa-solid fa-bullhorn",
            announcements: [
                {
                    date: "12.10.2026",
                    dateColor: "#e74c3c", // Red
                    type: "MISE À JOUR",
                    title: "NOUVEAUX VÉHICULES CONCESSIONNAIRE",
                    text: "Arrivée de la nouvelle concession import au nord de Los Santos avec plus de 15 véhicules inédits."
                },
                {
                    date: "10.10.2026",
                    dateColor: "#3498db", // Blue
                    type: "ÉVÉNEMENT",
                    title: "REFONTE DES SALAIRES & ENTREPRISES",
                    text: "Réajustement économique global appliqué à minuit pour tous les services publics et privés."
                }
            ],
            tickerText: "Bannière Battle Pass retirée avec succès"
        }
    }
};

// Export for Node.js testing, otherwise attach to window
if (typeof module !== 'undefined' && module.exports) {
    module.exports = Config;
} else {
    window.Config = Config;
}
