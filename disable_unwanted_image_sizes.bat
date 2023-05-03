@echo off
cd /D %~dp0

PATH=C:\Users\admin\Desktop\jordan\thang\python

:loop_wordpress_dir
echo.
echo Enter wordpress path to be backed up
set wordpress_dir=C:\wamp64\www\wordpress
set /p wordpress_dir="Default is %wordpress_dir%: "
if not exist "%wordpress_dir%\" (
	echo %wordpress_dir% does not exist!
	goto loop_wordpress_dir
)

python.exe disable_unwanted_image_sizes.py %wordpress_dir%

pause