import {
    ChannelType,
    Client,
    EmbedBuilder,
    Events,
    GatewayIntentBits,
    Partials,
    REST,
    Routes,
    SlashCommandBuilder,
} from 'discord.js';

import config from './config.js';
import { createConnection } from 'mysql2/promise';

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMembers,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
        GatewayIntentBits.DirectMessages,
    ],
    partials: [Partials.Message, Partials.Channel],
});

const rest = new REST({ version: '10' }).setToken(config.client.token);

client.once(Events.ClientReady, async (client) => {
    console.clear();
    console.log('\x1b[32m', `[+] ${client.user.username} (${client.user.id})`);
});

client.on(Events.MessageCreate, async (message) => {
    if (message.channel.type == ChannelType.DM) {
        if (!isNaN(message.content) && message.content.length == 6) {
            await createConnection({
                host: config.mysql.host,
                user: config.mysql.user,
                password: config.mysql.password,
                database: config.mysql.database,
            })
                .then(async (connection) => {
                    const [results] = await connection.query('SELECT * FROM auth WHERE auth_code = ?', [
                        message.content,
                    ]);

                    if (results && results.length > 0) {
                        await connection.query(
                            'UPDATE auth SET discord_id = ?, auth_code = ?, is_paired = ?, paired_at = ? WHERE auth_code = ?',
                            [message.author.id, null, true, Date.now(), message.content]
                        );

                        await message.reply({
                            content: 'The pairing process was successful.',
                        });

                        if (config.log.status && client.channels.cache.get(config.log.channel)) {
                            const embed = new EmbedBuilder()
                                .setColor(0x2b2d31)
                                .setAuthor({
                                    iconURL: message.author.displayAvatarURL() ?? undefined,
                                    name: message.author.username,
                                    url: `https://discord.com/users/${message.author.id}`,
                                })
                                .setDescription(
                                    `The player paired <t:${Math.floor(Date.now() / 1000)}:R>` +
                                        '\n\n' +
                                        `Serial No: **\` ${results[0].serial_number} \`**`
                                );

                            client.channels.cache.get(config.log.channel).send({
                                embeds: [embed],
                            });
                        }
                    }

                    await connection.end();
                })
                .catch((error) => {
                    console.log('\x1b[31m', '[-] MySQL');

                    console.error(error);
                });
        }
    }
});

client.on(Events.InteractionCreate, async (interaction) => {
    if (interaction.commandName == 'info') {
        await interaction.deferReply({ ephemeral: true });

        const serial = interaction.options.getString('serial');
        const player = interaction.options.getUser('player');

        if (!serial && !player) {
            return await interaction.editReply({
                content: 'Please specify a serial number or select a player!',
            });
        }

        await createConnection({
            host: config.mysql.host,
            user: config.mysql.user,
            password: config.mysql.password,
            database: config.mysql.database,
        })
            .then(async (connection) => {
                const [results] = serial
                    ? await connection.query('SELECT * FROM auth WHERE serial_number = ? AND is_paired = ?', [
                          serial,
                          true,
                      ])
                    : await connection.query('SELECT * FROM auth WHERE discord_id = ? AND is_paired = ?', [
                          player.id,
                          true,
                      ]);

                if (results && results.length > 0) {
                    const member = interaction.guild.members.cache.get(results[0].discord_id);

                    const embed = new EmbedBuilder()
                        .setColor(0x2b2d31)
                        .setAuthor({
                            iconURL: member.user.displayAvatarURL() ?? undefined,
                            name: member.user.username,
                            url: `https://discord.com/users/${member.id}`,
                        })
                        .setDescription(
                            `The player paired <t:${Math.floor(results[0].paired_at / 1000)}:R>` +
                                '\n\n' +
                                `Serial No: **\` ${results[0].serial_number} \`**`
                        );

                    await interaction.editReply({
                        embeds: [embed],
                    });
                } else {
                    await interaction.editReply({
                        content: 'No matching found!',
                    });
                }

                await connection.end();
            })
            .catch(async (error) => {
                await interaction.editReply({
                    content: 'There was a problem with the database, please try again later.',
                });

                console.log('\x1b[31m', '[-] MySQL');

                console.error(error);
            });
    }
});

async function start() {
    try {
        const commands = [
            new SlashCommandBuilder()
                .setName('info')
                .setDescription('It shows the information of the given player.')
                .addStringOption((option) => option.setName('serial').setDescription('Serial No').setRequired(false))
                .addUserOption((option) => option.setName('player').setDescription('Player').setRequired(false))
                .toJSON(),
        ];

        await rest.put(Routes.applicationCommands(config.client.id), { body: commands });

        client.login(config.client.token);
    } catch (error) {
        throw new Error(error);
    }
}

start();
