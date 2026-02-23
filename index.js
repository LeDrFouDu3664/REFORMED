import {
    Client,
    GatewayIntentBits,
    Partials,
    ActionRowBuilder,
    ButtonBuilder,
    ButtonStyle,
    EmbedBuilder,
    ChannelType,
    PermissionFlagsBits,
    ModalBuilder,
    TextInputBuilder,
    TextInputStyle,
    UserSelectMenuBuilder
} from 'discord.js';
import config from './config.js';
import * as db from './database.js';
import { logTicketAction, logModeration } from './logger.js';
import transcript from 'discord-html-transcripts';

// IMPORTANT: Vous DEVEZ activer "Server Members Intent" et "Message Content Intent"
// dans le Discord Developer Portal -> Votre Application -> Bot.
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent, // Requis pour l'activité des tickets
        GatewayIntentBits.GuildMembers,   // Requis pour le recrutement et modération
    ],
    partials: [Partials.Channel, Partials.Message, Partials.User],
});

client.once('ready', () => {
    console.log(`Logged in as ${client.user.tag}!`);

    // Auto-close inactive tickets every hour
    setInterval(async () => {
        const inactives = db.getInactiveTickets(48); // 48 hours
        for (const t of inactives) {
            const guild = client.guilds.cache.get(config.guildId);
            if (!guild) continue;
            const channel = await guild.channels.fetch(t.channelId).catch(() => null);
            if (channel) {
                const reason = "Fermeture automatique pour inactivité (48h).";
                db.updateTicketStatus(t.channelId, 'closed');

                if (config.channels.archiveCategory) {
                    await channel.setParent(config.channels.archiveCategory).catch(() => null);
                }

                const user = await guild.members.fetch(t.userId).catch(() => null);
                if (user) {
                    await channel.permissionOverwrites.delete(user.id).catch(() => null);
                    const attachment = await transcript.createTranscript(channel).catch(() => null);
                    const dmEmbed = new EmbedBuilder()
                        .setTitle(`Votre ticket sur ${guild.name} est fermé`)
                        .setDescription(`**Raison :** ${reason}`)
                        .setColor('#e74c3c')
                        .setTimestamp();
                    if (attachment) await user.send({ embeds: [dmEmbed], files: [attachment] }).catch(() => null);
                    else await user.send({ embeds: [dmEmbed] }).catch(() => null);
                }

                const embed = new EmbedBuilder()
                    .setTitle("Ticket FERMÉ (Auto)")
                    .setDescription(reason)
                    .setColor('#e74c3c')
                    .setTimestamp();
                await channel.send({ embeds: [embed] });
                await logTicketAction(client, 'Fermeture Auto', client.user, channel, reason);
            }
        }
    }, 3600000);

    const guild = client.guilds.cache.get(config.guildId);
    if (guild) {
        guild.commands.set([
            {
                name: 'setup_tickets',
                description: 'Configure le système de tickets',
                defaultMemberPermissions: PermissionFlagsBits.Administrator,
            },
            {
                name: 'warn',
                description: 'Avertit un utilisateur',
                defaultMemberPermissions: PermissionFlagsBits.ModerateMembers,
                options: [
                    { name: 'utilisateur', type: 6, description: 'L\'utilisateur à avertir', required: true },
                    { name: 'raison', type: 3, description: 'La raison de l\'avertissement', required: false }
                ]
            },
            {
                name: 'warnings',
                description: 'Affiche les avertissements d\'un utilisateur',
                defaultMemberPermissions: PermissionFlagsBits.ModerateMembers,
                options: [
                    { name: 'utilisateur', type: 6, description: 'L\'utilisateur', required: true }
                ]
            },
            {
                name: 'kick',
                description: 'Expulse un utilisateur',
                defaultMemberPermissions: PermissionFlagsBits.KickMembers,
                options: [
                    { name: 'utilisateur', type: 6, description: 'L\'utilisateur à expulser', required: true },
                    { name: 'raison', type: 3, description: 'La raison de l\'expulsion', required: false }
                ]
            },
            {
                name: 'ban',
                description: 'Bannit un utilisateur',
                defaultMemberPermissions: PermissionFlagsBits.BanMembers,
                options: [
                    { name: 'utilisateur', type: 6, description: 'L\'utilisateur à bannir', required: true },
                    { name: 'raison', type: 3, description: 'La raison du bannissement', required: false }
                ]
            },
            {
                name: 'timeout',
                description: 'Met un utilisateur en sourdine (mute)',
                defaultMemberPermissions: PermissionFlagsBits.ModerateMembers,
                options: [
                    { name: 'utilisateur', type: 6, description: 'L\'utilisateur', required: true },
                    { name: 'duree', type: 4, description: 'Durée en minutes', required: true },
                    { name: 'raison', type: 3, description: 'La raison', required: false }
                ]
            },
            {
                name: 'clear',
                description: 'Supprime un nombre de messages',
                defaultMemberPermissions: PermissionFlagsBits.ManageMessages,
                options: [
                    { name: 'nombre', type: 4, description: 'Nombre de messages (1-100)', required: true }
                ]
            },
            {
                name: 'mod_history',
                description: 'Affiche l\'historique de modération d\'un utilisateur',
                defaultMemberPermissions: PermissionFlagsBits.ModerateMembers,
                options: [
                    { name: 'utilisateur', type: 6, description: 'L\'utilisateur', required: true }
                ]
            },
            {
                name: 'stats_tickets',
                description: 'Affiche les statistiques des tickets',
                defaultMemberPermissions: PermissionFlagsBits.ManageMessages,
            },
            {
                name: 'staff_stats',
                description: 'Affiche les statistiques d\'un membre du staff',
                defaultMemberPermissions: PermissionFlagsBits.ManageMessages,
                options: [
                    {
                        name: 'staff',
                        type: 6, // USER
                        description: 'Le membre du staff',
                        required: false
                    }
                ]
            },
            {
                name: 'priority',
                description: 'Change la priorité du ticket',
                defaultMemberPermissions: PermissionFlagsBits.ManageMessages,
                options: [
                    {
                        name: 'niveau',
                        type: 3, // STRING
                        description: 'Le niveau de priorité',
                        required: true,
                        choices: [
                            { name: 'Basse', value: 'Basse' },
                            { name: 'Normale', value: 'Normale' },
                            { name: 'Haute', value: 'Haute' },
                            { name: 'Urgente', value: 'Urgente' }
                        ]
                    }
                ]
            },
            {
                name: 'check_inactifs',
                description: 'Liste les tickets inactifs',
                defaultMemberPermissions: PermissionFlagsBits.ManageMessages,
                options: [
                    {
                        name: 'heures',
                        type: 4, // INTEGER
                        description: 'Nombre d\'heures d\'inactivité (défaut 24)',
                        required: false
                    }
                ]
            },
            {
                name: 'rename',
                description: 'Renomme le ticket actuel',
                defaultMemberPermissions: PermissionFlagsBits.ManageMessages,
                options: [
                    { name: 'nom', type: 3, description: 'Le nouveau nom', required: true }
                ]
            },
            {
                name: 'transcript',
                description: 'Génère une transcription HTML du ticket actuel',
                defaultMemberPermissions: PermissionFlagsBits.ManageMessages,
            },
            {
                name: 'blacklist',
                description: 'Gère la liste noire des tickets',
                defaultMemberPermissions: PermissionFlagsBits.ManageMessages,
                options: [
                    {
                        name: 'action',
                        type: 3, // STRING
                        description: 'Ajouter ou retirer',
                        required: true,
                        choices: [
                            { name: 'Ajouter', value: 'add' },
                            { name: 'Retirer', value: 'remove' }
                        ]
                    },
                    {
                        name: 'utilisateur',
                        type: 6, // USER
                        description: 'L\'utilisateur à cibler',
                        required: true
                    },
                    {
                        name: 'raison',
                        type: 3, // STRING
                        description: 'La raison du blacklist (optionnel)',
                        required: false
                    }
                ]
            }
        ]);
    }
});

