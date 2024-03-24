export default {
    // Bot configuration, https://discord.com/developers/applications
    client: {
        token: '',
        id: '',
    },

    // Log system, if you want to enable it, set status to true and set the channel id.
    log: {
        status: false,
        channel: '',
    },

    // MySQL database configuration, must match that of the MTA script.
    mysql: {
        host: '',
        user: '',
        password: '',
        database: '',
    },
};
