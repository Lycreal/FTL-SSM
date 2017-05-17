@echo off
setlocal enabledelayedexpansion
title FTL存档管理
::作者：Lycreal
mode con cols=90 lines=30
::检查工作目录
::手动设置方法：用你的存档(ae_prof.sav)所在目录取代这里的%~dp0，不带引号
set workdir=%~dp0
cd /d %workdir%
if exist ae_prof.sav goto prestart
set workdir=%USERPROFILE%\Documents\My Games\FasterThanLight
cd /d %workdir% 2>nul
if exist ae_prof.sav goto prestart

echo 找不到ae_prof.sav，请手动设置工作目录。
pause && exit

:prestart
if not exist backup mkdir backup
:start
cls
echo ==============================================================
echo                          FTL存档管理
echo ==============================================================
echo 工作目录：%workdir%
echo.
call :list
echo.
echo 选项：
echo S. 快速保存
echo Sn.保存至槽位n
echo L. 快速读取
echo Ln.从槽位n读取
echo R. 从备份恢复当前存档
echo Rn.从备份恢复槽位n
echo Dn.删除槽位n和其备份(！)
echo X. 退出
echo.
set in=Z
set /p in=输入序号（直接回车刷新）：
if /I %in%==Z goto start
if /I %in%==X exit
if /I %in%==S set in=S0
if /I %in:~0,1%==S goto save
if /I %in%==L set in=L0
if /I %in:~0,1%==L goto load
if /I %in%==R goto rec
if /I %in:~0,1%==R goto recn
if /I %in:~0,1%==D goto del
echo 输入有误，请重新输入。
pause && goto start
:list
for %%I in (continue.sav) do (
	set /p=当前存档修改时间：%%~tI	备份：<nul
	if exist backup/continue.sav ( for %%P in ( backup/continue.sav ) do ( echo %%~tP ) ) else ( echo 无 )
)
echo.
for %%I in (backup\slot*.sav) do (
	set file=%%~nI
	set sl=!file:~4!
	set /p=槽位!sl!	修改时间：%%~tI	备份：<nul
	if exist backup/slot!sl!.bak ( for %%Q in ( backup/slot!sl!.bak ) do ( echo %%~tQ ) ) else ( echo 无 )
)
goto :eof
:save
set slot=slot%in:~1%
echo 即将保存至槽位%in:~1%...
if exist backup\%slot%.sav copy /y backup\%slot%.sav backup\%slot%.bak
copy /y continue.sav backup\%slot%.sav
pause && goto start
:load
set slot=slot%in:~1%
if not exist backup\%slot%.sav echo 槽位%in:~1%为空！ && pause && goto start
echo 即将从槽位%in:~1%中读取...
copy /y continue.sav backup\continue.sav
copy /y backup\%slot%.sav continue.sav
pause && goto start
:rec
if not exist backup\continue.sav echo 没有当前存档的备份！ && pause && goto start
echo 即将恢复当前存档...
copy /y continue.sav backup\continue.sav.tmp
copy /y backup\continue.sav continue.sav
move /y backup\continue.sav.tmp backup\continue.sav
pause && goto start
:recn
set slot=slot%in:~1%
if not exist backup\%slot%.bak echo 没有槽位%in:~1%的备份！ && pause && goto start
echo 即将恢复槽位%in:~1%...
copy /y backup\%slot%.sav backup\%slot%.sav.tmp
copy /y backup\%slot%.bak backup\%slot%.sav
move /y backup\%slot%.sav.tmp backup\%slot%.bak
pause && goto start
:del
set slot=slot%in:~1%
if not exist backup\%slot%.sav echo 槽位%in:~1%为空！ && pause && goto start
echo 即将删除槽位%in:~1%...
set /p sure=输入Y继续：
if /I not "%sure%"=="Y" echo 操作取消。 && pause && goto start
del /S backup\%slot%.sav
del /S backup\%slot%.bak
pause && goto start