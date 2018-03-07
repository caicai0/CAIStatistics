'use strict';
module.exports = (sequelize, DataTypes) => {
    const User = sequelize.define('User', {
        username: {type:DataTypes.STRING},
        passwordMd5:{type:DataTypes.STRING}
    });

    User.associate = function (models) {
        models.User.hasMany(models.Application);
    };

    return User;
};
