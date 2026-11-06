#!/usr/bin/env python3
"""
Lanceur universel tout-en-un pour le site Horizon RP.
Permet d'exécuter l'application immédiatement avec:
    python app.py
ou
    python app.py 8080
"""
import os
import sys

def main():
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

    try:
        import django
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Django n'a pas pu être importé. Assurez-vous qu'il est installé via:\n"
            "pip install -r requirements.txt"
        ) from exc

    django.setup()

    # Exécuter les migrations si la base n'est pas encore initialisée
    try:
        from django.core.management import call_command
        print("[*] Application des migrations de la base de données...")
        call_command('migrate', interactive=False)
    except Exception as e:
        print(f"[!] Note: Erreur lors de l'application automatique des migrations: {e}")

    # Récupérer l'adresse et le port si passés en argument
    port = "8000"
    host = "127.0.0.1"

    if len(sys.argv) > 1:
        arg = sys.argv[1]
        if ":" in arg:
            host, port = arg.split(":")
        else:
            port = arg

    addrport = f"{host}:{port}"
    print(f"[*] Démarrage du serveur Horizon RP sur http://{addrport}/")
    print("[*] Pour vous connecter à l'administration: http://127.0.0.1:8000/admin/")
    print("[*] Appuyez sur Ctrl+C pour arrêter le serveur.")

    execute_from_command_line(['manage.py', 'runserver', addrport])

if __name__ == '__main__':
    main()
