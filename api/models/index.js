'use strict';

var fs = require('fs');
var path = require('path');
var Sequelize = require('sequelize');
var basename = path.basename(__filename);
var config = require(__dirname + '/../config/config.js');
var db = {};

var sequelize;

sequelize = new Sequelize(config.database);

fs
    .readdirSync(__dirname)
    .filter(file => {
        return (file.indexOf('.') !== 0) && (file !== basename) && (file.slice(-3) === '.js');
    })
    .forEach(file => {
        var model = sequelize['import'](path.join(__dirname, file));
        db[model.name] = model;
    });

Object.keys(db).forEach(modelName => {
    if (db[modelName].associate) {
        db[modelName].associate(db);
    }
});

Object.keys(db).forEach(modelName => {
    if (db[modelName].sync){
        db[modelName].sync();
    }
});

db.sequelize = sequelize;

module.exports = db;