client.on('messageCreate', async message => {
    if (message.author.bot) return;
    const ticket = db.getTicket(message.channel.id);
    if (ticket && ticket.status === 'open') {
        db.updateActivity(message.channel.id);
    }
});

client.on('interactionCreate', async interaction => {
    if (interaction.isChatInputCommand()) {
        const { commandName } = interaction;

        if (commandName === 'setup_tickets') {
            const embed = new EmbedBuilder()
                .setTitle("Ouverture d'un Ticket")
                .setDescription("Veuillez cliquer sur le bouton correspondant à votre demande pour ouvrir un ticket.")
                .setColor('#3498db');

            const row = new ActionRowBuilder();
            Object.entries(config.ticketCategories).forEach(([key, cat]) => {
                row.addComponents(
                    new ButtonBuilder()
                        .setCustomId(`ticket_create:${key}`)
                        .setLabel(cat.label)
                        .setEmoji(cat.emoji)
                        .setStyle(ButtonStyle.Primary)
                );
            });

            await interaction.reply({ content: "Système de tickets configuré.", ephemeral: true });
            await interaction.channel.send({ embeds: [embed], components: [row] });
        }

        else if (commandName === 'warn') {
            const target = interaction.options.getUser('utilisateur');
            const reason = interaction.options.getString('raison') || 'Aucune raison fournie';
            db.addWarning(target.id);
            db.addModerationAction('WARN', target.id, interaction.user.id, reason);
            const count = db.getWarningCount(target.id);
            await interaction.reply({ content: `⚠️ ${target} a été averti. (Total: ${count})\nRaison: ${reason}` });
            await logModeration(client, target, 'Avertissement', reason, interaction.user);
        }

        else if (commandName === 'warnings') {
            const target = interaction.options.getUser('utilisateur');
            const count = db.getWarningCount(target.id);
            const history = db.getModerationHistory(target.id).filter(a => a.type === 'WARN');
            const embed = new EmbedBuilder()
                .setTitle(`Avertissements - ${target.tag}`)
                .setDescription(`Total: **${count}** avertissement(s)`)
                .setColor('#f1c40f');
            if (history.length > 0) {
                embed.addFields({ name: 'Derniers avertissements', value: history.slice(0, 5).map(a => `- ${a.reason} (par <@${a.staffId}>)`).join('\n') });
            }
            await interaction.reply({ embeds: [embed], ephemeral: true });
        }

        else if (commandName === 'kick') {
            const target = interaction.options.getMember('utilisateur');
            const reason = interaction.options.getString('raison') || 'Aucune raison fournie';
            if (!target || !target.kickable) return interaction.reply({ content: "Je ne peux pas expulser cet utilisateur.", ephemeral: true });
            await target.kick(reason);
            db.addModerationAction('KICK', target.id, interaction.user.id, reason);
            await interaction.reply({ content: `👢 ${target.user.tag} a été expulsé.\nRaison: ${reason}` });
            await logModeration(client, target.user, 'Expulsion', reason, interaction.user);
        }

        else if (commandName === 'ban') {
            const target = interaction.options.getMember('utilisateur');
            const reason = interaction.options.getString('raison') || 'Aucune raison fournie';
            if (!target || !target.bannable) return interaction.reply({ content: "Je ne peux pas bannir cet utilisateur.", ephemeral: true });
            await target.ban({ reason });
            db.addModerationAction('BAN', target.id, interaction.user.id, reason);
            await interaction.reply({ content: `🔨 ${target.user.tag} a été banni.\nRaison: ${reason}` });
            await logModeration(client, target.user, 'Bannissement', reason, interaction.user);
        }

        else if (commandName === 'timeout') {
            const target = interaction.options.getMember('utilisateur');
            const duration = interaction.options.getInteger('duree');
            const reason = interaction.options.getString('raison') || 'Aucune raison fournie';
            if (!target) return interaction.reply({ content: "Utilisateur non trouvé.", ephemeral: true });
            try {
                await target.timeout(duration * 60 * 1000, reason);
                db.addModerationAction('TIMEOUT', target.id, interaction.user.id, reason);
                await interaction.reply({ content: `🔇 ${target.user.tag} a été mis en sourdine pour ${duration} minutes.\nRaison: ${reason}` });
                await logModeration(client, target.user, 'Mute (Timeout)', `Durée: ${duration}m | Raison: ${reason}`, interaction.user);
            } catch (e) {
                await interaction.reply({ content: "Erreur lors du timeout.", ephemeral: true });
            }
        }

        else if (commandName === 'clear') {
            const amount = interaction.options.getInteger('nombre');
            if (amount < 1 || amount > 100) return interaction.reply({ content: "Nombre invalide (1-100).", ephemeral: true });
            await interaction.channel.bulkDelete(amount, true);
            await interaction.reply({ content: `✅ ${amount} messages supprimés.`, ephemeral: true });
        }

        else if (commandName === 'mod_history') {
            const target = interaction.options.getUser('utilisateur');
            const history = db.getModerationHistory(target.id);

            if (history.length === 0) {
                return interaction.reply({ content: `Aucun historique pour ${target.tag}.`, ephemeral: true });
            }

            const embed = new EmbedBuilder()
                .setTitle(`Historique - ${target.tag}`)
                .setColor('#34495e')
                .setTimestamp();

            const list = history.map(a => `**${a.type}** | ${a.reason} (par <@${a.staffId}>) - <t:${Math.floor(new Date(a.createdAt).getTime() / 1000)}:R>`).join('\n');

            if (list.length > 4096) {
                 await interaction.reply({ content: "Historique trop long pour être affiché.", ephemeral: true });
            } else {
                 embed.setDescription(list);
                 await interaction.reply({ embeds: [embed], ephemeral: true });
            }
        }

        else if (commandName === 'stats_tickets') {
            if (!await checkStaff(interaction)) return;
            const stats = db.getStats();
            const embed = new EmbedBuilder()
                .setTitle("Statistiques des Tickets")
                .addFields(
                    { name: "Total", value: `${stats.total}`, inline: true },
                    { name: "Ouverts", value: `${stats.open}`, inline: true },
                    { name: "Fermés", value: `${stats.closed}`, inline: true }
                )
                .setColor('#3498db')
                .setTimestamp();
            await interaction.reply({ embeds: [embed], ephemeral: true });
        }

        else if (commandName === 'staff_stats') {
            if (!await checkStaff(interaction)) return;
            const target = interaction.options.getUser('staff') || interaction.user;
            const stats = db.getStaffStats(target.id) || { claimedCount: 0, closedCount: 0 };

            const embed = new EmbedBuilder()
                .setTitle(`Stats Staff - ${target.tag}`)
                .setThumbnail(target.displayAvatarURL())
                .addFields(
                    { name: "Tickets Pris en charge", value: `${stats.claimedCount}`, inline: true },
                    { name: "Tickets Fermés", value: `${stats.closedCount}`, inline: true }
                )
                .setColor('#9b59b6')
                .setTimestamp();
            await interaction.reply({ embeds: [embed], ephemeral: true });
        }

        else if (commandName === 'priority') {
            if (!await checkStaff(interaction)) return;
            const ticket = db.getTicket(interaction.channelId);
            if (!ticket) return interaction.reply({ content: "Ce salon n'est pas un ticket.", ephemeral: true });

            const level = interaction.options.getString('niveau');
            db.setPriority(interaction.channelId, level);

            const colors = { 'Basse': '#95a5a6', 'Normale': '#3498db', 'Haute': '#e67e22', 'Urgente': '#c0392b' };

            const embed = new EmbedBuilder()
                .setDescription(`Priorité du ticket modifiée en **${level}** par ${interaction.user}.`)
                .setColor(colors[level] || '#3498db');

            await interaction.reply({ embeds: [embed] });
            await logTicketAction(client, 'Changement Priorité', interaction.user, interaction.channel, `Nouvelle priorité: ${level}`);
        }

        else if (commandName === 'check_inactifs') {
            if (!await checkStaff(interaction)) return;
            const hours = interaction.options.getInteger('heures') || 24;
            const inactives = db.getInactiveTickets(hours);

            if (inactives.length === 0) {
                return interaction.reply({ content: `Aucun ticket inactif depuis plus de ${hours} heures.`, ephemeral: true });
            }

            const list = inactives.map(t => `<#${t.channelId}> (Dernière activité: ${t.lastActivityAt})`).join('\n');
            await interaction.reply({ content: `**Tickets inactifs (${hours}h+) :**\n${list}`, ephemeral: true });
        }

        else if (commandName === 'rename') {
            if (!await checkStaff(interaction)) return;
            const ticket = db.getTicket(interaction.channelId);
            if (!ticket) return interaction.reply({ content: "Ce salon n'est pas un ticket.", ephemeral: true });
            const newName = interaction.options.getString('nom');
            await interaction.channel.setName(newName);
            await interaction.reply({ content: `✅ Ticket renommé en **${newName}**.` });
            await logTicketAction(client, 'Renommage', interaction.user, interaction.channel, `Nouveau nom: ${newName}`);
        }

        else if (commandName === 'transcript') {
            if (!await checkStaff(interaction)) return;
            const ticket = db.getTicket(interaction.channelId);
            if (!ticket) return interaction.reply({ content: "Ce salon n'est pas un ticket.", ephemeral: true });

            await interaction.deferReply();
            const attachment = await transcript.createTranscript(interaction.channel);
            await interaction.editReply({ content: "Transcription générée :", files: [attachment] });
        }

        else if (commandName === 'blacklist') {
            if (!await checkStaff(interaction)) return;
            const action = interaction.options.getString('action');
            const user = interaction.options.getUser('utilisateur');
            const reason = interaction.options.getString('raison') || 'Aucune raison fournie';

            if (action === 'add') {
                db.addToBlacklist(user.id, reason, interaction.user.id);
                await interaction.reply({ content: `${user.tag} a été ajouté à la liste noire.`, ephemeral: true });
                await logTicketAction(client, 'Blacklist - Ajout', interaction.user, interaction.channel || { name: 'Général', id: 'N/A' }, `Utilisateur: ${user.tag}, Raison: ${reason}`);
            } else {
                db.removeFromBlacklist(user.id);
                await interaction.reply({ content: `${user.tag} a été retiré de la liste noire.`, ephemeral: true });
                await logTicketAction(client, 'Blacklist - Retrait', interaction.user, interaction.channel || { name: 'Général', id: 'N/A' }, `Utilisateur: ${user.tag}`);
            }
        }
    }

    else if (interaction.isButton()) {
        const [action, data] = interaction.customId.split(':');

        if (action === 'ticket_create') {
            await handleTicketCreation(interaction, data);
        } else if (action === 'ticket_action') {
            await handleTicketAction(interaction, data);
        } else if (action === 'recruit_action') {
            await handleRecruitAction(interaction, data);
        }
    }

    else if (interaction.isModalSubmit()) {
        if (interaction.customId === 'modal_close_ticket') {
            await handleCloseTicket(interaction);
        } else if (interaction.customId.startsWith('modal_recruit_reject:')) {
            const userId = interaction.customId.split(':')[1];
            await handleRecruitRejectSubmit(interaction, userId);
        }
    }

    else if (interaction.isUserSelectMenu()) {
        if (interaction.customId === 'ticket_user_toggle') {
            await handleUserToggle(interaction);
        }
    }
});

