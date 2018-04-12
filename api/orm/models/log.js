'use strict';
module.exports = (sequelize, DataTypes) => {
    var userApplication = sequelize.define('log', {
        userApplicationId:DataTypes.INTEGER,
        name: DataTypes.STRING,
        values:DataTypes.STRING,
        timeStamp:DataTypes.DATE,
    }, {});
    userApplication.associate = function(models) {
        // associations can be defined here
    };
    return userApplication;
};