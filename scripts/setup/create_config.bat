@echo off
setlocal
:: This script creates or overwrites the project's config.json file
:: with a predefined set of default values.
:: It will ALWAYS write a new config.json.

:: Parameter:
::   %1 - Config file path

set "CONFIG_FILE=%~1"

if "%CONFIG_FILE%"=="" (
    echo Error: Configuration file path (argument 1) is missing.
    exit /b 1
)

echo Creating/Updating default configuration file: %CONFIG_FILE%
echo {> "%CONFIG_FILE%"
echo   "project_name": "Cpp26Project",>> "%CONFIG_FILE%"
echo   "cpp_version": "26",>> "%CONFIG_FILE%"
echo   "llvm_version": "20.1.4",>> "%CONFIG_FILE%"
echo   "cmake_version": "3.27.8",>> "%CONFIG_FILE%"
echo   "vcpkg_commit": "2023.10.19",>> "%CONFIG_FILE%"
echo   "setup_date": "%DATE%",>> "%CONFIG_FILE%"
echo   "hot_reload_enabled": true,>> "%CONFIG_FILE%"
echo   "modules_enabled": true>> "%CONFIG_FILE%"
echo }>> "%CONFIG_FILE%"
echo Default configuration file updated: %CONFIG_FILE%

exit /b 0