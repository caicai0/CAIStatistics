
let nodeMailer = require('nodemailer');

let transporter = nodeMailer.createTransport({
    host:'smtp.exmail.qq.com',
    port: 465,
    secureConnection: true,
    auth: {
        user: 'liyufeng@hmkx.cn',
        pass: 'flygirl791008'
    }
});

module.exports = async function (toEmail,subject,content) {
    let mailOptions = {
        from: 'liyufeng@hmkx.cn',
        to: toEmail,
        subject: subject,
        text:content
    };
    return new Promise(function (resolve, reject) {
        transporter.sendMail(mailOptions,function (err) {
            if(err){
                reject(err);
            }else {
                resolve();
            }
        });
    });
};