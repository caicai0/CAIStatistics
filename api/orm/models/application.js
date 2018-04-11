'use strict';
module.exports = (sequelize, DataTypes) => {
    var application = sequelize.define('application', {
        deviceId:DataTypes.INTEGER,
        UUID: DataTypes.STRING,
        bundleIdentifier:DataTypes.STRING,
        deviceToken:DataTypes.STRING,
    }, {});
    application.associate = function(models) {
        // associations can be defined here
    };
    return application;
};