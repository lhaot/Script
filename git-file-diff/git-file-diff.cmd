@echo off
setlocal EnableDelaydExpansion
chcp 65001 > NUL

:start
cd /d %~dp0

:main_start

:set_var_start
@REM arg
set name_only="%1"
if "--name-only" == "%1" (
    set name_only="true"
) else (
    set name_only="false"
)
@REM settings files
set basic_branch_file=basic-branch.txt
set compare_branches_file=compare-branches.txt
@REM result file
set result_file=file-diff-result.txt
set error_log_file=error.log
@REM tmp files
set deduplicate_tmp_file=.deduplicate.tmp
set origin_tmp_file=.origin.tmp
@REM var
set basic_branch=
set error_msg=
:set_var_end

@REM clean result file if exists
if exist %result_file% ( del %result_file% )

:check_settings_file_start
if not exist %basic_branch_file% (
    set error_msg=ERROR: %basic_branch_file% not exist
    goto error_start
) else if not exist %compare_branches_file% (
    set error_msg=ERROR: %compare_branches_file% not exist
    goto error_start
)
:check_settings_file_end

:basic_branch_setting_start
for /f "eol=#" %%i in (%basic_branch_file%) do (
    set basic_branch=%%i
    set prefix=!basic_branch:~0,6!
    if "origin" NEQ "!prefix!" (
        set basic_branch=origin/%%i
        echo [INFO] %%i is not origin branch, transfer to !basic_branch!
    )
    goto basic_branch_setting_end
)
if [%basic_branch%] == [] (
    set error_msg=ERROR: basic branch setting is blank
    goto error_start
)
:basic_branch_setting_end
echo basic branch is !basic_branch!

:prepare_branch_start
echo starting diff...
sort /unique %compare_branches_file% /o %deduplicate_tmp_file%
for /f "eol=#" %%i in ( %deduplicate_tmp_file% ) do (
    set compare_branch=%%i
    set prefix=!compare_branch:~0,6!
    if "origin" NEQ "!prefix!" (
        set compare_branch=origin/%%i
        echo [INFO] %%i is not origin branch, transfer to !compare_branch!
    )
    echo !compare_branch! >> %origin_tmp_file%
)
sort /unique %origin_tmp_file% /o %deduplicate_tmp_file%
if exist %origin_tmp_file% ( del %origin_tmp_file% )
:prepare_branch_end

:diff_start
for /f "eol=#" %%i in ( %deduplicate_tmp_file% ) do (
    echo diff %basic_branch%..%%i
    echo # diff %basic_branch%..%%i >> %result_file%
    if "true" == "%name_only%" (
        git diff --name-only %basic_branch%..%%i >> %result_file%
    ) else (
        git diff %basic_branch%..%%i >> %result_file%
    )
    echo. >> %diff_tmp_file%
)
if exist %deduplicate_tmp_file% ( del %deduplicate_tmp_file% )
echo diff done!
:diff_end

if "true" == "%name_only%" goto deduplicate_end
set /p deduplicate=continue deduplicate? will remove branch name(y/n)
if /i ["%deduplicate%"] == ["n"] ( goto deduplicate_end )
:deduplicate_start
echo starting deduplicate...
for /f "eol=#" %%i in ( %result_tmp_file% ) do (
    echo %%i >> "%sort_tmp_file%"
)
if exist %result_file% ( del %result_file% )
sort /unique %deduplicate_tmp_file% /o %result_file%
if exist %deduplicate_tmp_file% ( del %deduplicate_tmp_file% )
echo deduplicate done!
:deduplicate_end

@REM clean tmp files if exists
echo [SUCCESS] see diff result in %result_file%
if exist %error_log_file% ( del %error_log_file% )
goto clean_dir_start

:main_end


:error_start
echo [ERROR] %error_msg%
echo [ERROR] %error_msg% > "%error_log_file%"
goto clean_dir_start
:errot_end

@REM clean work directory
:clean_dir_start
@REM clean tmp files if exists
if exist %deduplicate_tmp_file% ( del %deduplicate_tmp_file% )
if exist %origin_tmp_file% ( del %origin_tmp_file% )
:clean_dir_end

endlocal
:end