async function getMonthlyCategory(guild) {
    const date = new Date();
    const monthNames = [
        "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
        "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ];
    const categoryName = `Tickets - ${monthNames[date.getMonth()]} ${date.getFullYear()}`;

    let category = guild.channels.cache.find(c => c.name === categoryName && c.type === ChannelType.GuildCategory);

    if (!category) {
        try {
            category = await guild.channels.create({
                name: categoryName,
                type: ChannelType.GuildCategory,
                permissionOverwrites: [
                    { id: guild.id, deny: [PermissionFlagsBits.ViewChannel] }
                ]
            });
        } catch (e) {
            console.error("Erreur lors de la création de la catégorie mensuelle:", e);
            return guild.channels.cache.get(config.channels.ticketCategory);
        }
    }

    return category;
}

async function handleTicketCreation(interaction, categoryKey) {
    const categoryCfg = config.ticketCategories[categoryKey];

    if (db.isBlacklisted(interaction.user.id)) {
        const info = db.getBlacklistInfo(interaction.user.id);
        return interaction.reply({
            content: `Vous êtes banni du système de tickets.\nRaison : ${info.reason}`,
            ephemeral: true
        });
    }

    const activeCount = db.getActiveTicketCount(interaction.user.id);
    if (activeCount >= config.ticketLimitPerUser) {
        return interaction.reply({ content: "Vous avez déjà un ticket ouvert.", ephemeral: true });
    }

    const lastTime = db.getLastTicketTime(interaction.user.id);
    if (lastTime) {
        const delta = (Date.now() - lastTime.getTime()) / 1000;
        if (delta < config.cooldownSeconds) {
            const remaining = Math.ceil(config.cooldownSeconds - delta);
            return interaction.reply({ content: `Veuillez patienter ${remaining} secondes.`, ephemeral: true });
        }
    }

    await interaction.deferReply({ ephemeral: true });

    const guild = interaction.guild;
    const overwrites = [
        { id: guild.id, deny: [PermissionFlagsBits.ViewChannel] },
        { id: interaction.user.id, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory, PermissionFlagsBits.AttachFiles] },
        { id: client.user.id, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ManageChannels] }
    ];

    if (categoryKey === 'direction') {
        if (config.roles.admin) {
            overwrites.push({ id: config.roles.admin, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory] });
        }
    } else if (config.roles.staff) {
        overwrites.push({ id: config.roles.staff, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory] });
    }

    const monthlyCategory = await getMonthlyCategory(guild);

    const channel = await guild.channels.create({
        name: `${categoryCfg.name}-${interaction.user.username}`,
        type: ChannelType.GuildText,
        parent: monthlyCategory.id,
        permissionOverwrites: overwrites
    });

    db.createTicket(channel.id, interaction.user.id, categoryKey);
    db.setCooldown(interaction.user.id);

    const embed = new EmbedBuilder()
        .setTitle(`Ticket ${categoryCfg.label} - OUVERT`)
        .setDescription(categoryCfg.welcomeMessage)
        .setColor(categoryCfg.color)
        .addFields({ name: "Règles", value: "• Un seul ticket à la fois.\n• Soyez respectueux.\n• Soyez patient." })
        .setFooter({ text: `ID Utilisateur: ${interaction.user.id}` })
        .setTimestamp();

    const row = new ActionRowBuilder().addComponents(
        new ButtonBuilder().setCustomId('ticket_action:claim').setLabel('Claim').setEmoji('🙋‍♂️').setStyle(ButtonStyle.Success),
        new ButtonBuilder().setCustomId('ticket_action:add_remove').setLabel('Ajouter/Retirer').setEmoji('👤').setStyle(ButtonStyle.Secondary),
        new ButtonBuilder().setCustomId('ticket_action:reopen').setLabel('Réouvrir').setEmoji('🔓').setStyle(ButtonStyle.Primary),
        new ButtonBuilder().setCustomId('ticket_action:close').setLabel('Fermer').setEmoji('🔒').setStyle(ButtonStyle.Danger)
    );

    const staffPing = config.roles.staff ? ` | <@&${config.roles.staff}>` : '';

    if (categoryCfg.isRecruitment) {
        const recruitRow = new ActionRowBuilder().addComponents(
            new ButtonBuilder().setCustomId(`recruit_action:accept`).setLabel('Accepter').setEmoji('✅').setStyle(ButtonStyle.Success),
            new ButtonBuilder().setCustomId(`recruit_action:reject`).setLabel('Refuser').setEmoji('❌').setStyle(ButtonStyle.Danger)
        );
        await channel.send({ content: `${interaction.user}${staffPing}`, embeds: [embed], components: [row, recruitRow] }).then(m => m.pin());
    } else {
        await channel.send({ content: `${interaction.user}${staffPing}`, embeds: [embed], components: [row] }).then(m => m.pin());
    }

    await interaction.editReply(`Votre ticket a été créé : ${channel}`);
    await logTicketAction(client, 'Création', interaction.user, channel, `Catégorie: ${categoryCfg.label}`);
}

