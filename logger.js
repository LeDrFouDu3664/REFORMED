const { EmbedBuilder } = require('discord.js');
const config = require('./config');

async function logTicketAction(client, action, staff, channel, details = null, file = null) {
    const logChannel = await client.channels.fetch(config.channels.logs).catch(() => null);
    if (!logChannel) return;

    const embed = new EmbedBuilder()
        .setTitle(`Log Ticket - ${action}`)
        .setColor(action === 'Création' ? '#3498db' : '#e67e22')
        .addFields(
            { name: 'Salon', value: `${channel} (\`${channel.name}\`)`, inline: true },
            { name: 'Responsable', value: `${staff} (\`${staff.id}\`)`, inline: true }
        )
        .setTimestamp();

    if (details) {
        embed.addFields({ name: 'Détails/Raison', value: details, inline: false });
    }

    const options = { embeds: [embed] };
    if (file) {
        options.files = [file];
    }

    await logChannel.send(options);
}

module.exports = { logTicketAction };
