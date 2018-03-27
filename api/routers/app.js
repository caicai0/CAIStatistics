
const router = require('koa-router')();
const config = require('../config/config');
const fs = require('fs');

router.post('/app/download', async(ctx, next) => {
    const header = {
        model:ctx.request.headers.model,
        systemVersion:ctx.request.headers.systemversion,
        CFBundleIdentifier:ctx.request.headers.cfbundleidentifier,
        CFBundleName:ctx.request.headers.cfbundlename,
        CFBundleShortVersionString:ctx.request.headers.cfbundleshortversionstring,
        CFBundleVersion:ctx.request.headers.cfbundleversion
    };
    const post = {
        version: ctx.request.body.version
    };
    console.log(header,post);
    const plist = fs.readFileSync(__dirname+'/../public/Statistic.plist','utf8');
    console.log(plist);
    ctx.body = JSON.stringify({code:0,plist:plist});
});

module.exports = router;