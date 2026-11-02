@echo off
setlocal enabledelayedexpansion

chcp 65001 >nul
title WinRAR Activator v2.2 Launcher

if not exist "%~dp0WinRAR-Activator.ps1" (
    color 0C
    echo.
    echo  ==========================================================================
    echo   [-] ERROR: WinRAR-Activator.ps1 not found in this folder!
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

"%PS_EXEC%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0WinRAR-Activator.ps1" -Theme Purple

endlocal