const jwt = require('jsonwebtoken');
const fs = require('fs');

const cert = fs.readFileSync(__dirname+'/rsa_private_key.pem');
const pubCert = fs.readFileSync(__dirname+'/rsa_public_key.pem');

async function sign(object) {
    const token = jwt.sign(object,cert,{algorithm:'RS256'});
    return token;
}

async function verify(token) {
    return new Promise(function (resolve, reject) {
        jwt.verify(token,pubCert,{algorithms:['RS256']},function (err,payload){
            if (err) {
                reject(err);
            }else {
                resolve(payload);
            }
        });
    });
}

function isExpire(iat){
    const now = new Date().getTime();
    if (now - iat < 60*60){
        return true;
    } else {
        return false;
    }
}

module.exports = {
    sign,
    verify,
    isExpire
};