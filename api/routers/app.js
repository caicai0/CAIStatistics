
const router = require('koa-router')();
const config = require('../config/config');
const fs = require('fs');
const orm = require('../orm/models');

router.post('/app/download', async(ctx, next) => {
    const header = {
        model:ctx.request.headers.model,
        openUDID:ctx.request.headers.openudid,
        UUID:ctx.request.headers.uuid,
        systemVersion:ctx.request.headers.systemversion,
        CFBundleIdentifier:ctx.request.headers.cfbundleidentifier
    };
    const post = {
        version: ctx.request.body.version
    };
    console.log(header,post);

    //检查本地是否有此手机的记录
    try {
        let [device,createdd] = await orm.device.findOrCreate({where:{model:header.model,openUDID:header.openUDID},
            defaults:{model:header.model,openUDID:header.openUDID,systemVersion:header.systemVersion}});
        let [application,createda] = await  orm.application.findOrCreate({where:{deviceId:device.id,UUID:header.UUID,bundleIdentifier:header.CFBundleIdentifier},
            defaults:{deviceId:device.id,UUID:header.UUID,bundleIdentifier:header.CFBundleIdentifier}});
    }catch (e)  {
        console.log(e);
    }

    const plist = fs.readFileSync(__dirname+'/../public/Statistic.plist','utf8');
    if (post.version == plist.version){
        ctx.body = JSON.stringify({code:0});
    } else {
        ctx.body = JSON.stringify({code:0,plist:plist});
    }
});

router.post('/app/report', async(ctx, next) => {
    const header = {
        model:ctx.request.headers.model,
        openUDID:ctx.request.headers.openudid,
        UUID:ctx.request.headers.uuid,
        systemVersion:ctx.request.headers.systemversion,
        CFBundleIdentifier:ctx.request.headers.cfbundleidentifier,
    };
    const post = ctx.request.body;
    console.log(header,ctx.request.body.logs);
    for (let plan in post.logs){
        if (plan.planId === "plan_deviceToken"){
            if (plan.values && plan.values.length) {
                const deviceToken = plan.values[0];
                console.log(deviceToken);
                try {
                    let [device,createdd] = await orm.device.findOrCreate({where:{model:header.model,openUDID:header.openUDID},
                        defaults:{model:header.model,openUDID:header.openUDID,systemVersion:header.systemVersion}});
                    let [application,createda] = await  orm.application.findOrCreate({where:{deviceId:device.id,UUID:header.UUID,bundleIdentifier:header.CFBundleIdentifier},
                        defaults:{deviceId:device.id,UUID:header.UUID,bundleIdentifier:header.CFBundleIdentifier}});
                    if (application){
                        application.deviceToken = deviceToken;
                        await application.save();
                    }
                }catch (e)  {
                    console.log(e);
                }
            }
        } 
    } 
    ctx.body = JSON.stringify({code:0});
});

module.exports = router;