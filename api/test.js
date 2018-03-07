const models = require('./models');

function insertData() {
    models.sequelize.User.create({username:'user1',passwordMd5:'123456'});
}