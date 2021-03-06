const orm = require('../../orm/models/index');
const jsonToken = require('../../service/jsonToken');

let create = async function (ctx) {
    const header = {
        token:ctx.request.headers.token
    };
    const post = {
        userApplicationId:ctx.request.body.userApplicationId,
        name:ctx.request.body.name,
        classPath:ctx.request.body.classPath,
        functionName:ctx.request.body.functionName,
        keyPath:ctx.request.body.keyPath
    };
    try {
        const payload = await jsonToken.verify(header.token);
        if (jsonToken.isExpire(payload.iat)){
            if (post.userApplicationId && post.name && post.classPath && post.functionName && post.keyPath) {
                let [baseInfo,created] = await orm.baseInfo.findOrCreate({
                    where:{
                        userApplicationId:post.userApplicationId,
                        name:post.name
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
                } else {
                    ctx.body = JSON.stringify({code: 4, message: '此项已经存在'});
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

let del = async function (ctx) {
    const header = {
        token:ctx.request.headers.token
    };
    const post = {
        baseInfoId:ctx.request.body.baseInfoId
    };
    try {
        const payload = await jsonToken.verify(header.token);
        if (jsonToken.isExpire(payload.iat)){
            if (post.baseInfoId) {
                await orm.baseInfo.delete({where:{id:post.baseInfoId}});
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

let update = async function (ctx) {
    const header = {
        token:ctx.request.headers.token
    };
    const post = {
        baseInfoId:ctx.request.body.baseInfoId,
        classPath:ctx.request.body.classPath,
        functionName:ctx.request.body.functionName,
        keyPath:ctx.request.body.keyPath
    };
    try {
        const payload = await jsonToken.verify(header.token);
        if (jsonToken.isExpire(payload.iat)){
            if (post.baseInfoId) {
                let baseInfo = await  orm.baseInfo.findOne({
                    where:{
                        id:post.baseInfoId
                    }
                });
                baseInfo.classPath = post.classPath;
                baseInfo.functionName = post.functionName;
                baseInfo.keyPath = post.keyPath;
                baseInfo.save();
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

let list = async function (ctx) {
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
                const list = await orm.userApplication.find({where:{userId:payload.userId},offset:post.page*post.size,limit:post.size});
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
