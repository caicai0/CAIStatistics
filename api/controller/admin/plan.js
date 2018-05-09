const orm = require('../../orm/models/index');
const jsonToken = require('../../service/jsonToken');

const create = async function (ctx) {
    const header = {
        token:ctx.request.headers.token
    };
    const post = {
        userApplicationId:ctx.request.body.userApplicationId,
        name:ctx.request.body.name,
        type:ctx.request.body.type,
        classPath:ctx.request.body.classPath,
        functionName:ctx.request.body.functionName,
        values:ctx.request.body.values
    };
    try {
        const payload = await jsonToken.verify(header.token);
        if (jsonToken.isExpire(payload.iat)){
            if (post.userApplicationId && post.name && post.classPath && post.functionName && post.keyPath) {
                let [baseInfo,created] = await orm.baseInfo.findOrCreate({
                    where:{
                        userApplicationId:post.userApplicationId,
                        name:post.name,
                        classPath:post.classPath,
                        functionName:post.functionName
                    },
                    defaults:{
                        userApplicationId:post.userApplicationId,
                        name:post.name,
                        classPath:post.classPath,
                        functionName:post.functionName,
                        keyPath:post.keyPath
                    }
                });
                if (created) {
                    ctx.body = JSON.stringify({code:0,message:'成功'});
                }else {
                    ctx.body = JSON.stringify({code:4,message:'计划已经存在'});
                }
            } else {
                ctx.body = JSON.stringify({code:3,message:'参数错误'});
            }
        } else {
            ctx.body = JSON.stringify({code:2,message:'token过期'});
        }
    }catch (e) {
        ctx.body = JSON.stringify({code:1,error:e});
    }
};

const del = async function (ctx) {
    const header = {
        token:ctx.request.headers.token
    };
    const post = {
        planId:ctx.request.body.planId
    };
    try {
        const payload = await jsonToken.verify(header.token);
        if (jsonToken.isExpire(payload.iat)){
            if (post.planId){
                await orm.plan.delete({
                    where:{
                        id:post.planId
                    }
                });
                ctx.body = JSON.stringify({code:0,message:'成功'});
            } else {
                ctx.body = JSON.stringify({code:3,message:'参数错误'});
            }
        } else {
            ctx.body = JSON.stringify({code:2,message:'token过期'});
        }
    }catch (e) {
        ctx.body = JSON.stringify({code:1,error:e});
    }
};

const update = async function (ctx) {
    const header = {
        token:ctx.request.headers.token
    };
    const post = {
        planId:ctx.request.body.planId,
        type:ctx.request.body.type,
        classPath:ctx.request.body.classPath,
        functionName:ctx.request.body.functionName,
        values:ctx.request.body.values
    };
    try {
        const payload = await jsonToken.verify(header.token);
        if (jsonToken.isExpire(payload.iat)){
            if (post.planId){
                let plan = await orm.plan.findOne({
                    where:{
                        id:post.planId
                    }
                });
                if (plan) {
                    if (post.type) {
                        plan.type = post.type;
                    }
                    if (post.classPath) {
                        plan.classPath = post.classPath;
                    }
                    if (post.functionName) {
                        plan.functionName = post.functionName;
                    }
                    if (post.values) {
                        plan.values = post.values;
                    }
                    plan.save();
                    ctx.body = JSON.stringify({code:0,message:'成功'});
                }else {
                    ctx.body = JSON.stringify({code: 4, message: '计划不存在'});
                }
            } else {
                ctx.body = JSON.stringify({code:3,message:'参数错误'});
            }
        } else {
            ctx.body = JSON.stringify({code:2,message:'token过期'});
        }
    }catch (e) {
        ctx.body = JSON.stringify({code:1,error:e});
    }
};

const list = async function (ctx) {
    const header = {
        token:ctx.request.headers.token
    };
    const post = {
        userApplicationId:ctx.request.body.userApplicationId,
        page:ctx.request.body.page,
        size:ctx.request.body.size
    };
    try {
        const payload = await jsonToken.verify(header.token);
        if (jsonToken.isExpire(payload.iat)){
            if (post.userApplicationId) {
                if (!post.page) {
                    post.page = 0;
                }
                if (!post.size) {
                    post.size = 20;
                }
                const list = await orm.plan.find({where:{userApplicationId:post.userApplicationId},offset:post.page*post.size,limit:post.size});
                ctx.body = JSON.stringify({code:0,data:list});
            }else {
                ctx.body = JSON.stringify({code:3,message:'参数错误'});
            }
        } else {
            ctx.body = JSON.stringify({code:2,message:'token过期'});
        }
    }catch (e) {
        ctx.body = JSON.stringify({code:1,error:e});
    }
};

module.exports = {
    create,
    del,
    update,
    list
};