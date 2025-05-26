@echo off

setlocal

set "DOWNLOAD_DIR=%~1"
if "%DOWNLOAD_DIR%"=="" set "DOWNLOAD_DIR=%TEMP%"

goto :main

:: Define color functions
:print_red
    powershell -Command "Write-Host '%~1' -ForegroundColor Red"
    goto :eof

:print_green
    powershell -Command "Write-Host '%~1' -ForegroundColor Green"
    goto :eof

:print_yellow
    powershell -Command "Write-Host '%~1' -ForegroundColor Yellow"
    goto :eof

:print_blue
    powershell -Command "Write-Host '%~1' -ForegroundColor Blue"
    goto :eof

:main
:: ======== Print Header using PowerShell Colors ========
call :print_blue "=========================================================="
call :print_blue "C++26 Development Environment Setup"
call :print_blue "=========================================================="
echo.


:: ======== Setup Paths ========
set "ROOT_DIR=%~dp0"
set "SCRIPTS_DIR=%ROOT_DIR%scripts"
set "SETUP_SCRIPTS_DIR=%SCRIPTS_DIR%\setup"
set "INSTALL_SCRIPTS_DIR=%SCRIPTS_DIR%\install"
set "DEPS_DIR=%ROOT_DIR%deps"
set "INSTALL_DIR=%ROOT_DIR%install"
set "BUILD_DIR=%ROOT_DIR%build"
set "DOWNLOAD_DIR=%ROOT_DIR%downloads"
set "VCPKG_DIR=%DEPS_DIR%\vcpkg"
set "CONFIG_FILE=%ROOT_DIR%config.json"

:: IMPORTANT: The version constants defined below are the source of truth for this setup script.
:: They are used to call the individual installer scripts and to generate the config.json file.
:: This script DOES NOT currently read versions from config.json to drive the setup process.
:: To change tool versions, modify them here and re-run setup.bat.
:: Define version constants
set "PROJECT_NAME=Cpp26Project"
set "CPP_VERSION=26"
set "LLVM_VERSION=20.1.4"
set "CMAKE_VERSION=3.27.8"
set "VCPKG_COMMIT=2023.10.19"

:: ======== Create Directories ========
call :print_blue "Creating directories..."
if not exist "%DEPS_DIR%" mkdir "%DEPS_DIR%"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%DOWNLOAD_DIR%" mkdir "%DOWNLOAD_DIR%"

:: ======== Check Admin Privileges ========
call :print_blue "Checking administrative privileges..."
call "%SETUP_SCRIPTS_DIR%\check_admin.bat"
if errorlevel 1 (
    call :print_red "Error: This script requires administrative privileges."
    echo Please run this script as an administrator.
    pause
    exit /b 1
)

:: ======== Create Configuration File ========
call :print_blue "Creating configuration file..."
call "%SETUP_SCRIPTS_DIR%\create_config.bat" "%CONFIG_FILE%" "%PROJECT_NAME%" "%CPP_VERSION%" "%LLVM_VERSION%" "%CMAKE_VERSION%" "%VCPKG_COMMIT%"
if errorlevel 1 (
    call :print_red "Error: Failed to create configuration file."
    pause
    exit /b 1
)

:: ======== Install Required Tools ========
call :print_blue "Installing Git..."
call "%INSTALL_SCRIPTS_DIR%\install_git.bat" "%DOWNLOAD_DIR%"
if errorlevel 1 (
    call :print_red "Error: Failed to install Git."
    pause
    exit /b 1
)

call :print_blue "Installing CMake..."
call "%INSTALL_SCRIPTS_DIR%\install_cmake.bat" "%DOWNLOAD_DIR%" "%CMAKE_VERSION%"
if errorlevel 1 (
    call :print_red "Error: Failed to install CMake."
    pause
    exit /b 1
)

