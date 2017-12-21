#  开放统计
1. 统计计划文件标准
	1. version:统计文件版本号
	2. plans:统计计划 类型数组
	3. 计划内容dict类型
	4. plantId:计划ID
	4. type:数值型 0.日志类统计（可以有values） 1.计数类统计（即使有values也无效）
	5. classPath:类路径（OC 就是类名  Java 就是包名.类名）
	6. selector:方法名称
	7. values:数组类型 统计上报内容（不包括计数类统计）内容为字符型 0.instance 1.第一个参数 以此类推。 后面可以跟keypath  比如“0.name.at” [[instance valueforkey:@“name”]valueForKey:@"at"];
2. 统计结果文件标准
	1. 日志类统计 时间戳 plantId [values]
	2. 计数统计 统计开始截止时间戳 统计结果 。统计结果：plantId：次数
