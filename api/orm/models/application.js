'use strict';
module.exports = (sequelize, DataTypes) => {
    var application = sequelize.define('application', {
        deviceId:DataTypes.INTEGER,
        bundleIdentifier:DataTypes.STRING,
    }, {});
    application.associate = function(models) {
        // associations can be defined here
    };
    return application;
};