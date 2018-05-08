'use strict';
module.exports = (sequelize, DataTypes) => {
    const userApplication = sequelize.define('userApplication', {
        userId:DataTypes.INTEGER,
        name: DataTypes.STRING,
        platform:DataTypes.STRING,
        bundleIdentifier:DataTypes.STRING,
        description:DataTypes.STRING,
        functionName:DataTypes.STRING,
        keyPath:DataTypes.STRING,
    }, {});
    userApplication.associate = function(models) {
        // associations can be defined here
    };
    return userApplication;
};