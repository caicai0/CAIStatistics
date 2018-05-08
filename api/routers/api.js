const router = require('koa-router')();
const admin = require('./admin');
const app = require('./app');

router.use('/admin',admin());
router.use('/app',app());

module.exports = router;