from django.core.management.base import BaseCommand
from accueil.models import ServerRule, Streamer, ShopPackage, VoteSite


class Command(BaseCommand):
    help = "Peuple la base de données avec le contenu initial pour Horizon RP"

    def handle(self, *args, **options):
        # Règles
        rules_data = [
            {
                "number": "01",
                "title": "Respect et comportement",
                "content": "Respectez les autres joueurs et les membres du staff. Les insultes, discriminations, propos haineux et comportements toxiques sont strictement interdits.",
                "order": 1,
            },
            {
                "number": "02",
                "title": "Roleplay & Fair-play",
                "content": "Vous devez respecter le contexte et le réalisme de votre personnage. Le fair-play est obligatoire. Le Power Gaming et le Meta Gaming sont proscrits.",
                "order": 2,
            },
            {
                "number": "03",
                "title": "Triche et exploitation",
                "content": "L'utilisation de logiciels tiers, cheats, duplicateurs de devises ou exploitation de failles de scripts entraîne un bannissement permanent immédiat.",
                "order": 3,
            },
            {
                "number": "04",
                "title": "Staff & Sanctions",
                "content": "Les décisions des modérateurs et administrateurs doivent être respectées. Pour contester, ouvrez un ticket dans la section dédiée sur Discord.",
                "order": 4,
            },
        ]
        for r in rules_data:
            ServerRule.objects.update_or_create(number=r["number"], defaults=r)

        # Streamers
        streamers_data = [
            {
                "name": "HorizonTV",
                "platform": "Twitch",
                "channel_url": "https://twitch.tv",
                "avatar_url": "https://images.unsplash.com/photo-1566492031773-4f4e44671857?q=80&w=200&auto=format&fit=crop",
                "is_live": True,
                "bio": "Patrouilles LSPD et scènes d'enquête en direct tous les soirs !",
                "order": 1,
            },
            {
                "name": "DrFouLive",
                "platform": "Twitch",
                "channel_url": "https://twitch.tv",
                "avatar_url": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop",
                "is_live": False,
                "bio": "Mécanique Benny's et courses poursuites clandestines.",
                "order": 2,
            },
        ]
        for s in streamers_data:
            Streamer.objects.update_or_create(name=s["name"], defaults=s)

        # Packs boutique
        packages_data = [
            {
                "name": "VIP Horizon Bronze",
                "price": 9.99,
                "badge": "Débutant",
                "description": "Idéal pour soutenir le serveur et profiter d'un badge exclusif en jeu.",
                "features": "Rôle Discord VIP Bronze\nAccès prioritaire en file d'attente (Queue priority)\n+1 Slot garage personnel\nBadge exclusif sur le chat en jeu",
                "is_featured": False,
                "order": 1,
            },
            {
                "name": "VIP Horizon Or",
                "price": 24.99,
                "badge": "Populaire",
                "description": "Le pack le plus complet pour les joueurs passionnés de roleplay.",
                "features": "Rôle Discord VIP Gold\nQueue priority maximale\n+3 Slots garage véhicules\nAccès au vestiaire exclusif\nTeinte de plaque personnalisée",
                "is_featured": True,
                "order": 2,
            },
            {
                "name": "Pack Import Véhicule",
                "price": 14.99,
                "badge": "Exclusif",
                "description": "Obtenez un bon d'import pour un véhicule civil personnalisé en concessionnaire.",
                "features": "1x Clé de véhicule importé\nAssurance tous risques offerte le 1er mois\nPersonnalisation custom chez les mécanos",
                "is_featured": False,
                "order": 3,
            },
        ]
        for p in packages_data:
            ShopPackage.objects.update_or_create(name=p["name"], defaults=p)

        # Sites de vote
        votes_data = [
            {
                "name": "Top Serveurs GTA",
                "url": "https://top-serveurs.net",
                "reward_description": "+5,000$ en banque et 1x Coffre Mystère",
                "order": 1,
            },
            {
                "name": "GTA Roleplay List",
                "url": "https://gta-servers.com",
                "reward_description": "+5,000$ sur votre compte courant",
                "order": 2,
            },
        ]
        for v in votes_data:
            VoteSite.objects.update_or_create(name=v["name"], defaults=v)

        self.stdout.write(self.style.SUCCESS("Données Horizon RP initialisées avec succès !"))
