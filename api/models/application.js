'use strict';
module.exports = (sequelize, DataTypes) => {
    const Application = sequelize.define('Application', {
        name: DataTypes.STRING,
        platform: DataTypes.STRING,
        boundleId: DataTypes.STRING
    });

    Application.associate = function (models) {
        models.Application.belongsTo(models.User, {
            onDelete: "CASCADE",
            foreignKey: {
                allowNull: false
            }
        });
    };

    return Application;
};
