@echo off
setlocal enabledelayedexpansion

chcp 65001 >nul
title WinRAR Activator v2.3

cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -ArgumentList '%*' -Verb RunAs"
    exit /b
)

if not exist "WinRAR-Activator.ps1" (
    color 0C
    echo.
    echo  ==========================================================================
    echo   [-] ERROR: WinRAR-Activator.ps1 not found in current directory.
    echo  ==========================================================================
    echo.
    pause
    exit /b 1
)

set "PS_EXEC="
where pwsh >nul 2>&1
if %errorlevel% equ 0 (
    set "PS_EXEC=pwsh"
) else if exist "%ProgramFiles%\PowerShell\7\pwsh.exe" (
    set "PS_EXEC=%ProgramFiles%\PowerShell\7\pwsh.exe"
) else if exist "%LocalAppData%\Microsoft\PowerShell\7\pwsh.exe" (
    set "PS_EXEC=%LocalAppData%\Microsoft\PowerShell\7\pwsh.exe"
) else (
    set "PS_EXEC=powershell"
)

"%PS_EXEC%" -NoProfile -ExecutionPolicy Bypass -File "WinRAR-Activator.ps1" %*

endlocal
exit /b %errorlevel%