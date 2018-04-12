'use strict';
module.exports = (sequelize, DataTypes) => {
    var applicationBaseInfo = sequelize.define('applicationBaseInfo', {
        applicationId:DataTypes.INTEGER,
        name: DataTypes.STRING,
        value:DataTypes.STRING,
    }, {});
    applicationBaseInfo.associate = function(models) {
        // associations can be defined here
    };
    return applicationBaseInfo;
};