call :print_blue "Installing Ninja..."
call "%INSTALL_SCRIPTS_DIR%\install_ninja.bat" "%DOWNLOAD_DIR%"
if errorlevel 1 (
    call :print_red "Error: Failed to install Ninja."
    pause
    exit /b 1
)

call :print_blue "Installing Python..."
call "%INSTALL_SCRIPTS_DIR%\install_python.bat" "%DOWNLOAD_DIR%"
if errorlevel 1 (
    call :print_red "Error: Failed to install Python."
    pause
    exit /b 1
)

call :print_blue "Installing LLVM/Clang..."
call "%INSTALL_SCRIPTS_DIR%\install_llvm.bat" "%DOWNLOAD_DIR%" "%LLVM_VERSION%"
if errorlevel 1 (
    call :print_red "Error: Failed to install LLVM/Clang."
    pause
    exit /b 1
)

call :print_blue "Installing Visual Studio ATL components..."
call "%INSTALL_SCRIPTS_DIR%\install_vs_atl.bat" "%DOWNLOAD_DIR%"
if errorlevel 1 (
    call :print_red "Error: Failed to install Visual Studio ATL components."
    pause
    exit /b 1
)

:: ======== Setup Visual Studio Environment ========
call :print_blue "Setting up Visual Studio environment..."
:: Run this and capture the temp file path with environment variables
for /f "tokens=*" %%i in ('call "%SETUP_SCRIPTS_DIR%\setup_vs_env.bat"') do (
    set "VS_ENV_FILE=%%i"
)

if not defined VS_ENV_FILE (
    call :print_yellow "Warning: Visual Studio environment setup failed."
    call :print_yellow "Some features may not work without Visual Studio."
) else (
    :: Source the environment variables from the temp file
    call "%VS_ENV_FILE%"
    :: Clean up the temp file
    del "%VS_ENV_FILE%" >nul 2>&1
    call :print_green "Visual Studio environment setup succeeded."
)

:: ======== Setup vcpkg ========
call :print_blue "Setting up vcpkg..."
call "%SETUP_SCRIPTS_DIR%\setup_vcpkg.bat" "%ROOT_DIR%" "%VCPKG_DIR%" "%VCPKG_COMMIT%"
if errorlevel 1 (
    call :print_red "Error: Failed to set up vcpkg."
    pause
    exit /b 1
)

:: ======== Set Environment Variables ========
call :print_blue "Setting environment variables..."
call "%SETUP_SCRIPTS_DIR%\setup_env_vars.bat" "%ROOT_DIR%" "%DEPS_DIR%" "%INSTALL_DIR%" "%BUILD_DIR%" "%DOWNLOAD_DIR%" "%VCPKG_DIR%"
if errorlevel 1 (
    call :print_red "Error: Failed to set environment variables."
    pause
    exit /b 1
)

:: ======== Run verification script ========
call :print_blue "Verifying installations..."
call "%SETUP_SCRIPTS_DIR%\verify_installs.bat"
if errorlevel 1 (
    call :print_red "Warning: Some verifications failed."
)

:: ======== Setup Complete ========
call :print_green "=========================================================="
call :print_green "C++26 Development Environment Setup Complete!"
call :print_green "=========================================================="
echo.
echo Project configuration:
echo   - Project name: %PROJECT_NAME%
echo   - C++ version: %CPP_VERSION%
echo   - LLVM version: %LLVM_VERSION%
echo   - CMake version: %CMAKE_VERSION%
echo   - vcpkg commit: %VCPKG_COMMIT%
echo.
echo Directories:
echo   - Root: %ROOT_DIR%
echo   - Dependencies: %DEPS_DIR%
echo   - Install: %INSTALL_DIR%
echo   - Build: %BUILD_DIR%
echo   - vcpkg: %VCPKG_DIR%
echo.
call :print_yellow "To verify your setup, please run:"
call :print_yellow "run_all_tests.bat"
echo.
call :print_green "You can now start developing your C++26 project!"
echo.

pause
exit /b 0 