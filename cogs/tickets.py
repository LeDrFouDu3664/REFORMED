import discord
from discord.ext import commands
from discord import app_commands
import config
from utils import db
import datetime

class TicketCreationView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)

        for key, cat in config.TICKET_CATEGORIES.items():
            button = discord.ui.Button(
                label=cat["label"],
                emoji=cat["emoji"],
                style=discord.ButtonStyle.primary,
                custom_id=f"ticket_create:{key}"
            )
            button.callback = self.create_ticket_callback
            self.add_item(button)

    async def create_ticket_callback(self, interaction: discord.Interaction):
        category_key = interaction.data["custom_id"].split(":")[1]
        category_cfg = config.TICKET_CATEGORIES[category_key]

        # Check active ticket limit
        active_count = await db.get_active_ticket_count(interaction.user.id)
        if active_count >= config.TICKET_LIMIT_PER_USER:
            await interaction.response.send_message(
                "Vous avez déjà un ticket ouvert. Veuillez le fermer avant d'en ouvrir un nouveau.",
                ephemeral=True
            )
            return

        # Check cooldown
        last_time = await db.get_last_ticket_time(interaction.user.id)
        if last_time:
            delta = (datetime.datetime.now() - last_time).total_seconds()
            if delta < config.COOLDOWN_SECONDS:
                remaining = int(config.COOLDOWN_SECONDS - delta)
                await interaction.response.send_message(
                    f"Veuillez patienter {remaining} secondes avant de créer un nouveau ticket.",
                    ephemeral=True
                )
                return

        await interaction.response.defer(ephemeral=True)

        guild = interaction.guild
        member = interaction.user

        # Permissions
        overwrites = {
            guild.default_role: discord.PermissionOverwrite(view_channel=False),
            member: discord.PermissionOverwrite(view_channel=True, send_messages=True, read_message_history=True, attach_files=True),
            guild.me: discord.PermissionOverwrite(view_channel=True, send_messages=True, read_message_history=True, manage_channels=True)
        }

        staff_role = guild.get_role(config.STAFF_ROLE_ID)
        if staff_role:
            overwrites[staff_role] = discord.PermissionOverwrite(view_channel=True, send_messages=True, read_message_history=True, attach_files=True)

        # Create channel
        category_id = category_cfg.get("category_id") or config.TICKET_CATEGORY_ID
        category = guild.get_channel(category_id)
        channel_name = f"{category_cfg['name']}-{member.name}"

        channel = await guild.create_text_channel(
            name=channel_name,
            category=category,
            overwrites=overwrites,
            reason=f"Ticket {category_cfg['label']} ouvert par {member.name}"
        )

        # Save to DB
        await db.create_ticket(channel.id, member.id, category_key)
        await db.set_cooldown(member.id)

        # Welcome message
        embed = discord.Embed(
            title=f"Ticket {category_cfg['label']} - OUVERT",
            description=category_cfg['welcome_message'],
            color=category_cfg['color'],
            timestamp=datetime.datetime.now()
        )
        embed.add_field(name="Règles", value="• Un seul ticket à la fois.\n• Soyez respectueux.\n• Soyez patient.", inline=False)
        embed.set_footer(text=f"ID Utilisateur: {member.id}")

        # Later we will add the management view here
        from cogs.tickets import TicketActionView
        view = TicketActionView()

        # Special view for recruitment
        if category_cfg.get("is_recruitment"):
            from cogs.recruitment import RecruitmentActionView
            # We will send the recruitment view as a second message or combine
            # Let's send it in the same message by adding buttons to the view
            recruit_view = RecruitmentActionView()
            for item in recruit_view.children:
                view.add_item(item)

        welcome_msg = await channel.send(content=f"{member.mention} | <@&{config.STAFF_ROLE_ID}>", embed=embed, view=view)
        await welcome_msg.pin()

        await interaction.followup.send(f"Votre ticket a été créé : {channel.mention}", ephemeral=True)

        # Log action
        try:
            from cogs.logs import log_ticket_action
            await log_ticket_action(interaction.client, "Création", interaction.user, channel, f"Catégorie: {category_cfg['label']}")
        except ImportError:
            pass

