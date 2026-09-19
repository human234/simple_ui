@echo off
rem Flash the last build to the board via the Zephyr Docker image.
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build.ps1" -Flash %*
exit /b %ERRORLEVEL%