@echo off
setlocal
:: This script creates or overwrites the project's config.json file.
:: It will ALWAYS write a new config.json based on the parameters provided.
:: Therefore, the calling script must supply all necessary project and version
:: parameters (%~2 through %~6) every time this script is invoked.

:: Create configuration file
:: Parameters:
::   %1 - Config file path
::   %2 - Project name
::   %3 - C++ version (optional)
::   %4 - LLVM version (optional)
::   %5 - CMake version (optional)
::   %6 - vcpkg commit (optional)

:: Essential parameters
set "CONFIG_FILE=%~1"
set "PROJECT_NAME=%~2"

if "%CONFIG_FILE%"=="" (
    echo Error: Configuration file path (argument 1) is missing.
    exit /b 1
)
if "%PROJECT_NAME%"=="" (
    echo Error: Project name (argument 2) is missing.
    exit /b 1
)

:: Optional parameters
set "CPP_VERSION=%~3"
set "LLVM_VERSION=%~4"
set "CMAKE_VERSION=%~5"
set "VCPKG_COMMIT=%~6"

echo Creating/Updating configuration file: %CONFIG_FILE%
echo {> "%CONFIG_FILE%"
echo   "project_name": "%PROJECT_NAME%",>> "%CONFIG_FILE%"
echo   "cpp_version": "%CPP_VERSION%",>> "%CONFIG_FILE%"
echo   "llvm_version": "%LLVM_VERSION%",>> "%CONFIG_FILE%"
echo   "cmake_version": "%CMAKE_VERSION%",>> "%CONFIG_FILE%"
echo   "vcpkg_commit": "%VCPKG_COMMIT%",>> "%CONFIG_FILE%"
echo   "setup_date": "%DATE%",>> "%CONFIG_FILE%"
echo   "hot_reload_enabled": true,>> "%CONFIG_FILE%"
echo   "modules_enabled": true>> "%CONFIG_FILE%"
echo }>> "%CONFIG_FILE%"
echo Configuration file updated: %CONFIG_FILE%

exit /b 0