async function checkStaff(interaction) {
    if (interaction.member.permissions.has(PermissionFlagsBits.Administrator)) return true;
    if (config.roles.staff && interaction.member.roles.cache.has(config.roles.staff)) return true;
    if (config.roles.admin && interaction.member.roles.cache.has(config.roles.admin)) return true;
    await interaction.reply({ content: "Vous n'avez pas la permission.", ephemeral: true });
    return false;
}

async function handleTicketAction(interaction, actionType) {
    if (!await checkStaff(interaction)) return;

    if (actionType === 'claim') {
        const ticket = db.getTicket(interaction.channelId);
        if (!ticket) return interaction.reply({ content: "Ticket non trouvé.", ephemeral: true });
        if (ticket.staffId) return interaction.reply({ content: `Déjà pris en charge par <@${ticket.staffId}>.`, ephemeral: true });

        db.claimTicket(interaction.channelId, interaction.user.id);
        await interaction.channel.permissionOverwrites.edit(interaction.user, { ViewChannel: true, SendMessages: true, ManageChannels: true });

        if (!interaction.channel.name.startsWith('✔-')) {
            await interaction.channel.setName(`✔-${interaction.channel.name}`).catch(() => null);
        }

        await interaction.reply({ embeds: [new EmbedBuilder().setDescription(`Le ticket a été pris en charge par ${interaction.user}.`).setColor('#2ecc71')] });
        await logTicketAction(client, 'Prise en charge', interaction.user, interaction.channel);
    }
    else if (actionType === 'add_remove') {
        const row = new ActionRowBuilder().addComponents(
            new UserSelectMenuBuilder().setCustomId('ticket_user_toggle').setPlaceholder('Sélectionnez un membre...')
        );
        await interaction.reply({ content: "Choisissez un membre :", components: [row], ephemeral: true });
    }
    else if (actionType === 'reopen') {
        const ticket = db.getTicket(interaction.channelId);
        if (!ticket || ticket.status !== 'closed') return interaction.reply({ content: "Le ticket n'est pas fermé.", ephemeral: true });

        db.updateTicketStatus(interaction.channelId, 'open');
        const user = await interaction.guild.members.fetch(ticket.userId).catch(() => null);
        if (user) await interaction.channel.permissionOverwrites.edit(user, { ViewChannel: true, SendMessages: true });

        const monthlyCategory = await getMonthlyCategory(interaction.guild);
        await interaction.channel.setParent(monthlyCategory.id);

        await interaction.reply({ embeds: [new EmbedBuilder().setTitle("Ticket RÉOUVERT").setDescription(`Réouvert par ${interaction.user}.`).setColor('#3498db')] });
        await logTicketAction(client, 'Réouverture', interaction.user, interaction.channel);
    }
    else if (actionType === 'close') {
        const modal = new ModalBuilder().setCustomId('modal_close_ticket').setTitle('Fermeture du ticket');
        const reasonInput = new TextInputBuilder().setCustomId('close_reason').setLabel("Raison").setStyle(TextInputStyle.Paragraph).setRequired(true);
        modal.addComponents(new ActionRowBuilder().addComponents(reasonInput));
        await interaction.showModal(modal);
    }
}

