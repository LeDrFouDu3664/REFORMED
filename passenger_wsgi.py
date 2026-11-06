import os
import sys
import traceback

# Configuration Passenger WSGI robuste pour serveurs Web (cPanel, CloudLinux, LiteSpeed, Nginx/Apache Passenger)
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
if CURRENT_DIR not in sys.path:
    sys.path.insert(0, CURRENT_DIR)

# Détection automatique de virtualenv local si présent (ex: virtualenv, venv, env)
for venv_name in ['virtualenv', 'venv', 'env']:
    venv_path = os.path.join(CURRENT_DIR, venv_name)
    if os.path.isdir(venv_path):
        for py_dir in ['lib/python3.12/site-packages', 'lib/python3.11/site-packages', 'lib/python3.10/site-packages', 'lib/site-packages']:
            site_packages = os.path.join(venv_path, py_dir)
            if os.path.isdir(site_packages) and site_packages not in sys.path:
                sys.path.insert(0, site_packages)

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

# Wrapper pour capturer les erreurs de démarrage et afficher un rapport explicite
try:
    from config.wsgi import application as django_app

    def application(environ, start_response):
        return django_app(environ, start_response)

except Exception as e:
    err_trace = traceback.format_exc()
    sys.stderr.write(f"Erreur d'initialisation WSGI : {err_trace}\n")

    def application(environ, start_response):
        status = '500 Internal Server Error'
        headers = [('Content-Type', 'text/html; charset=utf-8')]
        start_response(status, headers)
        html = f"""<!DOCTYPE html>
<html>
<head>
    <title>Erreur de Configuration - Horizon RP</title>
    <style>
        body {{ font-family: monospace; background: #0f172a; color: #f8fafc; padding: 30px; }}
        .box {{ background: #1e293b; border-left: 5px solid #ef4444; padding: 20px; border-radius: 8px; }}
        h1 {{ color: #ef4444; margin-top: 0; }}
        pre {{ background: #0b0f19; padding: 15px; border-radius: 6px; overflow-x: auto; color: #fca5a5; }}
        .tip {{ margin-top: 15px; color: #94a3b8; font-size: 13px; }}
    </style>
</head>
<body>
    <div class="box">
        <h1>Erreur d'initialisation de l'application</h1>
        <p>L'application Python n'a pas pu démarrer sur ce serveur hébergé (cPanel / Passenger).</p>
        <h3>Détails techniques :</h3>
        <pre>{err_trace}</pre>
        <div class="tip">
            <strong>Solutions courantes :</strong><br>
            1. Vérifiez que Django est installé dans l'environnement Python cPanel : <code>pip install -r requirements.txt</code><br>
            2. Vérifiez que la base de données SQLite a les permissions d'écriture : <code>chmod 664 db.sqlite3</code><br>
            3. Vérifiez la version de Python configurée dans votre interface "Setup Python App" sur cPanel (ex: Python 3.10 ou 3.11).
        </div>
    </div>
</body>
</html>"""
        return [html.encode('utf-8')]
