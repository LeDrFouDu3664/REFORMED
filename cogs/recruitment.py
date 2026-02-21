import discord
from discord.ext import commands
import config
from utils import db
import datetime

class RecruitmentActionView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)

    async def check_recruitment_staff(self, interaction: discord.Interaction):
        staff_role = interaction.guild.get_role(config.RECRUITMENT_ROLE_ID)
        admin_role = interaction.guild.get_role(config.ADMIN_ROLE_ID)
        if (staff_role and staff_role in interaction.user.roles) or (admin_role and admin_role in interaction.user.roles) or interaction.user.guild_permissions.administrator:
            return True
        await interaction.response.send_message("Vous n'avez pas la permission d'effectuer cette action de recrutement.", ephemeral=True)
        return False

    @discord.ui.button(label="Accepter", style=discord.ButtonStyle.success, custom_id="recruit_accept", emoji="✅")
    async def accept(self, interaction: discord.Interaction, button: discord.ui.Button):
        if not await self.check_recruitment_staff(interaction): return

        ticket = await db.get_ticket(interaction.channel_id)
        if not ticket: return

        member = interaction.guild.get_member(ticket[1])
        if not member:
            await interaction.response.send_message("Le membre n'est plus sur le serveur.", ephemeral=True)
            return

        # Give role
        recruit_role = interaction.guild.get_role(config.RECRUIT_ROLE_ID)
        if recruit_role:
            await member.add_roles(recruit_role)

        # Create recruit channels if needed
        recruit_cat = interaction.guild.get_channel(config.RECRUIT_CHANNELS_CATEGORY_ID)
        if recruit_cat:
            await interaction.guild.create_text_channel(
                name=f"bienvenue-{member.name}",
                category=recruit_cat,
                overwrites={
                    interaction.guild.default_role: discord.PermissionOverwrite(view_channel=False),
                    member: discord.PermissionOverwrite(view_channel=True, send_messages=True)
                }
            )

        embed = discord.Embed(
            title="Candidature ACCEPTÉE",
            description=f"Félicitations {member.mention}, votre candidature a été acceptée par {interaction.user.mention} !",
            color=discord.Color.green()
        )
        await interaction.response.send_message(embed=embed)

        # Log
        from cogs.logs import log_ticket_action
        await log_ticket_action(interaction.client, "Recrutement - Accepté", interaction.user, interaction.channel, f"Candidat: {member}")

    @discord.ui.button(label="Refuser", style=discord.ButtonStyle.danger, custom_id="recruit_reject", emoji="❌")
    async def reject(self, interaction: discord.Interaction, button: discord.ui.Button):
        if not await self.check_recruitment_staff(interaction): return

        ticket = await db.get_ticket(interaction.channel_id)
        if not ticket: return

        member = interaction.guild.get_member(ticket[1])

        # We can ask for a reason via Modal if we want, but let's keep it simple or use a Modal
        await interaction.response.send_modal(RejectRecruitModal(member))

class RejectRecruitModal(discord.ui.Modal, title="Refus de candidature"):
    reason = discord.ui.TextInput(
        label="Raison du refus",
        placeholder="Expliquez pourquoi la candidature est refusée...",
        required=True,
        style=discord.TextStyle.paragraph
    )

    def __init__(self, member):
        super().__init__()
        self.member = member

    async def on_submit(self, interaction: discord.Interaction):
        # Send DM to member
        if self.member:
            try:
                await self.member.send(f"Bonjour, votre candidature sur **{interaction.guild.name}** a été refusée.\n**Raison :** {self.reason.value}")
            except:
                pass

        embed = discord.Embed(
            title="Candidature REFUSÉE",
            description=f"La candidature de {self.member.mention if self.member else 'L\'utilisateur'} a été refusée par {interaction.user.mention}.\n**Raison :** {self.reason.value}",
            color=discord.Color.red()
        )
        await interaction.response.send_message(embed=embed)

        # Log
        from cogs.logs import log_ticket_action
        await log_ticket_action(interaction.client, "Recrutement - Refusé", interaction.user, interaction.channel, f"Candidat: {self.member}, Raison: {self.reason.value}")

        # Optionally close the ticket
        from cogs.tickets import CloseTicketModal
        # We can't easily trigger another modal from here, so we just suggest closing or do it automatically
        await interaction.followup.send("Vous pouvez maintenant fermer le ticket en utilisant le bouton 'Fermer'.", ephemeral=True)

class Recruitment(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.bot.add_view(RecruitmentActionView())

async def setup(bot):
    await bot.add_cog(Recruitment(bot))