async function handleUserToggle(interaction) {
    const userId = interaction.values[0];
    const user = await interaction.guild.members.fetch(userId);
    const hasPerm = interaction.channel.permissionOverwrites.cache.has(userId);

    const ticket = db.getTicket(interaction.channelId);

    if (hasPerm) {
        if (ticket && userId === ticket.userId) {
            return interaction.reply({ content: "Vous ne pouvez pas retirer le créateur du ticket.", ephemeral: true });
        }
        await interaction.channel.permissionOverwrites.delete(userId);
        await interaction.reply({ content: `${user} retiré.`, ephemeral: true });
    } else {
        await interaction.channel.permissionOverwrites.edit(user, { ViewChannel: true, SendMessages: true });
        await interaction.reply({ content: `${user} ajouté.`, ephemeral: true });
    }
    await logTicketAction(client, 'Modif. Membres', interaction.user, interaction.channel, `${user.user.tag} (${hasPerm ? 'retiré' : 'ajouté'})`);
}

async function handleCloseTicket(interaction) {
    const reason = interaction.fields.getTextInputValue('close_reason');
    const ticket = db.getTicket(interaction.channelId);
    if (!ticket) return interaction.reply({ content: "Erreur.", ephemeral: true });

    await interaction.deferReply();
    db.updateTicketStatus(interaction.channelId, 'closed');
    db.incrementClosedStats(interaction.user.id);

    const user = await interaction.guild.members.fetch(ticket.userId).catch(() => null);
    if (user) await interaction.channel.permissionOverwrites.delete(user.id);

    if (config.channels.archiveCategory) {
        await interaction.channel.setParent(config.channels.archiveCategory).catch(() => null);
    }

    const attachment = await transcript.createTranscript(interaction.channel);

    const embed = new EmbedBuilder()
        .setTitle("Ticket FERMÉ")
        .setDescription(`Fermé par ${interaction.user}.\n\n**Raison :** ${reason}`)
        .setColor('#e74c3c')
        .setTimestamp();

    if (user) {
        const dmEmbed = new EmbedBuilder()
            .setTitle(`Votre ticket sur ${interaction.guild.name} est fermé`)
            .setDescription(`**Raison :** ${reason}`)
            .setColor('#e74c3c')
            .setTimestamp();
        await user.send({ embeds: [dmEmbed], files: [attachment] }).catch(() => null);
    }

    await interaction.channel.send({ embeds: [embed] });
    await logTicketAction(client, 'Fermeture', interaction.user, interaction.channel, `Raison: ${reason}`, attachment);
    await interaction.editReply("Ticket fermé.");
}

