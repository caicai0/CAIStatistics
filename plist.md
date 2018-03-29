#plist文件
1. version String 文件版本
2. baseInfo Dictionary 获取基本不变的信息 主要通过公共类比如NSBundle UIDevice 等获取基本信息
	1. key String 键名，上传结果时使用相同的键名
	2. value Dictionary 获取信息的关键信息 (下面的key 是指定值)
		1. class String 指定类名（NSBundle）
		2. selector String 指定方法名（mainBundle）
		3. keyPath String 指定键值编码路径（infoDictionary.CFBundleVersion）
3. plans Array<Dictionary> 所以得统计计划 （下面为每个item内键值说明）
	1. planId String 计划唯一标识
	2. type Number 统计类型  0日志  1计数
	3. classPath String 指定统计类名（TestClass）
	4. selector String 方法名（这里都是实例方法）（argFunction:）
	5. values Array<String> 当tyep==0时才有此参数。指定要获取的值，这里是键值编码路径，但是以数字n开头。如果n==0表示调用方法的实例，后面的代表方法传入的相应位置的参数。比如n==1 表示第一个参数。（1.title）