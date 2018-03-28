
const config = {
    domain:"flagcaicai.f3322.net",
    port:63010,
    database: {
        dialect: "sqlite",
        storage: __dirname +"/db.sqlite"
    },
    production: {
        port:3000,
        database: {
            username: process.env.DB_USERNAME,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME,
            host: process.env.DB_HOSTNAME,
            dialect: 'mysql',
        }
    }
};

module.exports = config;