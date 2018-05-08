
const router = require('koa-router')();
const user = require('../api/admin/user');

router.post('/user/register', user.regist);

router.get('/user/verification', user.verification);

router.post('/user/login', user.login);

module.exports = router;