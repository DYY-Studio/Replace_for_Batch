@echo on
:Module_ReplaceBatch
if "%~1"=="" (
	goto RB.error_input
) else if "%~2"=="" (
	goto RB.error_input
)
set "input_string=A%~1A"
set "for_delims=%~2"
setlocal enabledelayedexpansion
for /l %%a in (0,1,1) do set "delims[%%a]=!for_delims:~%%a!"
if defined delims[1] (
	echo [ERROR] Replace对象必须是单个字符
	goto RB.error_input
)
for /f "tokens=1* delims=%for_delims%" %%a in ("%input_string%") do (
	if "%%~b"=="" (
		echo "%input_string:~1,-1%">"%USERPROFILE%\rforbat.log"
		set "input_string="
		set "for_delims="
		goto :EOF
	)
)
set "replace_to=%~3"
set "output_string="
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
set "insert_count=-1"
:RB.insert_char
set /a insert_count=insert_count+1
set "RB_cache=!input_string:~%insert_count%,1!"
if not "%RB_cache%"=="" (
	set "RB_cache[%insert_count%]=%RB_cache%%insert%"
	goto RB.insert_char
)
set insert_count=0
:RB.format_insert
if not defined RB_cache[%insert_count%] (
	set "input_string=%insert_string%"
	goto RB.insert_finish
)
set "insert_string=%insert_string%!RB_cache[%insert_count%]!"
set "RB_cache[%insert_count%]="
set /a insert_count=insert_count+1
goto RB.format_insert
:RB.insert_finish

for /f "tokens=1 delims=%~2" %%a in ("%input_string%") do if not "%%a"=="" (
	set "output_string=%%a"
)
set "loop=1"
:RB.re_replace
set /a loop=loop+1
for /f "tokens=%loop% delims=%~2" %%a in ("%input_string%") do if not "%%a"=="" (
	set "output_string=%output_string%%replace_to%%%a"
	goto RB.re_replace
)
for /f "tokens=1 delims=%insert%" %%a in ("%output_string%") do if not "%%a"=="" (
	set "no_insert_string=%%a"
)
set "loop=1"
:RB.remove_insert
set /a loop=loop+1
for /f "tokens=%loop% delims=%insert%" %%a in ("%output_string%") do if not "%%a"=="" (
	set "no_insert_string=%no_insert_string%%%a"
	goto RB.remove_insert
)
echo "%no_insert_string:~1,-1%">"%USERPROFILE%\rforbat.log"
set "insert_string="
set "RB_cache="
set "no_insert_string="
set "input_string="
set "output_string="
set "loop="
setlocal disabledelayedexpansion
goto :EOF
:RB.error_input
echo [ERROR] 输入无效
setlocal disabledelayedexpansion
pause
goto :EOF