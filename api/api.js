const Koa=require('koa');
const path=require('path');
const bodyParser = require('koa-bodyparser');
const config = require(__dirname + '/config/config.js');
const router=require('koa-router');
const koaStatic = require('koa-static');
const app=new Koa();

// 配置静态资源加载中间件
app.use(require('./middlewares/error'));

app.use(koaStatic(
  path.join(__dirname , './public')
));

app.use(bodyParser());

//  路由
app.use(require('./routers/user.js').routes());
app.use(require('./routers/app.js').routes());

app.on('error',function(err,ctx){
  ctx.body = JSON.stringify(err);
});

if (module.parent) {
  	module.exports = app;
}else{
	app.listen(3000);
}
console.log(`listening on port ${config.port}`);
