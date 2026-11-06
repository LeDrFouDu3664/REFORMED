from django.contrib import admin
from .models import ServerRule, Streamer, ShopPackage, VoteSite


@admin.register(ServerRule)
class ServerRuleAdmin(admin.ModelAdmin):
    list_display = ('number', 'title', 'order', 'is_active')
    list_filter = ('is_active',)
    search_fields = ('number', 'title', 'content')
    list_editable = ('order', 'is_active')


@admin.register(Streamer)
class StreamerAdmin(admin.ModelAdmin):
    list_display = ('name', 'platform', 'channel_url', 'is_live', 'order')
    list_filter = ('platform', 'is_live')
    search_fields = ('name', 'bio')
    list_editable = ('is_live', 'order')


@admin.register(ShopPackage)
class ShopPackageAdmin(admin.ModelAdmin):
    list_display = ('name', 'price', 'badge', 'is_featured', 'order')
    list_filter = ('is_featured',)
    search_fields = ('name', 'description')
    list_editable = ('price', 'badge', 'is_featured', 'order')


@admin.register(VoteSite)
class VoteSiteAdmin(admin.ModelAdmin):
    list_display = ('name', 'url', 'reward_description', 'order')
    search_fields = ('name', 'reward_description')
    list_editable = ('order',)
