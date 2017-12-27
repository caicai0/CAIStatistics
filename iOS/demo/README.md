#  开放统计
1. 统计计划文件标准
	1. version:统计文件版本号
	2. baseInfo:基本信息
		2. device: 设备信息 字典 key上报使用 value 限制在UIDevice属性（ios）
		3. app: app基本信息 字典 key上报使用 value [[NSBundle mainBundle]infoDictionary] 中需要的内容 支持keypath
	2. plans:统计计划 类型数组
		1. plantId:计划ID
		2. type:数值型 0.日志类统计（可以有values） 1.计数类统计（即使有values也无效）
		3. classPath:类路径（OC 就是类名  Java 就是包名.类名）
		4. selector:方法名称
		5. values:数组类型 统计上报内容（不包括计数类统计）内容为字符型 0.instance 1.第一个参数 以此类推。 后面可以跟keypath  比如“0.name.at” [[instance valueforkey:@“name”]valueForKey:@"at"];
2. 统计手段 
	1. String keyPath
	2. dict   global
		1. class 
		2. selector 类方法
		3. keyPath 可选
2. 统计结果文件标准
	1. 日志类统计 时间戳 plantId [values]
	2. 计数统计 统计开始截止时间戳 统计结果 。统计结果：plantId：次数
