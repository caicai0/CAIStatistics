
const orm = require('../../orm/models/index');
const jsonToken = require('../../service/jsonToken');

const userApplicationList = async function (ctx) {
    const header = {
        token:ctx.request.headers.token
    };
    const post = {
        page:ctx.request.body.page,
        size:ctx.request.body.size
    };
    try {
        const payload = await jsonToken.verify(header.token);
        if (jsonToken.isExpire(payload.iat)){
            if (!post.page) {
                post.page = 0;
            }
            if (!post.size) {
                post.size = 20;
            }
            const list = await orm.userApplication.find({where:{userId:payload.userId},offset:post.page*post.size,limit:post.size});
            ctx.body = JSON.stringify({code:0,data:list});
        } else {
            ctx.body = JSON.stringify({code:2,message:'token过期'});
        }
    }catch (e) {
        ctx.body = JSON.stringify({code:1,error:e});
    }
};

const createApp = async function (ctx) {
    const header = {
        token:ctx.request.headers.token
    };
    const post = {
        bundleIdentifier: ctx.request.body.bundleIdentifier,
        platform: ctx.request.body.platform,
        icon:ctx.request.body.icon
    };
    try {
        const payload = await jsonToken.verify(header.token);
        if (jsonToken.isExpire(payload.iat)){
            const userId = payload.userId;
            const [userApplication,created] = orm.userApplication.findOrCreate({where:{userId:userId,bundleIdentifier:post.bundleIdentifier,platform:post.platform},
                defaults:{userId:userId,bundleIdentifier:post.bundleIdentifier,platform:post.platform}});
            //这里可以修改信息的
            userApplication.icon = post.icon;
            userApplication.save();
            ctx.body = JSON.stringify({code:0,message:'成功'});
        } else {
            ctx.body = JSON.stringify({code:2,message:'token过期'});
        }
    }catch (e) {
        ctx.body = JSON.stringify({code:1,error:e});
    }
};

const updateApplication = async function (ctx) {
    const header = {
        token:ctx.request.headers.token
    };
    const post = {
        bundleIdentifier: ctx.request.body.bundleIdentifier,
        platform: ctx.request.body.platform,
        icon:ctx.request.body.icon
    };
    try {
        const payload = await jsonToken.verify(header.token);
        if (jsonToken.isExpire(payload.iat)){
            const userId = payload.userId;
            const userApplication = await orm.userApplication.findOne({where:{userId:userId,bundleIdentifier:post.bundleIdentifier,platform:post.platform}});
            //这里可以修改信息的
            if (userApplication) {
                if (post.icon) {
                    userApplication.icon = post.icon;
                }
                userApplication.save();
                ctx.body = JSON.stringify({code: 0, message: '成功'});
            }else {
                ctx.body = JSON.stringify({code:3,message:'应用不存在'});
            }
        } else {
            ctx.body = JSON.stringify({code:2,message:'token过期'});
        }
    }catch (e) {
        ctx.body = JSON.stringify({code:1,error:e});
    }
};

const deleteUserApplication = async function (ctx) {
    //删除应用 和应用相关的内容 此处做真实删除  如果有必要后期添加历史数据库
    const header = {
        token:ctx.request.headers.token
    };
    const post = {
        bundleIdentifier: ctx.request.body.bundleIdentifier,
        platform: ctx.request.body.platform
    };
    try {
        const payload = await jsonToken.verify(header.token);
        if (jsonToken.isExpire(payload.iat)){
            const userId = payload.userId;

            let del = await orm.userApplication.delete({where:{userId:userId,bundleIdentifier:post.bundleIdentifier,platform:post.platform}});
            if (del){
                ctx.body = JSON.stringify({code: 0, message: '成功'});
            } else {
                ctx.body = JSON.stringify({code:3,message:'删除失败'});
            }
        } else {
            ctx.body = JSON.stringify({code:2,message:'token过期'});
        }
    }catch (e) {
        ctx.body = JSON.stringify({code:1,error:e});
    }
};

module.exports = {
    userApplicationList,
    createApp,
    updateApplication
};