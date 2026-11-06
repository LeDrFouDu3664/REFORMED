from django.db import models


class ServerRule(models.Model):
    number = models.CharField(max_length=10, verbose_name="Numéro (ex: 01)")
    title = models.CharField(max_length=200, verbose_name="Titre")
    content = models.TextField(verbose_name="Contenu de la règle")
    order = models.PositiveIntegerField(default=0, verbose_name="Ordre d'affichage")
    is_active = models.BooleanField(default=True, verbose_name="Actif")

    class Meta:
        verbose_name = "Règle du serveur"
        verbose_name_plural = "Règles du serveur"
        ordering = ["order", "number"]

    def __str__(self):
        return f"{self.number}. {self.title}"


class Streamer(models.Model):
    name = models.CharField(max_length=100, verbose_name="Pseudo")
    platform = models.CharField(max_length=50, default="Twitch", verbose_name="Plateforme")
    channel_url = models.URLField(verbose_name="Lien de la chaîne")
    avatar_url = models.URLField(blank=True, default="", verbose_name="Image / Avatar URL")
    is_live = models.BooleanField(default=False, verbose_name="En direct")
    bio = models.CharField(max_length=255, blank=True, default="", verbose_name="Courte description")
    order = models.PositiveIntegerField(default=0, verbose_name="Ordre d'affichage")

    class Meta:
        verbose_name = "Streamer"
        verbose_name_plural = "Streamers"
        ordering = ["order", "name"]

    def __str__(self):
        return self.name


class ShopPackage(models.Model):
    name = models.CharField(max_length=150, verbose_name="Nom du pack")
    price = models.DecimalField(max_digits=6, decimal_places=2, verbose_name="Prix (€)")
    description = models.TextField(verbose_name="Description")
    badge = models.CharField(max_length=50, blank=True, default="", verbose_name="Badge (ex: Populaire, VIP)")
    features = models.TextField(help_text="Une fonctionnalité par ligne", blank=True, default="")
    is_featured = models.BooleanField(default=False, verbose_name="Mis en avant")
    order = models.PositiveIntegerField(default=0, verbose_name="Ordre d'affichage")

    class Meta:
        verbose_name = "Article Boutique"
        verbose_name_plural = "Articles Boutique"
        ordering = ["order", "price"]

    def __str__(self):
        return f"{self.name} - {self.price}€"

    def features_list(self):
        return [f.strip() for f in self.features.splitlines() if f.strip()]


class VoteSite(models.Model):
    name = models.CharField(max_length=150, verbose_name="Nom de la plateforme")
    url = models.URLField(verbose_name="Lien de vote")
    reward_description = models.CharField(max_length=255, verbose_name="Description de la récompense")
    order = models.PositiveIntegerField(default=0, verbose_name="Ordre d'affichage")

    class Meta:
        verbose_name = "Site de vote"
        verbose_name_plural = "Sites de vote"
        ordering = ["order", "name"]

    def __str__(self):
        return self.name
