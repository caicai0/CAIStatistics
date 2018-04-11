'use strict';
module.exports = (sequelize, DataTypes) => {
  var device = sequelize.define('device', {
      model: DataTypes.STRING,
      openUDID: DataTypes.STRING,
      systemVersion:DataTypes.STRING,
  }, {});
  device.associate = function(models) {
    // associations can be defined here
  };
  return device;
};