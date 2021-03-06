:Module_ReplaceBatch
if "%~1"=="" (
	goto RB.error_input
) else if "%~2"=="" (
	goto RB.error_input
)
set "input_string=%~1"
if "%input_string:~0,1%"=="" (
	echo [ERROR] 您没有输入任何字符！
	goto RB.error_input
)
set "for_delims=%~2"
if "%for_delims%"=="" (
	echo [ERROR] 您没有输入任何要替换的字符！
	goto RB.error_input
)
set "replace_to=%~3"
setlocal enabledelayedexpansion

set "RB_str_len=0"
:RB.delims_len
set "RB_len=!for_delims:~%RB_str_len%!"
if not "%RB_len%"=="" (
	set /a RB_str_len=RB_str_len+1
	goto RB.delims_len
) else set "delims_len=%RB_str_len%"

set "RB_str_len=0"
:RB.input_len
set "RB_inlen=!input_string:~%RB_str_len%!"
if not "%RB_inlen%"=="" (
	set /a RB_str_len=RB_str_len+1
	goto RB.input_len
) else set "input_len=%RB_str_len%"

set "RB_str_len=0"
if not defined replace_to (
	set "replace_len=0"
	goto RB.nocheck_re
)
:RB.replace_len
set "RB_relen=!replace_to:~%RB_str_len%!"
if not "%RB_relen%"=="" (
	set /a RB_str_len=RB_str_len+1
	goto RB.replace_len
) else set "replace_len=%RB_str_len%"

:RB.nocheck_re
set "RB_str_len="
if %input_len% LEQ %delims_len% (
	echo [ERROR] 输入字符串不能与替换字符串等长!
	goto RB.error_input
)

set "insert_collect=@#$~`;'[]{}_,?\/"
set "insert_count=-1"
:RB.choose_insert
set /a insert_count=insert_count+1
set "insert=!insert_collect:~%insert_count%,1!"
if "%insert%"=="" (
	echo [ERROR] 您的输入中包含本模块无法处理的字符
	goto RB.error_input
)
for /f "tokens=2 delims=%insert%" %%a in ("%input_string%") do (
	if "%%~a"=="" (
		goto RB.choose_finish
	) else goto RB.choose_insert
)
:RB.choose_finish

set /a gap=replace_len-delims_len
set "step=1"
if %gap% LEQ -1 (
	rem set /a stop=%gap:~1%+1
	rem 对于全重复字符串，此处改为
	rem set /a step=%gap:~1%+1
	rem set /a insert_count=0
	set "all_gap=0"
	:RB.insert_replace
	rem set /a insert_count=insert_count+1
	rem 对于全重复字符串，此处改为
	rem if "%insert_count%"=="%step%" goto RB.list_input
	rem if "%insert_count%"=="%stop%" goto RB.list_input
	rem set "replace_to=%replace_to%%insert%"
	rem goto RB.insert_replace
) else (
	set "all_gap=0"
)
:RB.list_input
set /a list_end=input_len-delims_len
set /a list_start=0
for /l %%a in (%list_start%,%step%,%list_end%) do (
	set "RB_List[%%a]=!input_string:~%%a,%delims_len%!"
	for /f "tokens=*" %%b in ('set /a %%a+%delims_len%') do (
		set "RB_range[%%a]=%%a,%%b"
	)
)
rem echo [%delims_len%]^|[%input_len%]^|[%replace_len%]
rem set RB_
rem pause

set /a loop=list_start-1
set /a loop_end=list_end+1
:RB.replace_start
set /a loop=loop+1 
if "%loop%"=="%loop_end%" goto RB.replace_end
set "replace=!RB_List[%loop%]!"
if not "%replace%"=="%for_delims%" goto RB.replace_start
for /f "tokens=1* delims==" %%a in ('set RB_range[%loop%]') do (
	for /f "tokens=1,2 delims=," %%c in ("%%~b") do (
		if not defined all_gap (
			set "range[0]=%%c"
			set "range[1]=%%d"
		) else (
			set /a range[0]=%%c+all_gap
			set /a range[1]=%%d+all_gap
			set /a all_gap=all_gap+gap
		)
	)
)
set "input_string=!input_string:~0,%range[0]%!%replace_to%!input_string:~%range[1]%!"
goto RB.replace_start
:RB.replace_end
if defined all_gap (
	set "all_gap="
	set "output_string=%input_string%"
	goto RB.replace_finish
)
set "output_string="
set "loop=-1"
:RB.remove_insert
set /a loop=loop+1
set "RB_cache=!input_string:~%loop%,1!"
if "%RB_cache%"=="" goto RB.replace_finish
if "%RB_cache%"=="%insert%" (
	set "output_string=%output_string%"
) else set "output_string=%output_string%%RB_cache%"
goto RB.remove_insert
:RB.replace_finish
echo "%output_string%">"%USERPROFILE%\rforbat.log"
:RB.end_clear
setlocal disabledelayedexpansion
set "RB_cache="
rem echo %input_string%[%gap%]
rem echo %output_string%
set "input_string="
set "output_string="
set "for_delims="
set "loop="
goto :EOF
:RB.error_input
echo [ERROR] 输入无效
pause
goto RB.end_clear