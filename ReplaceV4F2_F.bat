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
set "replace_to=%~3"

setlocal enabledelayedexpansion

:RB.delims_len
call :RB.long_string "%for_delims%" "delims_len"

:RB.input_len
call :RB.long_string "%input_string%" "input_len"

if not defined replace_to (
	set "replace_len=0"
	goto RB.nocheck_re
)
:RB.replace_len
call :RB.long_string "%replace_to%" "replace_len"

:RB.nocheck_re
if %input_len% LSS %delims_len% (
	echo [ERROR] �����ַ������ܱȱ��滻�ַ�����!
	goto RB.error_input
)
setlocal disabledelayedexpansion

set "work_string=%input_string%"
set "work_string2=%work_string%"
:RB.list_input
set "RB_list_cache="
set "list_start=0"

for /l %%a in (1,1,%input_len%) do (
	for /l %%b in (1,1,%delims_len%) do (
		call :RB.list_input_get
		if "%%~b"=="%delims_len%" call :RB.list_add "%%~a"
	)
	call :RB.add_work_string
)
goto RB.replace_finish

:RB.list_input_get
if not defined work_string2 goto :EOF
set "RB_list_cache=%RB_list_cache%%work_string2:~0,1%"
set "work_string2=%work_string2:~1%"
goto :EOF
:RB.list_add
if not defined RB_list_cache goto :EOF

if defined RB_next (
	if 0%~1 GEQ 0%RB_next% (
		set "RB_next="
	)
) else (
	if "%RB_list_cache%"=="%for_delims%" (
		set "output_string=%output_string%%replace_to%"
		set "RB_list_cache="
		set /a RB_next=%~1+delims_len-1
	) else (
		if %~1 GEQ %input_len% (
			set "output_string=%output_string%%RB_list_cache%"
		) else set "output_string=%output_string%%RB_list_cache:~0,1%"
	)
)

goto :EOF
:RB.add_work_string
if not defined work_string goto :EOF
set /a list_start=list_start+1
set "work_string=%work_string:~1%"
set "work_string2=%work_string%"
set "RB_list_cache="
goto :EOF

:RB.replace_finish
echo "%output_string%">"%USERPROFILE%\rforbat.log"
:RB.end_clear
set "RB_cache="
set "work_string="
set "work_string2="
set "input_string="
set "output_string="
set "RB_list_cache="
set "for_delims="
set "list_start="
set "list_end="
set "loop="
set "same_char="
goto :EOF
:RB.error_input
echo [ERROR] ������Ч
pause
goto RB.end_clear

rem call :RB.long_string "[string]" "[return]"
:RB.long_string
if "%~1"=="" goto :EOF
if "%~2"=="" goto :EOF
set "string_long=0"
set "string_in=%~1"
if not defined ls_step set "ls_step=5"
if %ls_step% LSS 1 goto :EOF
:RB.long_string_loop
set /a string_long=string_long+ls_step
set "ls_check=!string_in:~%string_long%!"
if defined ls_check (
	goto RB.long_string_loop
)
set /a string_long=string_long-ls_step
set "ls_check=!string_in:~%string_long%!"
set "ls_lcheck=0"
:RB.long_string_l2
set "ls_lcheck_s=!ls_check:~%ls_lcheck%!"
if not "%ls_lcheck_s%"=="" (
	set /a string_long=string_long+1
) else goto RB.long_string_return
set /a ls_lcheck=ls_lcheck+1
goto RB.long_string_l2
:RB.long_string_return
set "ls_lcheck_s="
set "ls_lcheck="
set "ls_check="
set "string_in="
set "%~2=%string_long%"
set "string_long="
goto :EOF