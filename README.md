# Replace_for_Batch
### Copyright(c) 2019-2020 yyfll (yanyifei66@gmail.com)
### 本模块旨在为Batch用户提供稳定、便利、正确的字符替换方式

告知
=
在新版Windows 10 中，变量扩展已更新支持原生Replace方法，使用方法如下

	%a:str1=str2%

该变量`%a%`中的`str1`就会被替换为`str2`，并且速度很快，同时兼容与号

我很高兴能够维护Replace_for_Batch至今，该项目至此结束，谢谢

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
	
开发者
=
本模块使用的变量有以下名称及作用（仅V3及更早版本）

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
	
## 基础算法介绍
本模块从V1到现在V4Fix一共使用了3种不同的算法，在该处将会逐个介绍

1. 直接切割 ( V1 / V1_BS / V2 / V2+ )

		本模块最早的一个算法，直接利用CMD for指令的f开关中选项"delims"进行字符串的切割
		切割后在切开的字符串中间插入要替换的字符，完美结局
		V1完成后，测试中发现该方式并不能处理被替换字符连续出现的情况，于是就有了V2+中的插入符插补来防止切错的情况
		但是插入符的加入和删除使本模块效率极低，于是该算法被抛弃
		后来开发要JSON转义路径的时候，就想到路径不会是连续反斜杠，于是这玩意又用上了
		
2. 逐字搜索 ( V3 / V3F / V3F2 )

		本模块的第二个算法，其实很简单，就是利用CMD字符串切割(%x:~0,1%)来逐个搜索被替换字符
		找到被替换字符就往输出变量尾部追加一个替换成的字符，没找到就原样追加
		效率不是很高（起码比带插入符的直接切割法快），但是准确度特高
		
3. 叠加搜索 ( V4(M) / V4+ ) / 后消式叠加搜索 ( V4F / V4F2 )

		将字符串按照被替换字符串长度逐个切割成一组一组的，每一组与上一组都有交叠
		然后在每一组中查找被替换字符串，找到了就和前面一样换掉
		通过这个，本模块实现了字符串替换这个最早开发就在梦寐以求的功能
		但是后来发现，对于连续字符串还是没办法，于是凑合着用了一年
		
		考虑到说得不是很清楚，打算用简单示范来讲清楚
		我有一个字符串“123456789”，我现在想把45换成00
		组切割：[12] [23] [34] [45] [56] [67] [78] [89]
		位置记录：[0,2] [1,3] [2,4] [3,5] [4,6] ...
		组匹配：[12] <> 45
		输出字符串：[:~0,2][:~2]
		以此类推
		组匹配：[45] == 45
		输出字符串：[:~0,3]00[:~5]
		基本上就是这样一个过程
		
		而V4F和V4F2中，匹配成功后在该字段开始位置后的(被替换字符串长度-1)个组就会被移除
		这样就避免了因为重复匹配重叠部分而导致的错误

## 已删除内容
### V2+
	输入字符串中必须不包含"@#$~`;'[]{}_,?\/"中的任意一个字符，否则会报错
	您也可以手动修改"insert_collect"变量来变更输入限制
	("insert_collect"变量中包含的字符必须有一个不在输入字符串中出现)

最终决定版本
=
### Replace for Batch V4F3 UTF8

	我也不记得修正了什么了
	
### Replace for Batch V4F3-2a UTF8

	修复了对于长字符串无法完成尾部替换的问题
	V4F3-2的可选版本a，不对尾部做任何处理
	
### Replace for Batch V4F3-2d UTF8

	修复了对于长字符串无法完成尾部替换的问题
	V4F3-2的可选版本d，会跳过尾部无意义部分替换
  
FIX版本
=
> Replace for Batch V4F2_F [200307]

	与RenameFiles同时更新，修复了因IF无法比较"26"和"027"谁大而导致Replace无法处理最后一个字符

> Replace for Batch V4F2 [200123]

	本版本是效率更新，基本算法与V4F相同
	通过删减一部分不必要多余操作，V4F2较V4F提速超过300%

> Replace for Batch V4F [200118]

	重新编写主要算法，该新算法的改进包括：
    不使用变量延迟（兼容半角感叹号）
    修复了旧叠加搜索对连续字符串不兼容的问题
    
> Replace for Batch V3F2 [200118]

    算法优化，可以定义Step来进行快速搜索
	修复带半角感叹号(!)文本替换后感叹号消失的问题
	现已不需要使用变量扩展
	
特殊专用版本
=
> Replace V1_BS

	基于V1版本的、用于为JSON输出进行本地路径反斜杠转义的专用模块，效率极高
	应用在两个使用JSON输入的、依赖mkvmerge的批处理中

> Replace SP_3+4

	暂时只在RenameFiles里使用的混合模块，包括V4F2主程序和V3F2扩展
	对于少部分输入可以调用速度更快的V3F2进行处理，其实没什么用
	
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

题外话
=
### 为什么坚持用Batch写程序？还是些弱智东西？
	我认为Batch是一个大金蛋，为什么呢？
	Batch什么都没有，全都要靠自己创造，DEBUG也很难，最后搞出来还有可能是只有自己在用
	但是我觉得这很快乐，很有成就感，因为是从零开始写起的
	就是靠一个if，一个for，一个goto，一个call，一个set，基本上就能创造出你所想使用的函数
	并不是那些什么现成的，一行就能解决的东西，一个Replace有效的部分我写了起码100行
	
	其实除了这些，就是我太懒
	我也会VB，但是我不知道如何深入去学习，如何去做那些我想写的程序，于是停滞不前
	其他事情将我的生活塞得满满当当，我也没有时间去写一个好的VB程序
	“下次一定”
