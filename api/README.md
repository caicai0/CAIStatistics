# CAIStatistics
API

1. /statistic/report 上报接口
	1. 内容格式 JSON
	2. HTTP请求方式  POST
	3. 参数
		1. version 计划版本
		2. appkey app分配的key
		3. deviceId 设备唯一编号
		4. deviceInfo 设备信息
			1. name 平台
			2. deviceModel 硬件描述
			2. os_version 系统版本
			3. bundelVersion appbuild版本
			3. language 系统语言
			4. resolution 分辨率
			5. lib_version 库版本
		5. logs 数组
			1. planId 计划Id 
			2. values 数组内部类型字符串 （日志型）
			3. number 事件出现的次数 （计数型）
	4. 返回结果
    	1. code 0 
    	2. version plist版本号  有必要更新时才有
2. /download 下载xml
	1. 内容格式  JSON
	2. 方式  POST
	3. 参数
         1. version 本地版本
   4. 返回结果
   		1. code 0  
   		2. plist 文件内容  如果本地版本号比较老才会有此字段
