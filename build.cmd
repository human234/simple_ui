@echo off
rem Build the HMI gauge demo inside the official Zephyr Docker image.
rem Run from anywhere inside your west workspace; the workspace root is
rem located automatically and mounted at /workdir in the container.
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build.ps1" %*
exit /b %ERRORLEVEL%