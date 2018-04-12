var plist = require('plist');
var fs = require('fs');

const str = fs.readFileSync(__dirname+'/public/Statistic.plist','utf8');
var obj = plist.parse(str);
var pli = plist.build(obj);
console.log(obj);
console.log(pli);
