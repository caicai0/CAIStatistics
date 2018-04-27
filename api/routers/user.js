
const router = require('koa-router')();
const orm = require('../orm/models/index');
const md5 = require('blueimp-md5');
const sendMail = require('../service/sendMail');
const config = require('../config/config');

function ismail(obj){
    let reg=/[a-zA-Z0-9]{1,10}@[a-zA-Z0-9]{1,5}\.[a-zA-Z0-9]{1,5}/;
    return reg.test(obj.value);
}

router.post('/user/register', async(ctx, next) => {
    const post = {
        name: ctx.request.body.name,
        pass: ctx.request.body.password,
        repeatpass: ctx.request.body.repeatpass
    };

    if (!config.allowRegister){
        ctx.body = {code:0,message:'管理员没有开通注册功能'};
        return;
    }

    if(!ismail(post.name)){
        ctx.body = {code:0, message:'name不是邮箱'};
    }else if(post.pass == null){

    }
    else if(post.pass != post.repeatpass){
        ctx.body = {code:0, message:'两次密码不一致'};
    }else {
        let user = await orm.user.findOne({where:{userName:post.name}});
        if (user) {
            ctx.body = {code: 0, message: "用户已存在"};
        }else {
            let userRgist = await orm.userRegist.findOne({where:{userName:post.name}});
            let nowStamp = new Date().getTime();
            if(userRgist && nowStamp - userRgist.createdAt.getTime()<60){
                ctx.body = {code:0, message: "已经注册请等待"}
            }else {
                if(userRgist){
                    await userRgist.destroy({force:true});
                }
                let ver =  md5(toString(nowStamp));
                orm.userRegist.create({userName:post.name,password:md5(post.pass),verification:ver});
                let content = '您正在注册api用户，点击此链接确认。'+'http://'+config.domain+':'+config.port+'/user/verification?name='+post.name+'&verification='+ver;
                let error = await sendMail(post.name,'用户确认',content);
                if(error){
                    ctx.body = {code:0, message:JSON.stringify(error)};
                }else {
                    ctx.body = {code:0, message:'确认邮件已经发出'};
                }
            }
        }
    }
});

router.get('/user/verification', async (ctx, next)=> {
    ctx.body = {code:0,message:'验证'};
});

router.post('/user/login', async (ctx, next) => {
    const post = {
        name: ctx.request.body.name,
        pass: ctx.request.body.password,
        repeatpass: ctx.request.body.repeatpass
    };
    console.log(post);
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

router.post('user/logout',async (ctx, next) => {

});

router.post('user/applications',async (ctx, next) => {

});

router.post('user/createApplication',async (ctx, next) => {

});

router.post('user/updateApplication',async (ctx, next) => {

});

module.exports = router;