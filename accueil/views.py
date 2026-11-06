from django.shortcuts import render
from .models import ServerRule, Streamer, ShopPackage, VoteSite


def accueil(request):
    """Page d'accueil principale."""
    rules = ServerRule.objects.filter(is_active=True)[:4]
    packages = ShopPackage.objects.all()[:3]
    streamers = Streamer.objects.all()[:3]
    return render(request, 'accueil/pages/home.html', {
        'rules': rules,
        'packages': packages,
        'streamers': streamers,
    })


def reglement(request):
    """Page complète du règlement."""
    rules = ServerRule.objects.filter(is_active=True)
    return render(request, 'accueil/pages/reglement.html', {
        'rules': rules,
    })


def boutique(request):
    """Page de la boutique."""
    packages = ShopPackage.objects.all()
    return render(request, 'accueil/pages/boutique.html', {
        'packages': packages,
    })


def streamers(request):
    """Page de la liste des créateurs de contenu."""
    streamers_list = Streamer.objects.all()
    return render(request, 'accueil/pages/streamers.html', {
        'streamers': streamers_list,
    })


def vote(request):
    """Page des votes et récompenses."""
    sites = VoteSite.objects.all()
    return render(request, 'accueil/pages/vote.html', {
        'sites': sites,
    })


def dashboard(request):
    """Interface interactive tout-en-un moderne (Dark / Red Gaming)."""
    rules = ServerRule.objects.filter(is_active=True)
    streamers_list = Streamer.objects.all()
    packages = ShopPackage.objects.all()
    vote_sites = VoteSite.objects.all()
    return render(request, 'accueil/index.html', {
        'rules': rules,
        'streamers': streamers_list,
        'packages': packages,
        'vote_sites': vote_sites,
    })