class TicketActionView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)

    async def check_staff(self, interaction: discord.Interaction):
        staff_role = interaction.guild.get_role(config.STAFF_ROLE_ID)
        admin_role = interaction.guild.get_role(config.ADMIN_ROLE_ID)
        if (staff_role and staff_role in interaction.user.roles) or (admin_role and admin_role in interaction.user.roles) or interaction.user.guild_permissions.administrator:
            return True
        await interaction.response.send_message("Vous n'avez pas la permission d'effectuer cette action.", ephemeral=True)
        return False

    @discord.ui.button(label="Claim", style=discord.ButtonStyle.success, custom_id="ticket_claim", emoji="🙋‍♂️")
    async def claim(self, interaction: discord.Interaction, button: discord.ui.Button):
        if not await self.check_staff(interaction): return

        ticket = await db.get_ticket(interaction.channel_id)
        if not ticket:
            await interaction.response.send_message("Ce salon n'est pas un ticket valide.", ephemeral=True)
            return

        if ticket[4]: # staff_id
            await interaction.response.send_message(f"Ce ticket est déjà pris en charge par <@{ticket[4]}>.", ephemeral=True)
            return

        await db.claim_ticket(interaction.channel_id, interaction.user.id)

        # Update permissions: give specific staff more rights or just acknowledge
        await interaction.channel.set_permissions(interaction.user, view_channel=True, send_messages=True, manage_channels=True)

        embed = discord.Embed(
            description=f"Le ticket a été pris en charge par {interaction.user.mention}.",
            color=discord.Color.green()
        )
        await interaction.response.send_message(embed=embed)

        from cogs.logs import log_ticket_action
        await log_ticket_action(interaction.client, "Prise en charge", interaction.user, interaction.channel)

    @discord.ui.button(label="Ajouter/Retirer", style=discord.ButtonStyle.secondary, custom_id="ticket_add_remove", emoji="👤")
    async def add_remove(self, interaction: discord.Interaction, button: discord.ui.Button):
        if not await self.check_staff(interaction): return

        view = UserSelectionView(interaction.channel)
        await interaction.response.send_message("Sélectionnez un membre à ajouter ou retirer :", view=view, ephemeral=True)

    @discord.ui.button(label="Réouvrir", style=discord.ButtonStyle.primary, custom_id="ticket_reopen", emoji="🔓")
    async def reopen(self, interaction: discord.Interaction, button: discord.ui.Button):
        if not await self.check_staff(interaction): return

        ticket = await db.get_ticket(interaction.channel_id)
        if not ticket or ticket[3] != 'closed':
            await interaction.response.send_message("Ce ticket n'est pas fermé.", ephemeral=True)
            return

        await db.update_ticket_status(interaction.channel_id, 'open')

        # Restore permissions for the user
        user = interaction.guild.get_member(ticket[1])
        if user:
            await interaction.channel.set_permissions(user, view_channel=True, send_messages=True)

        # Move back to active category
        active_cat = interaction.guild.get_channel(config.TICKET_CATEGORY_ID)
        if active_cat:
            await interaction.channel.edit(category=active_cat)

        embed = discord.Embed(
            title="Ticket RÉOUVERT",
            description=f"Le ticket a été réouvert par {interaction.user.mention}.",
            color=discord.Color.blue()
        )
        await interaction.response.send_message(embed=embed)

        from cogs.logs import log_ticket_action
        await log_ticket_action(interaction.client, "Réouverture", interaction.user, interaction.channel)

    @discord.ui.button(label="Fermer", style=discord.ButtonStyle.danger, custom_id="ticket_close", emoji="🔒")
    async def close(self, interaction: discord.Interaction, button: discord.ui.Button):
        if not await self.check_staff(interaction): return
        # Logic for closing will be in Part 7 (using Modal)
        from cogs.tickets import CloseTicketModal
        await interaction.response.send_modal(CloseTicketModal())

