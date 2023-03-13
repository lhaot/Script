@echo off & setlocal
chcp 65001 > NUL

:start
cd /d %~dp0

:main_start

:set_var_start
@REM settings files
set basic_branch_file=basic-branch.txt
set compare_branches_file=compare-branches.txt
@REM result file
set result_file=file-diff-result.txt
set error_log_file=error.log
@REM tmp files
set result_tmp_file=.result.tmp
set deduplicate_compare_branches_tmp_file=.deduplicate_compare_branches.tmp
set diff_tmp_file=.diff.tmp
set deduplicate_tmp_file=.deduplicate.tmp
@REM var
set basic_branch=
set error_msg=
:set_var_end

@REM clean work directory
:clean_dir_start
@REM clean result file if exists
if exist %result_file% ( del %result_file% )
@REM clean tmp files if exists
if exist %result_tmp_file% ( del %result_tmp_file% )
if exist %deduplicate_compare_branches_tmp_file% ( del %deduplicate_compare_branches_tmp_file% )
if exist %diff_tmp_file% ( del %diff_tmp_file% )
if exist %deduplicate_tmp_file% ( del %deduplicate_tmp_file% )
:clean_dir_end

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
    goto basic_branch_setting_end
)
if [%basic_branch%] == [] (
    set error_msg=ERROR: basic branch setting is blank
    goto error_start
)
:basic_branch_setting_end
echo basic branch is %basic_branch%.

:diff_start
echo starting diff...
sort /unique %compare_branches_file% > %deduplicate_compare_branches_tmp_file%
for /f "eol=#" %%i in ( %deduplicate_compare_branches_tmp_file% ) do (
    echo diff %basic_branch%..%%i
    git diff --name-only %basic_branch%..%%i >> %diff_tmp_file%
)
copy %diff_tmp_file% %result_tmp_file% > NUL
echo diff done!
:diff_end

set /p deduplicate=continue deduplicate?(y/n)
if /i ["%deduplicate%"] == ["n"] ( goto deduplicate_end )
:deduplicate_start
echo starting deduplicate...
sort /unique %diff_tmp_file% > %deduplicate_tmp_file%
copy %deduplicate_tmp_file% %result_tmp_file% > NUL
echo deduplicate done!
:deduplicate_end

copy %result_tmp_file% %result_file% > NUL
@REM clean tmp files if exists
if exist %result_tmp_file% ( del %result_tmp_file% )
if exist %deduplicate_compare_branches_tmp_file% ( del %deduplicate_compare_branches_tmp_file% )
if exist %diff_tmp_file% ( del %diff_tmp_file% )
if exist %deduplicate_tmp_file% ( del %deduplicate_tmp_file% )
echo SUCCESS! see diff result in %result_file%
if exist %error_log_file% ( del %error_log_file% )
goto end

:main_end


:error_start
echo %error_msg%
echo %error_msg% > "%error_log_file%"
@REM clean tmp files if exists
if exist %result_tmp_file% ( del %result_tmp_file% )
if exist %deduplicate_compare_branches_tmp_file% ( del %deduplicate_compare_branches_tmp_file% )
if exist %diff_tmp_file% ( del %diff_tmp_file% )
if exist %deduplicate_tmp_file% ( del %deduplicate_tmp_file% )
goto end
:errot_end

:end