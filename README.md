# Replace_for_Batch
### Copyright(c) 2019 yyfll (yanyifei66@gmail.com)
### 本模块旨在为Batch用户提供稳定、便利、正确的字符替换方式

使用方法
=
您可以把该模块直接塞进您的BAT中

然后使用内部挂载的方式

	Call :Module_ReplaceBatch "输入字符串" "被替换字符(单字符)" "替换为(字符串或留空)"
	
当然您也可以使用外部挂载的方式

	Call "Replace.bat" "输入字符串" "被替换字符(单字符)" "替换为(字符串或留空)"
	
本模块的结果会输出到

	"%USERPROFILE%\rforbat.log"
您可以使用以下指令来获取结果

	for /f "usebackq tokens=*" %%x in ("%USERPROFILE%\rforbat.log") do set "变量名=%%x"
	[根据for的语法，x可以为任意字母(如%%a、%%b...)]
  
最新版本
=
> Replace for Batch V4F [200118]

	重新编写主要算法，该新算法的改进包括：
    不使用变量延迟（兼容半角感叹号）
    修复了旧叠加搜索对连续字符串不兼容的问题
    
> Replace for Batch V3F2 [200118]

    算法优化，可以定义Step来进行快速搜索
	修复带半角感叹号(!)文本替换后感叹号消失的问题
	现已不需要使用变量扩展
	
更新记录
=
> Replace for Batch V1[190218]

	初步搭建基本架构
	支持字符不重复的字符串进行正确的字符替换

> Replace for Batch V2[190218]

	添加插入符，利用插入符分割重复字符达到正确替换的目的
 
> Replace for Batch V2+[190218]

	添加检测，输入字符串没有要替换字符时直接退出
	
> Replace for Batch V3[190221]

	更换替换方式，加快替换速度减少等待
	取消插入符，大幅简化处理过程

> Replace for Batch V4[190322]
	
	支持把字符串替换成字符串
	
> Replace for Batch V4+[190323]
	
	算法简化
	支持调用旧式搜索
	
> Replace for Batch V4-Mini[190529]

	删除无用内容后的V4标准版本

开发者
=
本模块使用的变量有以下名称及作用

	input_string 		输入字符串
	for_delims 		被替换字符
	replace_to 		替换为
	output_string 		输出字符串
	insert_collect 		插入符集
	insert_count		循环控制变量(请勿更改!)
	RB_cache 		缓存插入字符后的字符串
	RB_cache[NUM] 		(数组)缓存插入字符后的字符串
	insert_string 		插入插入符后的输入字符串
	no_insert_string 	缓存删除插入符后的字符串

已删除内容
=
## V2+
	输入字符串中必须不包含"@#$~`;'[]{}_,?\/"中的任意一个字符，否则会报错
	您也可以手动修改"insert_collect"变量来变更输入限制
	("insert_collect"变量中包含的字符必须有一个不在输入字符串中出现)
