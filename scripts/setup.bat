@echo off
setlocal enabledelayedexpansion

echo.
echo === Pixie Environment Setup ===
echo.

REM Go to repo root
cd /d %~dp0..
set ROOT=%CD%

REM Step 1: Create libs/ and fetch dependencies
echo [1/4] Installing local libraries...
call scripts\setup_libs.bat || goto :error

REM Step 2: Load environment variables from .env.database
echo [2/4] Loading .env.database into PowerShell environment...
powershell -ExecutionPolicy Bypass -File scripts\load.env.ps1 || goto :error

REM Step 3: Configure CMake backend
echo [3/4] Configuring CMake backend...
cmake -S backend -B backend\build || goto :error

REM Step 4: Build backend
echo [4/4] Building backend...
cmake --build backend\build --config Release || goto :error

echo.
echo Setup complete. You can now run the backend or dev DB tools.
goto :eof

:error
echo Setup failed. Check the step above for details.
exit /b 1