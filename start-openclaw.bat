@echo off
chcp 65001 >nul
title OpenClaw 一键启动
echo ========================================
echo        OpenClaw 一键启动脚本 v1.0
echo ========================================
echo.

:: 1. 检查 Ollama 是否运行（可选）
echo [1/3] 检查 Ollama 服务...
curl -s http://127.0.0.1:11434/api/tags >nul 2>&1
if %errorlevel% equ 0 (
    echo       Ollama 已在运行 ✓
) else (
    echo       Ollama 未运行，正在启动...
    start "" "ollama serve"
    timeout /t 3 >nul
)

:: 2. 启动 OpenClaw Gateway
echo [2/3] 启动 OpenClaw Gateway...
start "" "C:\Users\%USERNAME%\AppData\Local\Programs\ClawX\ClawX.exe"
echo       Gateway 启动中，等待就绪...
timeout /t 5 >nul

:: 3. 启动 Watchdog
echo [3/3] 启动守护进程...
start "" powershell.exe -ExecutionPolicy Bypass -WindowStyle Minimized -File "C:\Users\%USERNAME%\.openclaw\workspace\scripts\gateway-watchdog.ps1"
echo       守护进程已启动 ✓

echo.
echo ========================================
echo   OpenClaw 启动完成！
echo   控制面板: http://127.0.0.1:18789
echo ========================================
echo.
pause
