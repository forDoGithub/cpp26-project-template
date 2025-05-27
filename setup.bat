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
set "READ_CONFIG_SCRIPT=%SCRIPTS_DIR%\utils\read_config.ps1"

:: Configuration is now loaded from config.json via read_config.ps1
:: If config.json does not exist, a default one is created.

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

:: ======== Load Configuration ========
:: Check if config.json exists. If not, create a default one.
if not exist "%CONFIG_FILE%" (
    call :print_yellow "Configuration file (%CONFIG_FILE%) not found. Creating default configuration..."
    call "%SETUP_SCRIPTS_DIR%\create_config.bat" "%CONFIG_FILE%"
    if errorlevel 1 (
        call :print_red "Error: Failed to create default configuration file."
        pause
        exit /b 1
    )
)

:: Read configuration from config.json using PowerShell script
call :print_blue "Loading configuration from %CONFIG_FILE%..."
set "TEMP_CONFIG_LOADER=%TEMP%\load_config_vars.bat"
if exist "%TEMP_CONFIG_LOADER%" del "%TEMP_CONFIG_LOADER%"

powershell -ExecutionPolicy Bypass -NoProfile -File "%READ_CONFIG_SCRIPT%" "%CONFIG_FILE%" > "%TEMP_CONFIG_LOADER%"

if errorlevel 1 (
    call :print_red "Error: Failed to execute read_config.ps1. PowerShell might not be available or script failed."
    if exist "%TEMP_CONFIG_LOADER%" del "%TEMP_CONFIG_LOADER%"
    pause
    exit /b 1
)

if not exist "%TEMP_CONFIG_LOADER%" (
    call :print_red "Error: read_config.ps1 did not produce an output file."
    pause
    exit /b 1
)

call "%TEMP_CONFIG_LOADER%"
del "%TEMP_CONFIG_LOADER%"

:: Verify a key variable was set to ensure config loading was successful
if not defined CONFIG_LLVM_VERSION (
    call :print_red "Error: Failed to load configuration variables from %CONFIG_FILE%."
    call :print_red "The file might be empty or severely malformed, or read_config.ps1 failed silently."
    pause
    exit /b 1
)
call :print_green "Configuration loaded successfully."
echo.

:: ======== Install Required Tools (using loaded configuration) ========
call :print_blue "Installing Git..."
call "%INSTALL_SCRIPTS_DIR%\install_git.bat" "%DOWNLOAD_DIR%"
if errorlevel 1 (
    call :print_red "Error: Failed to install Git."
    pause
    exit /b 1
)

call :print_blue "Installing CMake..."
call "%INSTALL_SCRIPTS_DIR%\install_cmake.bat" "%DOWNLOAD_DIR%" "%CONFIG_CMAKE_VERSION%"
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
call "%INSTALL_SCRIPTS_DIR%\install_llvm.bat" "%DOWNLOAD_DIR%" "%CONFIG_LLVM_VERSION%"
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
call "%SETUP_SCRIPTS_DIR%\setup_vcpkg.bat" "%ROOT_DIR%" "%VCPKG_DIR%" "%CONFIG_VCPKG_COMMIT%"
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
echo Project configuration (from %CONFIG_FILE%):
echo   - Project name: %CONFIG_PROJECT_NAME%
echo   - C++ version: %CONFIG_CPP_VERSION%
echo   - LLVM version: %CONFIG_LLVM_VERSION%
echo   - CMake version: %CONFIG_CMAKE_VERSION%
echo   - vcpkg commit: %CONFIG_VCPKG_COMMIT%
echo   - Hot Reload Enabled: %CONFIG_HOT_RELOAD_ENABLED%
echo   - Modules Enabled: %CONFIG_MODULES_ENABLED%
echo   - Setup Date: %CONFIG_SETUP_DATE%
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