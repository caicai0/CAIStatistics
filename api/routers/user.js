
const router = require('koa-router')();
const orm = require('../orm/models/index');
const md5 = require('md5');

router.post('/user/register', async(ctx, next) => {
    const post = {
        name: ctx.request.body.name,
        pass: ctx.request.body.password,
        repeatpass: ctx.request.body.repeatpass
    };
    let user = await orm.User.findOne({where:{username:post.name}});
    if (user) {
        ctx.body = {code: 0, message: "用户已存在"};
    }else {
        user = await orm.User.create({username: post.name, passwordMd5: post.pass});
        if(user){
            ctx.body = {code: 0, message: "注册成功"};
        }
    }
});

router.post('/user/login', async (ctx, next) => {
    const post = {
        name: ctx.request.body.name,
        pass: ctx.request.body.password,
        repeatpass: ctx.request.body.repeatpass
    };
    let user = await orm.User.findOne({where:{username:post.name}});
    if (user) {
        ctx.body = {code: 0, message: "用户已存在"};
    }else {
        user = await orm.User.create({username: post.name, passwordMd5: post.pass});
        if(user){
            ctx.body = {code: 0, message: "注册成功"};
        }
    }
});

module.exports = router;