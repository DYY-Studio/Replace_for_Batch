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
if not "%for_delims:~1%"=="" (
	echo [ERROR] Replace对象必须是单个字符
	goto RB.error_input
)
for /f "tokens=1* delims=%for_delims%" %%a in ("%input_string%") do (
	if "%%~a%%~b"=="%input_string%" (
		echo "%input_string:~1,-1%">"%USERPROFILE%\rforbat.log"
		goto RB.end_clear
	)
)
set "replace_to=%~3"

set "insert_collect=@#$~`;:'[]{}_,?\/."
set "working_insert=%insert_collect%"
:RB.choose_insert
set "insert=%working_insert:~0,1%"
if "%insert%"=="" (
	echo [ERROR] 您的输入中包含本模块无法处理的字符
	goto RB.error_input
)
for /f "tokens=2 delims=%insert%" %%a in ("%input_string%") do (
	if "%%~a"=="" (
		goto RB.choose_finish
	) else (
		set "working_insert=%working_insert:~1%"
		goto RB.choose_insert
	)
)
:RB.choose_finish


set "search_step=10"
set "output_string="
set "loop=-%search_step%"
:RB.re_replace
set "has_insert="
set /a loop=loop+%search_step%
setlocal EnableDelayedExpansion
set "RB_cache=!input_string:~%loop%,%search_step%!"
setlocal DisableDelayedExpansion

if "%RB_cache%"=="" goto RB.replace_finish

for /f "tokens=1,2 delims=%for_delims%" %%a in ("%insert%%RB_cache%%insert%") do (
	if "%%~b"=="" (
		for /f "tokens=1,2 delims=%insert%" %%c in ("^|%RB_cache%^|") do (
			if "%%~d"=="" (
				set "output_string=%output_string%%RB_cache%"
				goto RB.re_replace
			) else set "has_insert=0"
		)
	)
)

set /a subloop=loop-%search_step%

set "RB_working=%RB_cache%"
set "RB_cache2=%RB_working%"
:RB.re_replace2
if not defined RB_working goto RB.re_replace
set "RB_cache2=%RB_working:~0,1%"
if "%RB_cache2%"=="" goto RB.re_replace

if "%RB_cache2%"=="%for_delims%" (
	set "output_string=%output_string%%replace_to%"
) else if defined has_insert if "%RB_cache2%"=="%insert%" (
	set "output_string=%output_string%%insert%"
) else set "output_string=%output_string%%RB_cache2%"

set "RB_working=%RB_working:~1%"

goto RB.re_replace2
:RB.replace_finish
echo "%output_string%">"%USERPROFILE%\rforbat.log"
:RB.end_clear
setlocal DisableDelayedExpansion
set "RB_cache="
set "input_string="
set "output_string="
set "for_delims="
set "loop="
goto :EOF
:RB.error_input
echo [ERROR] 输入无效
pause
goto RB.end_clear