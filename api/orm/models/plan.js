'use strict';
module.exports = (sequelize, DataTypes) => {
    var plan = sequelize.define('plan', {
        userApplicationId: DataTypes.STRING,
        name: DataTypes.STRING,
        type:DataTypes.INTEGER,
        classPath:DataTypes.STRING,
        functionName:DataTypes.STRING,
        values:DataTypes.STRING,              //json字符串  {key:value}
    }, {});
    plan.associate = function(models) {
        // associations can be defined here
    };
    return plan;
};