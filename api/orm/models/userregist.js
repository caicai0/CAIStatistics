'use strict';
module.exports = (sequelize, DataTypes) => {
  var userRegist = sequelize.define('userRegist', {
    userName: DataTypes.STRING,
    password: DataTypes.STRING,
    verification: DataTypes.STRING
  }, {});
  userRegist.associate = function(models) {
    // associations can be defined here
  };
  return userRegist;
};