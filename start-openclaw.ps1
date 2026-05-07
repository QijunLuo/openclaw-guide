# OpenClaw 一键启动脚本 (PowerShell 版)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "       OpenClaw 一键启动脚本 v1.0" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 检查 Ollama
Write-Host "[1/3] 检查 Ollama 服务..." -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri "http://127.0.0.1:11434/api/tags" -TimeoutSec 3 -ErrorAction Stop
    Write-Host "      Ollama 已在运行" -ForegroundColor Green
} catch {
    Write-Host "      Ollama 未运行，正在启动..." -ForegroundColor Yellow
    Start-Process "ollama" -ArgumentList "serve" -WindowStyle Minimized
    Start-Sleep -Seconds 3
}

# 2. 启动 ClawX Gateway
Write-Host "[2/3] 启动 OpenClaw Gateway..." -ForegroundColor Yellow
$clawxPath = "$env:LOCALAPPDATA\Programs\ClawX\ClawX.exe"
if (Test-Path $clawxPath) {
    # 先检查是否已运行
    $existing = Get-Process -Name "ClawX" -ErrorAction SilentlyContinue
    if (-not $existing) {
        Start-Process -FilePath $clawxPath
        Write-Host "      ClawX 已启动，等待就绪..." -ForegroundColor Green
        Start-Sleep -Seconds 6
    } else {
        Write-Host "      ClawX 已在运行" -ForegroundColor Green
    }
} else {
    Write-Host "      [错误] 找不到 ClawX.exe，请确认安装路径" -ForegroundColor Red
}

# 3. 启动 Watchdog
Write-Host "[3/3] 启动守护进程..." -ForegroundColor Yellow
$watchdog = "$env:USERPROFILE\.openclaw\workspace\scripts\gateway-watchdog.ps1"
if (Test-Path $watchdog) {
    $existingWatchdog = Get-Process -Name "powershell" -ErrorAction SilentlyContinue | Where-Object { $_.StartTime -gt (Get-Date).AddMinutes(-2) }
    if (-not $existingWatchdog) {
        Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Minimized -File `"$watchdog`"" -WindowStyle Minimized
    }
    Write-Host "      守护进程已启动" -ForegroundColor Green
} else {
    Write-Host "      [警告] 找不到 Watchdog 脚本，跳过" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw 启动完成！" -ForegroundColor Green
Write-Host "  控制面板: http://127.0.0.1:18789" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Read-Host "按 Enter 键关闭"
