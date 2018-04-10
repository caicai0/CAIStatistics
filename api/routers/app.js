
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
    let [device,createdd] = await orm.device.findOrCreate({where:{model:header.model,openUDID:header.openUDID,UUID:header.UUID},
        defaults:{model:header.model,openUDID:header.openUDID,UUID:header.UUID,systemVersion:header.systemVersion}});
    let [application,createda] = await  orm.application.findOrCreate({where:{deviceId:device.id,bundleIdentifier:header.CFBundleIdentifier},
        defaults:{deviceId:device.id,bundleIdentifier:header.CFBundleIdentifier}});

    if (post.version == plist.version){
        ctx.body = JSON.stringify({code:0});
    } else {
        const plist = fs.readFileSync(__dirname+'/../public/Statistic.plist','utf8');
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
    ctx.body = JSON.stringify({code:0});
});

module.exports = router;