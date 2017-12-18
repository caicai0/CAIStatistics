var Koa=require('koa');
var path=require('path')
var bodyParser = require('koa-bodyparser');
var config = require('./config/default.js');
var router=require('koa-router')
var koaStatic = require('koa-static')
var app=new Koa()


// session存储配置
const sessionMysqlConfig= {
  user: config.database.USERNAME,
  password: config.database.PASSWORD,
  database: config.database.DATABASE,
  host: config.database.HOST,
}

// 配置静态资源加载中间件
app.use(koaStatic(
  path.join(__dirname , './public')
))

app.use(bodyParser())

//  路由
app.use(require('./routers/user.js').routes())

if (module.parent) {
  	module.exports = app;
}else{
	app.listen(3000)
}
console.log(`listening on port ${config.port}`)