class UserSelectionView(discord.ui.View):
    def __init__(self, channel):
        super().__init__(timeout=60)
        self.channel = channel

    @discord.ui.select(cls=discord.ui.UserSelect, placeholder="Choisissez un membre...")
    async def select_user(self, interaction: discord.Interaction, select: discord.ui.UserSelect):
        user = select.values[0]

        # Toggle permission
        current_perms = self.channel.overwrites_for(user)
        if current_perms.view_channel:
            await self.channel.set_permissions(user, overwrite=None)
            action = "retiré du"
        else:
            await self.channel.set_permissions(user, view_channel=True, send_messages=True)
            action = "ajouté au"

        await interaction.response.send_message(f"{user.mention} a été {action} ticket.", ephemeral=True)

        from cogs.logs import log_ticket_action
        await log_ticket_action(interaction.client, "Modif. Membres", interaction.user, self.channel, f"Utilisateur: {user} ({action})")

class CloseTicketModal(discord.ui.Modal, title="Fermeture du ticket"):
    reason = discord.ui.TextInput(
        label="Raison de la fermeture",
        placeholder="Expliquez pourquoi vous fermez ce ticket...",
        required=True,
        min_length=5,
        max_length=500,
        style=discord.TextStyle.paragraph
    )

    async def on_submit(self, interaction: discord.Interaction):
        await interaction.response.defer()

        ticket = await db.get_ticket(interaction.channel_id)
        if not ticket:
            await interaction.followup.send("Ce salon n'est pas un ticket valide.", ephemeral=True)
            return

        # Update status in DB
        await db.update_ticket_status(interaction.channel_id, 'closed')

        # Remove user permissions
        user = interaction.guild.get_member(ticket[1])
        if user:
            await interaction.channel.set_permissions(user, overwrite=None)

        # Move to archive category
        archive_cat = interaction.guild.get_channel(config.ARCHIVE_CATEGORY_ID)
        if archive_cat:
            await interaction.channel.edit(category=archive_cat)

        # Generate transcript
        import chat_exporter
        import io
        transcript = await chat_exporter.export(interaction.channel)
        if transcript:
            transcript_file = discord.File(
                io.BytesIO(transcript.encode()),
                filename=f"transcript-{interaction.channel.name}.html"
            )
        else:
            transcript_file = None

        embed = discord.Embed(
            title="Ticket FERMÉ",
            description=f"Le ticket a été fermé par {interaction.user.mention}.\n\n**Raison :** {self.reason.value}",
            color=discord.Color.red(),
            timestamp=datetime.datetime.now()
        )
        await interaction.channel.send(embed=embed)

        # Log action with transcript
        from cogs.logs import log_ticket_action
        await log_ticket_action(
            interaction.client,
            "Fermeture",
            interaction.user,
            interaction.channel,
            f"Raison: {self.reason.value}",
            file=transcript_file
        )

        await interaction.followup.send("Le ticket a été fermé avec succès.", ephemeral=True)

class Tickets(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.bot.add_view(TicketCreationView())
        self.bot.add_view(TicketActionView())

    @app_commands.command(name="setup_tickets", description="Configure le système de tickets")
    @app_commands.checks.has_permissions(administrator=True)
    async def setup_tickets(self, interaction: discord.Interaction):
        embed = discord.Embed(
            title="Ouverture d'un Ticket",
            description="Veuillez cliquer sur le bouton correspondant à votre demande pour ouvrir un ticket.",
            color=discord.Color.blue()
        )
        await interaction.response.send_message("Système de tickets configuré.", ephemeral=True)
        await interaction.channel.send(embed=embed, view=TicketCreationView())

async def setup(bot):
    await bot.add_cog(Tickets(bot))