async function handleRecruitAction(interaction, actionType) {
    const isStaff = interaction.member.roles.cache.has(config.roles.recruitmentStaff) || interaction.member.permissions.has(PermissionFlagsBits.Administrator);
    if (!isStaff) return interaction.reply({ content: "Pas autorisé.", ephemeral: true });

    const ticket = db.getTicket(interaction.channelId);
    if (!ticket) return;
    const member = await interaction.guild.members.fetch(ticket.userId).catch(() => null);

    if (actionType === 'accept') {
        if (!member) return interaction.reply({ content: "Membre non trouvé.", ephemeral: true });
        if (config.roles.recruit) await member.roles.add(config.roles.recruit);

        if (config.channels.recruitChannelsCategory) {
            await interaction.guild.channels.create({
                name: `bienvenue-${member.user.username}`,
                parent: config.channels.recruitChannelsCategory,
                permissionOverwrites: [
                    { id: interaction.guild.id, deny: [PermissionFlagsBits.ViewChannel] },
                    { id: member.id, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages] }
                ]
            });
        }

        await interaction.reply({ embeds: [new EmbedBuilder().setTitle("Candidature ACCEPTÉE").setDescription(`Félicitations ${member} ! Accepté par ${interaction.user}.`).setColor('#2ecc71')] });
        await logTicketAction(client, 'Recrutement - Accepté', interaction.user, interaction.channel, `Candidat: ${member.user.tag}`);
    } else if (actionType === 'reject') {
        const modal = new ModalBuilder().setCustomId(`modal_recruit_reject:${ticket.userId}`).setTitle('Refus de candidature');
        const reasonInput = new TextInputBuilder().setCustomId('reject_reason').setLabel("Raison").setStyle(TextInputStyle.Paragraph).setRequired(true);
        modal.addComponents(new ActionRowBuilder().addComponents(reasonInput));
        await interaction.showModal(modal);
    }
}

async function handleRecruitRejectSubmit(interaction, userId) {
    const reason = interaction.fields.getTextInputValue('reject_reason');
    const member = await interaction.guild.members.fetch(userId).catch(() => null);

    if (member) {
        await member.send(`Votre candidature sur **${interaction.guild.name}** a été refusée.\n**Raison :** ${reason}`).catch(() => null);
    }

    await interaction.reply({ embeds: [new EmbedBuilder().setTitle("Candidature REFUSÉE").setDescription(`Refusé par ${interaction.user}.\n**Raison :** ${reason}`).setColor('#e74c3c')] });
    await logTicketAction(client, 'Recrutement - Refusé', interaction.user, interaction.channel, `Candidat: ${member ? member.user.tag : userId}, Raison: ${reason}`);
    await interaction.followup({ content: "Vous pouvez maintenant fermer le ticket.", ephemeral: true });
}

client.login(config.token).catch(err => {
    if (err.message.includes('Used disallowed intents')) {
        console.error('ERREUR: Intents non activés dans le Developer Portal !');
        console.error('Veuillez activer "Server Members Intent" et "Message Content Intent" pour que le bot fonctionne.');
    } else {
        console.error('Erreur de connexion:', err);
    }
});
