@echo off
setlocal enabledelayedexpansion

REM ================================
REM Pixie Local Library Installer
REM Pinned versions:
REM - Crow: v1.2.1.2
REM - nlohmann/json: v3.12.0
REM - libpqxx: 7.10.1
REM ================================

REM Navigate to script directory
pushd %~dp0

REM Set output directory (relative to script)
set "LIBS_DIR=..\backend\libs"
set "CROW_DIR=%LIBS_DIR%\crow"
set "JSON_DIR=%LIBS_DIR%\nlohmann"
set "PQXX_DIR=%LIBS_DIR%\libpqxx"
set "PQXX_LOCAL=%PQXX_DIR%\libpqxx_local"

echo Creating libs directory at %LIBS_DIR%...
mkdir "%LIBS_DIR%" 2>nul

REM ---------------- Crow ----------------
echo Installing Crow (v1.2.1.2)...
git clone --branch v1.2.1.2 --depth=1 https://github.com/CrowCpp/crow.git "%CROW_DIR%"
if errorlevel 1 (
    echo [ERROR] Failed to clone Crow
    exit /b 1
)

REM ---------------- JSON ----------------
echo Installing nlohmann/json (v3.12.0)...
mkdir "%JSON_DIR%" 2>nul
curl -L -o "%JSON_DIR%\json.hpp" https://github.com/nlohmann/json/releases/download/v3.12.0/json.hpp
if errorlevel 1 (
    echo [ERROR] Failed to download json.hpp
    exit /b 1
)

REM ---------------- libpqxx ----------------
echo Installing libpqxx (v7.10.1)...
git clone --branch 7.10.1 --depth=1 https://github.com/jtv/libpqxx.git "%PQXX_DIR%"
if errorlevel 1 (
    echo [ERROR] Failed to clone libpqxx
    exit /b 1
)

cd "%PQXX_DIR%"
mkdir build
cd build

echo Configuring libpqxx...
cmake .. -DCMAKE_INSTALL_PREFIX="%PQXX_LOCAL%" -DPostgreSQL_ROOT="C:\Program Files\PostgreSQL\17"
if errorlevel 1 (
    echo [ERROR] CMake configure failed
    exit /b 1
)

echo Building libpqxx...
cmake --build . --config Release
if errorlevel 1 (
    echo [ERROR] Build failed
    exit /b 1
)

echo Installing libpqxx...
cmake --install . --config Release
if errorlevel 1 (
    echo [ERROR] Install failed
    exit /b 1
)

cd ..
mkdir include 2>nul
mkdir lib 2>nul
xcopy /E /I /Y "%PQXX_LOCAL%\include" "include" >nul
xcopy /E /I /Y "%PQXX_LOCAL%\lib" "lib" >nul

REM Optional: clean up test binaries
rmdir /S /Q "build\test" >nul 2>&1

cd ..\..\..

popd

echo.
echo ==========================================
echo All libraries installed successfully:
echo %LIBS_DIR%
echo ==========================================
