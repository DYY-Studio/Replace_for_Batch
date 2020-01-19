:Module_ReplaceBatch
if "%~1"=="" (
	goto RB.error_input
) else if "%~2"=="" (
	goto RB.error_input
)
set "input_string=%~1"
if "%input_string:~0,1%"=="" (
	echo [ERROR] ��û�������κ��ַ���
	goto RB.error_input
)
set "for_delims=%~2"
if "%for_delims%"=="" (
	echo [ERROR] ��û�������κ�Ҫ�滻���ַ���
	goto RB.error_input
)
if not "%for_delims:~1%"=="" (
	echo [ERROR] Replace��������ǵ����ַ�
	goto RB.error_input
)
for /f "tokens=1* delims=%for_delims%" %%a in ("%input_string%") do (
	if "%%~a%%~b"=="%input_string%" (
		echo "%input_string:~1,-1%">"%USERPROFILE%\rforbat.log"
		goto RB.end_clear
	)
)
set "replace_to=%~3"

set "search_step=5"
set "output_string="

set "work_string=%input_string%"
:RB.re_replace
set "RB_cache="
set "RB_need_replace="

if not defined work_string goto :RB.replace_finish
for /l %%a in (1,1,%search_step%) do call :RB.get_string
goto RB.get_string_end
:RB.get_string
if not defined work_string if not defined RB_need_replace goto :EOF
set "RB_cache=%RB_cache%%work_string:~0,1%"
if "%work_string:~0,1%"=="%for_delims%" set "RB_need_replace=0"
set "work_string=%work_string:~1%"
goto :EOF
:RB.get_string_end

if "%RB_cache%"=="" goto RB.replace_finish

if not defined RB_need_replace (
	set "output_string=%output_string%%RB_cache%"
	goto RB.re_replace
)

set "RB_working=%RB_cache%"
set "RB_cache2=%RB_working%"
:RB.re_replace2
if not defined RB_working goto RB.re_replace
set "RB_cache2=%RB_working:~0,1%"
if "%RB_cache2%"=="" goto RB.re_replace

if "%RB_cache2%"=="%for_delims%" (
	set "output_string=%output_string%%replace_to%"
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
echo [ERROR] ������Ч
pause
goto RB.end_clear