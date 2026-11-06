/* ========================================
   HORIZON RP - JAVASCRIPT PRINCIPAL
======================================== */

document.addEventListener("DOMContentLoaded", function () {

    // MENU MOBILE
    const menuToggle = document.getElementById("menuToggle");
    const navLinks = document.getElementById("navLinks");

    if (menuToggle && navLinks) {
        menuToggle.addEventListener("click", function () {
            navLinks.classList.toggle("open");
        });
    }

    // FERMETURE DES MENUS APRÈS CLIC
    document.querySelectorAll(".nav-link").forEach(link => {
        link.addEventListener("click", function () {
            if (navLinks) {
                navLinks.classList.remove("open");
            }
        });
    });

    // LIENS DISCORD
    const discordUrl = ""; // Nous ajouterons le vrai lien Discord.

    const discordButtons = [
        document.getElementById("discordButton"),
        document.getElementById("discordHero")
    ];

    discordButtons.forEach(button => {
        if (button) {
            button.addEventListener("click", function (event) {
                event.preventDefault();

                if (discordUrl) {
                    window.open(discordUrl, "_blank");
                } else {
                    showNotification("Le Discord sera bientôt configuré.");
                }
            });
        }
    });

    // CONNEXION AU SERVEUR
    const joinServer = document.getElementById("joinServer");

    if (joinServer) {
        joinServer.addEventListener("click", function (event) {
            event.preventDefault();
            showNotification("La connexion au serveur sera bientôt disponible.");
        });
    }

    // FERMETURE DES MODALES
    document.querySelectorAll("[data-close-modal]").forEach(button => {
        button.addEventListener("click", function () {
            const modal = button.closest(".modal");

            if (modal) {
                modal.classList.remove("active");
                modal.setAttribute("aria-hidden", "true");
            }
        });
    });

    // FERMETURE EN CLIQUANT À L'EXTÉRIEUR
    document.querySelectorAll(".modal").forEach(modal => {
        modal.addEventListener("click", function (event) {
            if (event.target === modal) {
                modal.classList.remove("active");
                modal.setAttribute("aria-hidden", "true");
            }
        });
    });

    // LIEN ACTIF DANS LA NAVIGATION
    const currentPath = window.location.pathname.replace(/\/$/, "") || "/";

    document.querySelectorAll(".nav-link").forEach(link => {
        const linkPath = new URL(link.href).pathname.replace(/\/$/, "") || "/";

        if (currentPath === linkPath) {
            link.classList.add("active");
        }
    });

});

// AFFICHAGE DES NOTIFICATIONS
function showNotification(message) {
    const notification = document.getElementById("notification");

    if (!notification) return;

    notification.textContent = message;
    notification.classList.add("show");

    clearTimeout(window.horizonNotificationTimer);

    window.horizonNotificationTimer = setTimeout(function () {
        notification.classList.remove("show");
    }, 3500);
}