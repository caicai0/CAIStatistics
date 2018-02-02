var mysql = require('mysql');
var config = require('../config/default.js');

var pool  = mysql.createPool({
  host     : config.database.HOST,
  port     : config.database.PORT,
  user     : config.database.USERNAME,
  password : config.database.PASSWORD,
  database : config.database.DATABASE
});

let query = function( sql, values ) {
  return new Promise(( resolve, reject ) => {
    pool.getConnection(function(err, connection) {
      if (err) {
        resolve( err )
      } else {
        connection.query(sql, values, ( err, rows) => {
          if ( err ) {
            reject( err )
          } else {
            resolve( rows )
          }
          connection.release()
        })
      }
    })
  })
};

let users=
    `create table if not exists users(
     id INT NOT NULL AUTO_INCREMENT,
     name VARCHAR(100) NOT NULL,
     pass VARCHAR(40) NOT NULL,
     PRIMARY KEY ( id )
    );`

let createTable = function( sql ) {
  return query( sql, [] )
}
// 建表
createTable(users)
// 注册用户
let insertData = function( value ) {
  let _sql = "insert into users(name,pass) values(?,?);"
  return query( _sql, value )
}
// 删除用户(测试使用)
let deleteUserData = function( name ) {
  let _sql = `delete from users where name="${name}";`
  return query( _sql )
}
// 查找用户(测试使用)
let findUserData = function( name ) {
  let _sql = `select * from users where name="${name}";`
  return query( _sql )
}

// 通过名字查找用户
let findDataByName = function (  name ) {
  let _sql = `
    select * from users
      where name="${name}"
      `
  return query( _sql)
}

// 滚动无限加载数据
let findPageById = function(page){
  let _sql=`select * from posts limit ${(page-1)*5},5;`
  return query(_sql)
}

module.exports={
	query,
	createTable,
	insertData,
  deleteUserData,
  findUserData,
	findDataByName,
  findPageById
}

