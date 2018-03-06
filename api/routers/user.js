
var router = require('koa-router')();
var userModel = require('../lib/mysql.js');
var md5 = require('md5')
var checkNotLogin = require('../middlewares/check.js').checkNotLogin
var checkLogin = require('../middlewares/check.js').checkLogin

router.post('/user/register', async(ctx, next) => {
    console.log(ctx.request.body)
    var user = {
        name: ctx.request.body.name,
        pass: ctx.request.body.password,
        repeatpass: ctx.request.body.repeatpass
    }
    await userModel.findDataByName(user.name)
        .then(result => {
            console.log(result)
            if (result.length) {
                throw Error('用户已经存在')
            } else if (user.pass !== user.repeatpass || user.pass == '') {
                throw Error('密码错误')
            } else {
                console.log('注册成功')
                    // ctx.session.user=ctx.request.body.name				
                userModel.insertData([ctx.request.body.name, md5(ctx.request.body.password)])
            }
        })
})

module.exports = router