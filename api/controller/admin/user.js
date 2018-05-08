
const orm = require('../../orm/models/index');
const md5 = require('blueimp-md5');
const sendMail = require('../../service/sendMail');
const config = require('../../config/config');
const jsonToken = require('../../service/jsonToken');

const register = async function (ctx) {
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
    else if(post.pass !== post.repeatpass){
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
};

const verification = async function (ctx) {
    const get = {
        name: ctx.query.name,
        verification: ctx.query.verification
    };

    const userRgist = await orm.userRegist.findOne({where:{userName:get.name,verification:get.verification}});
    if (userRgist){
        await orm.userRegist.delete({where:{userName:get.name}});
        await orm.user.create({userName:userRgist.userName,password:userRgist.password});
        ctx.body = JSON.stringify({code:0,message:'成功'});
    }else {
        ctx.body = JSON.stringify({code:1,message:'请注册'});
    }
};

const login = async function (ctx) {
    const post = {
        userName: ctx.request.body.userName,
        password: ctx.request.body.password
    };
    const passwordMd5 = md5(post.password);
    const user = await orm.user.findOne({where:{userName:post.userName,password:passwordMd5}});
    if (user) {
        const token = await jsonToken.sign({userId:user.id});
        ctx.body = JSON.stringify({code:0,data:{token:token}});
    }else {
        ctx.body = JSON.stringify({code:1,message:'请注册'});
    }
};

module.exports = {
    register,
    verification,
    login
};