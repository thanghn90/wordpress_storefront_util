@echo off
cd /D %~dp0

:loop_wamp_dir
echo.
echo Enter path to wampmanager.exe
set wamp_dir=C:\wamp64
set /p wamp_dir="Default is %wamp_dir%: "
if not exist "%wamp_dir%\wampmanager.exe" (
	echo No wampmanager.exe found in %wamp_dir%!
	goto loop_wamp_dir
)

:loop_mysqldump_dir
echo.
echo Enter path to mysqldump.exe
set mysqldump_dir=C:\wamp64\bin\mariadb\mariadb10.10.2\bin
set /p mysqldump_dir="Default is %mysqldump_dir%: "
if not exist "%mysqldump_dir%\mysqldump.exe" (
	echo No mysqldump_dir.exe found in %mysqldump_dir%!
	goto loop_mysqldump_dir
)

:loop_wordpress_dir
echo.
echo Enter wordpress path to be backed up
set wordpress_dir=C:\wamp64\www\wordpress
set /p wordpress_dir="Default is %wordpress_dir%: "
if not exist "%wordpress_dir%\" (
	echo %wordpress_dir% does not exist!
	goto loop_wordpress_dir
)
REM remove trailing backslash and get the wordpress folder name
if "%wordpress_dir:~-1%" == "\" set wordpress_dir=%wordpress_dir:~0,-1%
for %%f in ("%wordpress_dir%") do set "wordpress_folder=%%~nxf"

:loop_dbusername
echo.
echo Enter wordpress database name
set dbusername=root
set /p dbusername="Default is %dbusername%: "

echo.
set dbpassword=
set /p dbpassword="Enter %dbusername% password: "

echo.
echo (Optional) Enter 7z.exe path
set default_path7z=C:\Program Files\7-Zip
set /p path7z="Default is %default_path7z%: "
REM attempt to fall back to default
if not exist "%path7z%\7z.exe" set path7z=%default_path7z%

:loop_dbname
echo.
set dbname=
set /p dbname="Enter wordpress database name: "
if "%dbname%"=="" (
	echo ERROR! Empty database name!
	goto loop_dbname
)

REM Check if wampmanager.exe is running
REM Source: https://stackoverflow.com/questions/162291/how-to-check-if-a-process-is-running-via-a-batch-script
echo.
tasklist /fi "ImageName eq wampmanager.exe" /fo csv 2>NUL | find /I "wampmanager.exe">NUL
if not "%ERRORLEVEL%"=="0" (
	echo wampmanager.exe not run yet. Starting it now...
	start %wamp_dir%\wampmanager.exe
	echo please wait until wampmanager.exe has fully started and hit enter...
	pause
)
echo wampmanager.exe is running

REM First, backup sql database
echo.
echo Start backing up database...
if "%dbpassword%"=="" (
	REM no need for password
	"%mysqldump_dir%\mysqldump.exe" -u %dbusername% %dbname% > %dbname%.sql
) else (
	REM attempt to use password
	"%mysqldump_dir%\mysqldump.exe" -u %dbusername% -p %dbpassword% %dbname% > %dbname%.sql
)

REM then, depend on whether 7z was found, either copy the directory or zip it
echo.
if exist "%path7z%\7z.exe" (
	REM no need to zip the sql dump. User can browse it using phpmyadmin easily
	if exist backup_wordpress.7z del backup_wordpress.7z
	"%path7z%\7z.exe" a backup_wordpress.7z
) else (
	mkdir %wordpress_folder%
	xcopy /E %wordpress_dir% %wordpress_folder%
)

pause