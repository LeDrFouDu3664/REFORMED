import { EmbedBuilder } from 'discord.js';
import config from './config.js';

export async function logTicketAction(client, action, staff, channel, details = null, file = null) {
    const logChannel = await client.channels.fetch(config.channels.logs).catch(() => null);
    if (!logChannel) return;

    const channelValue = channel.id !== 'N/A' ? `<#${channel.id}>` : (channel.name || 'Inconnu');

    const embed = new EmbedBuilder()
        .setTitle(`Log Ticket - ${action}`)
        .setColor(action === 'Création' ? '#3498db' : '#e67e22')
        .addFields(
            { name: 'Salon', value: `${channelValue} (\`${channel.name}\`)`, inline: true },
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

export async function logModeration(client, target, type, reason, staff) {
    const logChannel = await client.channels.fetch(config.channels.logs).catch(() => null);
    if (!logChannel) return;

    const embed = new EmbedBuilder()
        .setTitle(`Modération - ${type}`)
        .setColor(type === 'Bannissement' ? '#c0392b' : '#f39c12')
        .addFields(
            { name: 'Utilisateur', value: `${target.tag || target} (\`${target.id}\`)`, inline: true },
            { name: 'Modérateur', value: `${staff} (\`${staff.id}\`)`, inline: true },
            { name: 'Raison', value: reason, inline: false }
        )
        .setTimestamp();

    await logChannel.send({ embeds: [embed] });
}

export async function logMessageDeleted(client, message) {
    if (message.author?.bot) return;
    const logChannel = await client.channels.fetch(config.channels.logs).catch(() => null);
    if (!logChannel) return;

    const embed = new EmbedBuilder()
        .setTitle("Message Supprimé")
        .setColor('#e74c3c')
        .addFields(
            { name: 'Auteur', value: `${message.author} (\`${message.author.id}\`)`, inline: true },
            { name: 'Salon', value: `${message.channel}`, inline: true },
            { name: 'Contenu', value: message.content || '*Fichier/Embed*' }
        )
        .setTimestamp();

    await logChannel.send({ embeds: [embed] });
}

export async function logMessageEdited(client, oldMessage, newMessage) {
    if (oldMessage.author?.bot || oldMessage.content === newMessage.content) return;
    const logChannel = await client.channels.fetch(config.channels.logs).catch(() => null);
    if (!logChannel) return;

    const embed = new EmbedBuilder()
        .setTitle("Message Modifié")
        .setColor('#3498db')
        .addFields(
            { name: 'Auteur', value: `${oldMessage.author} (\`${oldMessage.author.id}\`)`, inline: true },
            { name: 'Salon', value: `${oldMessage.channel}`, inline: true },
            { name: 'Ancien', value: oldMessage.content || '*Vide*' },
            { name: 'Nouveau', value: newMessage.content || '*Vide*' }
        )
        .setTimestamp();

    await logChannel.send({ embeds: [embed] });
}
