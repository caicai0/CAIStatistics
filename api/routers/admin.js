
const router = require('koa-router')();
const user = require('../controller/admin/user');

router.post('/user/register', user.register);

router.get('/user/verification', user.verification);

router.post('/user/login', user.login);

module.exports = router;