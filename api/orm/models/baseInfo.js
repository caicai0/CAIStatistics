'use strict';
module.exports = (sequelize, DataTypes) => {
    var baseInfo = sequelize.define('baseInfo', {
        userApplicationId:DataTypes.INTEGER,
        name: DataTypes.STRING,
        classPath:DataTypes.STRING,
        functionName:DataTypes.STRING,
        keyPath:DataTypes.STRING,
    }, {});
    baseInfo.associate = function(models) {
        // associations can be defined here
    };
    return baseInfo;
};