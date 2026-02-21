import discord
from discord.ext import commands
import config
import datetime

async def log_ticket_action(bot, action, staff, channel, reason=None, file=None):
    log_channel = bot.get_channel(config.LOG_CHANNEL_ID)
    if not log_channel:
        try:
            log_channel = await bot.fetch_channel(config.LOG_CHANNEL_ID)
        except:
            return

    embed = discord.Embed(
        title=f"Log Ticket - {action}",
        color=discord.Color.blue() if action == "Création" else discord.Color.orange(),
        timestamp=datetime.datetime.now()
    )

    embed.add_field(name="Salon", value=f"{channel.mention} (`{channel.name}`)", inline=True)
    embed.add_field(name="Responsable", value=f"{staff.mention} (`{staff.id}`)", inline=True)

    if reason:
        embed.add_field(name="Détails/Raison", value=reason, inline=False)

    embed.set_footer(text=f"Action: {action}")

    if file:
        await log_channel.send(embed=embed, file=file)
    else:
        await log_channel.send(embed=embed)

class Logs(commands.Cog):
    def __init__(self, bot):
        self.bot = bot

async def setup(bot):
    await bot.add_cog(Logs(bot))
