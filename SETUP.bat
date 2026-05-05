@echo off
:: Launcher for setup-junctions.ps1 — auto-elevates to Administrator
:: (junction creation requires admin privileges)

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-junctions.ps1"

echo.
pause
