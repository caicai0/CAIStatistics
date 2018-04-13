'use strict';
module.exports = (sequelize, DataTypes) => {
    var loginUser = sequelize.define('loginUser', {
        userName: DataTypes.STRING,
        password: DataTypes.STRING
    }, {});
    loginUser.associate = function(models) {
        // associations can be defined here
    };
    return loginUser;
};