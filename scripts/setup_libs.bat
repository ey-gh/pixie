@echo off
setlocal enabledelayedexpansion

REM ================================
REM Pixie Local Library Installer
REM Pinned versions:
REM - Crow: v1.2.1.2
REM - nlohmann/json: v3.12.0
REM - libpqxx: 7.10.1
REM ================================

REM Define base directories
set LIBS_DIR=backend\libs
set CROW_DIR=%LIBS_DIR%\crow
set JSON_DIR=%LIBS_DIR%\nlohmann
set PQXX_DIR=%LIBS_DIR%\libpqxx

echo Creating libs directory...
mkdir "%LIBS_DIR%" 2>nul

REM --------------------------------------------------
REM Install Crow (v1.2.1.2)
REM --------------------------------------------------
echo Cloning Crow (v1.2.1.2)...
git clone --branch v1.2.1.2 --depth=1 https://github.com/CrowCpp/crow.git "%CROW_DIR%"

REM --------------------------------------------------
REM Install nlohmann/json (v3.12.0)
REM --------------------------------------------------
echo Downloading nlohmann/json v3.12.0...
mkdir "%JSON_DIR%" 2>nul
curl -L -o "%JSON_DIR%\json.hpp" https://github.com/nlohmann/json/releases/download/v3.12.0/json.hpp

REM --------------------------------------------------
REM Install libpqxx (7.10.1)
REM --------------------------------------------------
echo Cloning libpqxx (7.10.1)...
git clone --branch 7.10.1 --depth=1 https://github.com/jtv/libpqxx.git "%PQXX_DIR%"

cd "%PQXX_DIR%"
mkdir build
cd build

REM Configure build using PostgreSQL installed on system
cmake .. -DCMAKE_INSTALL_PREFIX="../install" -DPostgreSQL_ROOT="C:\Program Files\PostgreSQL\17"

REM Build and install
cmake --build . --config Release
cmake --install . --config Release

REM Organize include and lib folders for use in CMake
cd ..
mkdir include
mkdir lib
xcopy /E /I /Y "install\include" "include"
xcopy /E /I /Y "install\lib" "lib"

echo.
echo All libraries installed successfully into %LIBS_DIR%
