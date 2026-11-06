from django.shortcuts import render
from django.db import DatabaseError
from .models import ServerRule, Streamer, ShopPackage, VoteSite


def get_safe_queryset(fetch_func):
    """Exécute une requête ORM en toute sécurité sans lever d'erreur 500 si la base n'est pas migrée."""
    try:
        return list(fetch_func())
    except (DatabaseError, Exception):
        return []


def accueil(request):
    """Page d'accueil principale."""
    rules = get_safe_queryset(lambda: ServerRule.objects.filter(is_active=True)[:4])
    packages = get_safe_queryset(lambda: ShopPackage.objects.all()[:3])
    streamers = get_safe_queryset(lambda: Streamer.objects.all()[:3])
    return render(request, 'accueil/pages/home.html', {
        'rules': rules,
        'packages': packages,
        'streamers': streamers,
    })


def reglement(request):
    """Page complète du règlement."""
    rules = get_safe_queryset(lambda: ServerRule.objects.filter(is_active=True))
    return render(request, 'accueil/pages/reglement.html', {
        'rules': rules,
    })


def boutique(request):
    """Page de la boutique."""
    packages = get_safe_queryset(lambda: ShopPackage.objects.all())
    return render(request, 'accueil/pages/boutique.html', {
        'packages': packages,
    })


def streamers(request):
    """Page de la liste des créateurs de contenu."""
    streamers_list = get_safe_queryset(lambda: Streamer.objects.all())
    return render(request, 'accueil/pages/streamers.html', {
        'streamers': streamers_list,
    })


def vote(request):
    """Page des votes et récompenses."""
    sites = get_safe_queryset(lambda: VoteSite.objects.all())
    return render(request, 'accueil/pages/vote.html', {
        'sites': sites,
    })


def dashboard(request):
    """Interface interactive tout-en-un moderne (Dark / Red Gaming)."""
    rules = get_safe_queryset(lambda: ServerRule.objects.filter(is_active=True))
    streamers_list = get_safe_queryset(lambda: Streamer.objects.all())
    packages = get_safe_queryset(lambda: ShopPackage.objects.all())
    vote_sites = get_safe_queryset(lambda: VoteSite.objects.all())
    return render(request, 'accueil/index.html', {
        'rules': rules,
        'streamers': streamers_list,
        'packages': packages,
        'vote_sites': vote_sites,
    })
